# Check if SSH login and Zsh is installed
if [ -n "$SSH_CLIENT" ] && command -v zsh &> /dev/null; then
    if [ -n "$ZSH_VERSION" ]; then
        echo "Already using Zsh"
    else
        exec zsh
    fi
fi
