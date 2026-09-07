# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Synchronize a module with Stow and push to GitHub - https://gemini.google.com/share/2eb889d6315d
dot-sync() {
    local module=$1
    local msg=$2

    if [ -z "$module" ]; then
        echo "Usage: dot-sync <module> [commit_message]"
        return 1
    fi

    # Go to dotfiles directory, exit if it fails
    cd ~/Projects/dinatih/dotfiles || return

    # 1. Apply symbolic links
    stow -t ~ -v "$module"

    # 2. Git operations
    # We only add the specific module folder to keep the commit atomic
    git -C .. add "dotfiles/$module"

    local commit_msg="${msg:-Update $module configuration}"
    git -C .. commit -m "$commit_msg"
    git -C .. push origin main

    # Return to previous directory
    cd - > /dev/null
    echo "✅ Module $module synchronized and pushed to GitHub."
}

# export EDITOR=nvim
export OLLAMA_API_BASE=http://localhost:11434

# >>> Codex installer >>>
export PATH="/home/dinatih/.local/bin:$PATH"
# <<< Codex installer <<<

export PATH="$PATH:/home/dinatih/fbx-viewer/target/release"

# Open any past version of a .blend file from git history in Blender
git-blend() {
    local commit="$1"
    local file="${2:-public/characters/lara/lara_perfect.blend}"
    if [ -z "$commit" ]; then
        (nohup blender "$file" >/dev/null 2>&1 &)
        return 0
    fi
    local base_name="$(basename "$file")"
    local tmp_file="/tmp/${commit}_${base_name}"
    git show "${commit}:${file}" > "$tmp_file" && (nohup blender "$tmp_file" >/dev/null 2>&1 &)
}


