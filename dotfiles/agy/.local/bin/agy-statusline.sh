#!/usr/bin/env bash
# Antigravity CLI (agy) status line with Context, Cost & Quotas (/usage)

input=$(cat)

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
# 2. Cost (Added in 1.1.21)
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
# 3. Quota / Usage info
# -----------------------------------------------------------------------------
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
  quota_str="  ${DIM}quota: [${quota_direct}]${RESET}"
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
    # Adapt to model family (Claude/GPT vs Gemini)
    case "$model" in
      *[cC]laude*|*[gG][pP][tT]*)
        q_5h=$(jq -r '[.command.data.groups[]?.buckets[]? | select(.id == "3p-5h") | ((.remaining_fraction // 0) * 100 | floor)][0] // empty' "$USAGE_CACHE" 2>/dev/null)
        q_w=$(jq -r '[.command.data.groups[]?.buckets[]? | select(.id == "3p-weekly") | ((.remaining_fraction // 0) * 100 | floor)][0] // empty' "$USAGE_CACHE" 2>/dev/null)
        ;;
      *)
        q_5h=$(jq -r '[.command.data.groups[]?.buckets[]? | select(.id == "gemini-5h") | ((.remaining_fraction // 0) * 100 | floor)][0] // empty' "$USAGE_CACHE" 2>/dev/null)
        q_w=$(jq -r '[.command.data.groups[]?.buckets[]? | select(.id == "gemini-weekly") | ((.remaining_fraction // 0) * 100 | floor)][0] // empty' "$USAGE_CACHE" 2>/dev/null)
        ;;
    esac
    
    if [ -n "$q_5h" ] || [ -n "$q_w" ]; then
      quota_str="  ${DIM}quota:${RESET} ${MAGENTA}5h:${q_5h:-?}%${RESET} ${DIM}w:${q_w:-?}%${RESET}"
    fi
  fi
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
# 5. Formatting & Rendering
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

  printf "${DIM}${CYAN}%s${RESET}  ${BOLD_CYAN}%s${RESET}${DIM}/%s${RESET}${DIM} (%s%%)${RESET}%s%s%s%s" \
    "$model" "$used_fmt" "$total_fmt" "$used_int" "$last_str" "$cost_str" "$quota_str" "$git_diff_str"
else
  printf "${DIM}${CYAN}%s${RESET}  ${DIM}ready${RESET}%s%s%s" \
    "$model" "$cost_str" "$quota_str" "$git_diff_str"
fi
