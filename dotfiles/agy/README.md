# Antigravity CLI (`agy`) Statusline

Custom statusline for Google Antigravity CLI (`agy`) with Starship cyan styling.

## Features

- **Model & Context window**: Active model, tokens used / context window size and percentage (`Gemini 3.8 Flash  154.0k/1000.0k (15%)`).
- **Running Cost (`cost`)**: Non-rounded estimated session cost in USD (introduced in `agy` 1.1.21). Formatted in green (`$0.0042`).
- **Quota & Limits (`/usage`)**: Displays remaining quota percentages for 5-hour and weekly limits. Automatically adapts to active model family (Gemini vs Claude/GPT) with non-blocking background caching.
- **Last turn token stats**: Token consumption of the latest turn (`↳ 1.2k (out:420 cache:800)`).
- **Git status**: Additions / deletions in current working directory (`+14 -2`).

## Requirements

- `jq`
- `awk`
- `agy` >= 1.1.21

## Installation & Setup

### With GNU Stow

```bash
cd ~/Projects/dinatih/dotfiles
stow -t ~ agy
```

Or manually:

```bash
cp .local/bin/agy-statusline.sh ~/.local/bin/
chmod +x ~/.local/bin/agy-statusline.sh
```

### Enable in Antigravity CLI

In `~/.gemini/antigravity-cli/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.local/bin/agy-statusline.sh"
  }
}
```

Or directly inside an interactive `agy` session:

```text
/statusline bash ~/.local/bin/agy-statusline.sh
```
