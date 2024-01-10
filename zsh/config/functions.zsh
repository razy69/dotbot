##
# Functions
##

# Fix cursor
function _fix_cursor() {
  echo -ne '\x1b[\x35 q'
}

precmd_functions+=(_fix_cursor)


# SSH Agent
if [ ! -S "${HOME}/.ssh/ssh_auth_sock" ]; then
    eval $(ssh-agent)
    ln -sf "$SSH_AUTH_SOCK" "${HOME}/.ssh/ssh_auth_sock"
fi

export SSH_AUTH_SOCK="${HOME}/.ssh/ssh_auth_sock"
ssh-add -l > /dev/null || ssh-add


# Tmux share ssh-agent
function update_environment_from_tmux() {
  if [ -n "${TMUX}" ]; then
    eval "$(tmux show-environment -s)"
  fi
}

autoload -zU add-zsh-hook
add-zsh-hook precmd update_environment_from_tmux
