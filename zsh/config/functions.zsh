##
# Functions
##

# Fix cursor
function _fix_cursor() {
  echo -ne '\x1b[\x35 q'
}
precmd_functions+=(_fix_cursor)


# Tmux env vars
function update_environment_from_tmux() {
  if [ -n "${TMUX}" ]; then
    eval "$(tmux show-environment -s)"
  fi
}

autoload -zU add-zsh-hook
add-zsh-hook precmd update_environment_from_tmux


# Utils
function uuid_gen() {
  if command -v uuidgen >/dev/null; then
    tr '[:upper:]' '[:lower:]' <<< $(uuidgen)
  else
    python3 -c 'import uuid; print(uuid.uuid4())'
  fi
}


# Tmux
function tmux_new() {
  if [ $# -eq 1 ]; then
    TMUX_ENV="${1}"
  else
    TMUX_ENV="local"
  fi

  tmux -L "${TMUX_ENV}" has-session -t "${TMUX_ENV}" 2>/dev/null \
    && tmux -L "${TMUX_ENV}" attach -t "${TMUX_ENV}" \
    || tmux -L "${TMUX_ENV}" new-session -s "${TMUX_ENV}" -c "${PWD}"
}


function tmux_kill() {
  if [ $# -eq 1 ]; then
    TMUX_ENV="${1}"
  else
    TMUX_ENV="local"
  fi

  tmux -L "${TMUX_ENV}" kill-server
}
