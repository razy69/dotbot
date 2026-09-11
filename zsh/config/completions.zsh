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

  # preview directory's content with eza when completing cd
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -T --icons $realpath'
  zstyle ':fzf-tab:complete:cd:*' fzf-flags --height=10% --prompt='Destination: '

  # preview directory's content with eza if directory or show file content with bat when completing ls
  zstyle ':fzf-tab:complete:ls:*' fzf-preview '[[ -d $realpath ]] && eza -a -h -H -i -l -g -U -m -u -S --octal-permissions --git --icons --long -F $realpath || bat -p --color=always $realpath'
  zstyle ':fzf-tab:complete:ls:*' fzf-flags --height=10% --prompt='Path: '

  # To make fzf-tab follow FZF_DEFAULT_OPTS.
  # NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  zstyle ':fzf-tab:*' fzf-flags --height=10% --prompt='Completion: '

  # switch group using `<` and `>`
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:*' fzf-bindings 'tab:down'
  zstyle ':fzf-tab:*' show-group brief

  # Do not complete with fzf
  # zstyle ':fzf-tab:complete:zshz:*' disabled-on any
fi

_comp_options+=(globdots)

zmodload zsh/complist

if (( $+commands[gopass] )) && [[ ! -s "${ZSH}/completions/_gopass" ]]; then
  gopass completion zsh > "${ZSH}/completions/_gopass"
fi

fpath=(
  ${ZSH}/completions
  ${ZSH}/plugins/zsh-completions/src
  $fpath
)

autoload -Uz compinit
# (Nmh+24) = matches only when dump is older than 24h; #q-syntax avoided (needs extended_glob)
_zcompdump_stale=( ${HOME}/.zcompdump(Nmh+24) )
# Some boot scripts write the dump with system-only fpath before we run,
# refreshing its mtime — content-probe for our user fpath before trusting -C.
[[ -f ${HOME}/.zcompdump ]] && _zcompdump_content="$(<${HOME}/.zcompdump)"
if (( ${#_zcompdump_stale} )) || [[ ${_zcompdump_content:-} != *"${ZSH}/completions"* ]]; then
  compinit
  zcompile "${HOME}/.zcompdump"
else
  compinit -C
fi
unset _zcompdump_stale _zcompdump_content

# Replay compdef calls captured by the pre-compinit stub in ~/.zshrc (see #Mise).
if (( ${+_zdefcomp} )); then
  for _zdef in "${_zdefcomp[@]}"; do
    compdef ${(z)_zdef}
  done
  unset _zdef _zdefcomp
fi
