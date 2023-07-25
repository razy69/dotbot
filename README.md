# dotbot

https://github.com/anishathalye/dotbot

## Configure dotfiles

zsh
  - fast-syntax-highlighting
  - zsh-autosuggestions
  - zsh-completions
  - Powerlevel10k

vim
  - vim-monokai-tasty 

nvim
  - lazy.nvim
  - indent-blankline 
  - bufferline
  - mason 
  - neo-tree
  - telescope
  - nvim-cmp
  - lspkind-vim
  - gitsigns
  - trouble
  - noice
  - treesitter
  - lualine
  - which-key
  - nvim-navic
  - lsp-lines
  - monokai-pro

tmux
  - tpm
  - tmux-resurrect
  - tmux-continuum

## How to install

```bash
$ git clone https://github.com/razy69/dotbot ~/.dotbot && cd ~/.dotbot
$ ./install
```

## How to register new keymap

```bash
$ autoload -Uz zkbd
$ zkbd
```

Then move generated file to `~/.dotbot/zsh/keymaps/`.

## Additional Setup

Font:
  - Any patched NerdFont: https://www.nerdfonts.com/font-downloads

Programs:
  - batcat: https://github.com/sharkdp/bat
  - delta: https://github.com/dandavison/delta
  - erdtree: https://github.com/solidiquis/erdtree
  - ripgrep: https://github.com/BurntSushi/ripgrep
  - fd: https://github.com/sharkdp/fd
  - exa: https://github.com/ogham/exa
