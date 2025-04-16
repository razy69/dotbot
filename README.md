# dotbot

Dotfile manager: https://github.com/anishathalye/dotbot

## Configured dotfiles

- bat
- delta
- ghostty
- git
- k9s
- smise-en-place
- neovim
  - lazy.nvim (plugin manager)
  - alpha.nvim (dashboard)
  - blink.cmp (completion)
  - nvim-lspconfig (lsp config utils)
  - garbage-day.nvim (lsp kill unused lsp server)
  - lspsaga.nvim (lsp various utilities)
  - nvim-treesitter
  - conform.nvim (formatter)
  - noice.nvim (notifications)
  - nvim-bqf (qf improvements)
  - bool.nvim (better C-a/C-x)
  - undotree (undo manager)
  - lualine.nvim (statusbar)
  - fzf-lua (picker/fuzzy-finder)
  - neo-tree.nvim (file explorer)
  - trouble.nvim (diagnostics and other utilities)
  - rainbow-delimitiers.nvim (colorize parenthesis, brackets, square brackets)
  - hlargs.nvim (highlight function arguments)
  - vim-illuminate (highlight words)
  - gitsigns (status column git indicator)
  - indent-blankline.nvim (indent guide)
  - treesj (join/split code blocks)
  - nvim-autopairs (close parenthesis, brackets, square brackets)
  - numb.nvim (preview line when jump to line number)
  - markdown.nvim (preview markdown)
  - todo-comments.nvim (list TODO and other things)
  - Comment.nvim (enhance comments)
  - nvim-ts-context-commentstring (enhance comments)
  - neogen (code annotation)
  - arrow.nvim (mark utility)
  - mini.icons (icons provider)
  - nvim-colorizer (colorize colors code)
  - flash.nvim (better movements)
  - nvim-surround (improve surround)
  - persistence.nvim (session)
  - inc-rename (rename utility)
  - move.nvim (move line helpers)
  - which-key.nvim (keybindings help)
  - catppuccin (theme)
- tmux
  - tpm (plugin manager)
  - tmux-continuum
  - tmux-prefix-highlight
  - tmux-resurrect
- vim
- zsh

## How to install

```bash
git clone https://github.com/razy69/dotbot ~/.dotbot && cd ~/.dotbot
./install
```

Install mise-en-place (see: https://mise.jdx.dev/getting-started.html#installing-mise-cli)

```bash
mise install
```

## Additional Setup

Font:
  - Any patched NerdFont: https://www.nerdfonts.com/font-downloads
