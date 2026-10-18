#!/usr/bin/env bash
# Antigravity CLI (agy) status line with Quota (/usage & reset time), Model, Context, Cost & Git

input=$(cat)

# ANSI colors
CYAN=$'\e[36m'
BOLD_CYAN=$'\e[1;36m'
YELLOW=$'\e[33m'
BOLD_YELLOW=$'\e[1;33m'
GREEN=$'\e[32m'
MAGENTA=$'\e[35m'
DIM=$'\e[2m'
RESET=$'\e[0m'

# -----------------------------------------------------------------------------
# 1. Model & Context Window
# -----------------------------------------------------------------------------
model=$(echo "$input" | jq -r '.model.display_name // .model.id // empty')
total_tokens=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$total_tokens" ] && [ -n "$used_pct" ]; then
  used_tokens=$(awk "BEGIN {printf \"%.0f\", $total_tokens * $used_pct / 100}")
else
  used_tokens=""
fi

# Last turn tokens
last_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
last_output=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // empty')
last_cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

# -----------------------------------------------------------------------------
# 2. Quota / Usage info with reset time (placed at start of line)
# -----------------------------------------------------------------------------
fmt_time() {
  local reset_iso=$1
  [ -z "$reset_iso" ] || [ "$reset_iso" = "null" ] && return
  local reset_epoch now diff
  reset_epoch=$(date -d "$reset_iso" +%s 2>/dev/null) || return
  now=$(date +%s)
  diff=$((reset_epoch - now))
  if [ "$diff" -le 0 ]; then
    return
  fi
  local d=$((diff / 86400))
  local h=$(( (diff % 86400) / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  if [ "$d" -gt 0 ]; then
    echo "${d}j${h}h"
  elif [ "$h" -gt 0 ]; then
    echo "${h}h${m}m"
  else
    echo "${m}m"
  fi
}

quota_str=""

# Check if quota is directly passed in stdin
quota_direct=$(echo "$input" | jq -r '
  if .quota then
    [.quota[]? | "\(.id // .name): \(((.remaining_fraction // 0) * 100) | floor)%"] | join(" | ")
  else
    empty
  fi
' 2>/dev/null)

if [ -n "$quota_direct" ]; then
  quota_str="${DIM}[${RESET}${MAGENTA}${quota_direct}${RESET}${DIM}]${RESET}  "
else
  # Background cache for `agy -p "/usage"` (refreshed every 5 minutes to stay instantaneous)
  USAGE_CACHE="/tmp/agy_usage_cache_${USER}.json"
  CACHE_TTL=300

  now=$(date +%s)
  last_mod=0
  if [ -f "$USAGE_CACHE" ]; then
    last_mod=$(stat -c %Y "$USAGE_CACHE" 2>/dev/null || echo 0)
  fi

  if [ $((now - last_mod)) -gt $CACHE_TTL ]; then
    ( agy -p "/usage" --output-format json > "${USAGE_CACHE}.tmp" 2>/dev/null && mv "${USAGE_CACHE}.tmp" "$USAGE_CACHE" ) &
  fi

  if [ -f "$USAGE_CACHE" ]; then
    case "$model" in
      *[cC]laude*|*[gG][pP][tT]*)
        id_5h="3p-5h"
        id_w="3p-weekly"
        ;;
      *)
        id_5h="gemini-5h"
        id_w="gemini-weekly"
        ;;
    esac

    raw_q=$(jq -r --arg id5 "$id_5h" --arg idw "$id_w" '
      def b(bid): [.command.data.groups[]?.buckets[]? | select(.id == bid)][0];
      [
        (b($id5) | [((.remaining_fraction // empty) * 100 | floor), (.reset_time // "")]),
        (b($idw) | [((.remaining_fraction // empty) * 100 | floor), (.reset_time // "")])
      ] | flatten | @tsv
    ' "$USAGE_CACHE" 2>/dev/null)

    read -r q_5h r_5h q_w r_w <<< "$raw_q"

    part_5h=""
    if [ -n "$q_5h" ]; then
      t_5h=$(fmt_time "$r_5h")
      part_5h="${MAGENTA}5h:${q_5h}%${RESET}"
      [ -n "$t_5h" ] && part_5h+=" ${DIM}(${t_5h})${RESET}"
    fi

    part_w=""
    if [ -n "$q_w" ]; then
      t_w=$(fmt_time "$r_w")
      part_w="${MAGENTA}w:${q_w}%${RESET}"
      [ -n "$t_w" ] && part_w+=" ${DIM}(${t_w})${RESET}"
    fi

    if [ -n "$part_5h" ] && [ -n "$part_w" ]; then
      quota_str="${DIM}[${RESET}${part_5h} ${DIM}|${RESET} ${part_w}${DIM}]${RESET}  "
    elif [ -n "$part_5h" ]; then
      quota_str="${DIM}[${RESET}${part_5h}${DIM}]${RESET}  "
    elif [ -n "$part_w" ]; then
      quota_str="${DIM}[${RESET}${part_w}${DIM}]${RESET}  "
    fi
  fi
fi

# -----------------------------------------------------------------------------
# 3. Cost (Added in 1.1.21)
# -----------------------------------------------------------------------------
cost_val=$(echo "$input" | jq -r '.cost.total_usd // .cost // empty')
cost_str=""
if [ -n "$cost_val" ] && [ "$cost_val" != "null" ]; then
  cost_formatted=$(awk "BEGIN {
    c = $cost_val;
    if (c >= 0.10) {
      printf \"$%.2f\", c
    } else {
      printf \"$%.4f\", c
    }
  }")
  cost_str="  ${GREEN}${cost_formatted}${RESET}"
fi

# -----------------------------------------------------------------------------
# 4. Git diff line counts
# -----------------------------------------------------------------------------
cwd=$(echo "$input" | jq -r '.cwd // empty')
git_diff_str=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  diff_stat=$(git -C "$cwd" -c core.hooksPath=/dev/null diff --shortstat 2>/dev/null)
  insertions=$(echo "$diff_stat" | grep -oP '\d+(?= insertion)' || true)
  deletions=$(echo "$diff_stat" | grep -oP '\d+(?= deletion)' || true)
  if [ -n "$insertions" ] || [ -n "$deletions" ]; then
    git_diff_str="  "
    [ -n "$insertions" ] && git_diff_str+=$'\e[32m'"+${insertions}"$'\e[0m'
    [ -n "$insertions" ] && [ -n "$deletions" ] && git_diff_str+=" "
    [ -n "$deletions" ]  && git_diff_str+=$'\e[31m'"-${deletions}"$'\e[0m'
  fi
fi

# -----------------------------------------------------------------------------
# 5. Conversation Title
# -----------------------------------------------------------------------------
conv_title=$(echo "$input" | jq -r '.conversation_title // .title // .cascade_conversation_title // .conversation_name // empty' 2>/dev/null)
conv_str=""
if [ -n "$conv_title" ] && [ "$conv_title" != "null" ]; then
  conv_title=$(printf "%s" "$conv_title" | tr -d '\n\r')
  conv_str="  ${DIM}·${RESET} ${DIM}${conv_title}${RESET}"
fi

# -----------------------------------------------------------------------------
# 6. Formatting & Rendering
# -----------------------------------------------------------------------------
fmt() {
  local n=$1
  if [ -z "$n" ] || [ "$n" = "null" ]; then echo "?"; return; fi
  if [ "$n" -ge 1000 ]; then
    awk "BEGIN {printf \"%.1fk\", $n/1000}"
  else
    echo "$n"
  fi
}

if [ -n "$used_tokens" ] && [ -n "$total_tokens" ]; then
  used_fmt=$(fmt "$used_tokens")
  total_fmt=$(fmt "$total_tokens")
  used_int=$(printf "%.0f" "$used_pct")

  # Last turn tokens
  if [ -n "$last_output" ] && [ "$last_output" != "null" ] && [ "$last_output" -gt 0 ] 2>/dev/null; then
    last_total=$(( ${last_input:-0} + ${last_output:-0} ))
    last_fmt=$(fmt "$last_total")
    out_fmt=$(fmt "$last_output")
    cache_fmt=$(fmt "$last_cache_read")
    last_str="  ${BOLD_YELLOW}↳ ${last_fmt}${RESET}${DIM} (out:${out_fmt} cache:${cache_fmt})${RESET}"
  else
    last_str=""
  fi

  printf "%s${DIM}${CYAN}%s${RESET}  ${BOLD_CYAN}%s${RESET}${DIM}/%s${RESET}${DIM} (%s%%)${RESET}%s%s%s%s" \
    "$quota_str" "$model" "$used_fmt" "$total_fmt" "$used_int" "$last_str" "$cost_str" "$git_diff_str" "$conv_str"
else
  printf "%s${DIM}${CYAN}%s${RESET}  ${DIM}ready${RESET}%s%s%s" \
    "$quota_str" "$model" "$cost_str" "$git_diff_str" "$conv_str"
fi
