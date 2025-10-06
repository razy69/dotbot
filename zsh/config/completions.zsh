##
# Completions
##

zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate _extensions
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'

if [[ $+commands[fzf] ]]; then
  # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
  zstyle ':completion:*' menu no

  # preview directory's content with exa when completing cd
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -T --icons $realpath'
  zstyle ':fzf-tab:complete:cd:*' fzf-flags --prompt='Destination: '

  # preview directory's content with exa if directory or show file content with bat when completing ls
  zstyle ':fzf-tab:complete:ls:*' fzf-preview '[[ -d $realpath ]] && exa -ahHilgUmuS --octal-permissions --git --icons --long -F $realpath || bat -p --color=always $realpath'
  zstyle ':fzf-tab:complete:ls:*' fzf-flags --prompt='Path: '

  # To make fzf-tab follow FZF_DEFAULT_OPTS.
  # NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  zstyle ':fzf-tab:*' fzf-flags --prompt='Completion: '

  # switch group using `<` and `>`
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:*' fzf-bindings 'ctrl-i:preview-half-page-up' 'tab:down'
  zstyle ':fzf-tab:*' show-group brief

  # Do not complete with fzf
  # zstyle ':fzf-tab:complete:zshz:*' disabled-on any
fi

_comp_options+=(globdots)

zmodload zsh/complist

fpath=(
  ${ZSH}/completions
  ${ZSH}/plugins/zsh-completions/src
  $fpath
)

# fast, thread-safe load of zsh completions
() {
  setopt local_options

  local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  local zcomp_ttl=1  # how many days to let the zcompdump file live before it must be recompiled
  local lock_timeout=1  # register an error if lock-timeout exceeded
  local lockfile="${zcompdump}.lock"

  autoload -Uz compinit

  # check for lockfile — if the lockfile exists, we cannot run a compinit
  #   if no lockfile, then we will create one, and set a trap on EXIT to remove it;
  #   the trap will trigger after the rest of the function has run.
  if [ -f "${lockfile}" ]
  then 

    # error log if the lockfile outlived its timeout
    if [ "$( find "${lockfile}" -mmin $lock_timeout )" ]
    then
      (
        echo "${lockfile} has been held by $(< ${lockfile}) for longer than ${lock_timeout} minute(s)."
        echo "This may indicate a problem with compinit"
      ) >&2
    fi

    # since the zcompdump is still locked, run compinit without generating a new dump
    compinit -D -d "$zcompdump"

    # Exit if there's a lockfile; another process is handling things
    return 1

  else

    # Create the lockfile with this shell's PID for debugging
    echo $$ > "${lockfile}"

    # Ensure the lockfile is removed on exit
    trap "rm -f '${lockfile}'" EXIT

  fi


  # refresh the zcompdump file if needed
  if [ ! -f "$zcompdump" -o "$( find "$zcompdump" -mtime "+${zcomp_ttl}" )" ]
  then
    # if the zcompdump is expired (past its ttl) or absent, we rebuild it
    compinit -d "$zcompdump"

  else

    # load the zcompdump without updating
    compinit -CD -d "$zcompdump"

    # asynchronously rebuild the zcompdump file
    (autoload -Uz compinit; compinit -d "$zcompdump" &);

  fi
}
