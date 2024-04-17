require "helpers/globals"
require "helpers/keyboard"


-- Overview of which map command works in which mode.
--
-- nm(key, command)   Normal mode
-- im(key, command)   Input mode
-- vm(key, command)   Visual mode
-- tm(key, command)   Terminal mode


g.mapleader = " "                  -- Use Space, like key for alternative hotkeys

-- VIM {{{
nm("<leader>t", "<cmd>tabnew<CR>")       -- Open new tab
nm("<leader>n", "<cmd>tabnext<CR>")      -- Go next tab
nm("<leader>p", "<cmd>tabprevious<CR>")  -- Go previous tab
nm("<leader>q", "<cmd>quitall!<CR>")     -- Fast neovim exit
nm("<leader><BS>", "za<CR>")             -- Folding with the spacebar
-- }}}

-- LSP {{{
nm("ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")          -- Code actions
nm("gr", "<cmd>lua vim.lsp.buf.rename()<CR>")               -- Rename an object
nm("gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")          -- Go to declaration
nm("<leader>D", "<cmd>lua vim.diagnostic.open_float()<CR>") -- Open diagnostics float window
nm("<leader>R", "<cmd>LspRestart<CR>")                      -- Restart LSP Servers
-- }}}

-- Telescope {{{
nm("gd", "<cmd>lua require('telescope.builtin').lsp_definitions({jump_type='vsplit'})<CR>") -- Goto definitions
nm("gR", "<cmd>lua require('telescope.builtin').lsp_references({jump_type='vsplit'})<CR>")  -- Goto references
nm("<leader>O", "<cmd>Telescope oldfiles<CR>")                                              -- Show recent files
nm("<leader>o", "<cmd>Telescope find_files<CR>")                                            -- Search for a file (ignoring git-ignore)
nm("<leader>i", "<cmd>Telescope jumplist<CR>")                                              -- Show jumplist (previous locations)
nm("<leader>f", "<cmd>Telescope live_grep<CR>")                                             -- Find a string in project
nm("<leader>b", "<cmd>Telescope buffers<CR>")                                               -- Show all buffers
nm("<leader>z", "<cmd>Telescope<CR>")                                                       -- Show all commands
nm("<leader>d", "<cmd>Telescope diagnostics<CR>")                                           -- Show diagnostics
nm("<leader>u", "<cmd>Telescope undo<CR>")                                                  -- Show Telescope Undo menu
-- nm("<leader>gcc", "<cmd>lua require('telescope.builtin').git_commits()<CR>")                -- Lists commits for current directory with diff preview
-- nm("<leader>gf", "<cmd>lua require('telescope.builtin').git_files()<CR>")                   -- Fuzzy search for files tracked by Git. This command lists the output of the `git ls-files` command.
-- nm("<leader>gbb", "<cmd>lua require('telescope.builtin').git_branches()<CR>")               -- List branches for current directory, with output from `git log --oneline` shown in the preview window
-- nm("<leader>gss", "<cmd>lua require('telescope.builtin').git_status()<CR>")                 -- Lists git status for current directory
-- nm("<leader>gst", "<cmd>lua require('telescope.builtin').git_stash()<CR>")                  -- Lists stash items in current directory
-- }}}

-- Neo Tree {{{
nm("<leader>e", "<cmd>Neotree toggle<CR>") -- Toggle file explorer
-- }}}

-- Noice {{{
nm("<leader>h", "<cmd>Noice telescope<CR>") -- Opens Noice message history in Telescope
-- }}}

-- WhichKey {{{
nm("<leader>`", "<cmd>WhichKey<CR>") -- Open WhichKey
-- }}}

-- Telekasten {{{
nm("<leader>nn", "<cmd>Telekasten panel<CR>") -- Open Telekasten Menu
-- }}}

-- Spectre {{{
nm("<leader>S", "<cmd>lua require('spectre').toggle()<CR>") -- Open/Close Spectre
nm("<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>") -- Search current word 
nm("<leader>sW", "<cmd>lua require('spectre').open_file_search({select_word=true})<CR>") -- Search on current file 
-- }}}

-- Neogen {{{
nm("<leader>a", "<cmd>lua require('neogen').generate()<CR>") -- Neogen Annotations
-- }}}

nm("<leader>bg", "<cmd>BackgroundToggle<CR>")

-- Disable Exising Bindings {{{
im("<C-n>", "<Nop>")
im("<C-p>", "<Nop>")
-- }}}
