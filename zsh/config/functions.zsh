##
# Functions
##

# Tmux share ssh-agent
function update_environment_from_tmux() {
    if [ -n "${TMUX}" ]; then
        eval "$(tmux show-environment -s)"
    fi
}

add-zsh-hook precmd update_environment_from_tmux