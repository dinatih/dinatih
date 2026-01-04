# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

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
