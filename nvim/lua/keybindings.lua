require "helpers/globals"
require "helpers/keyboard"

-- Overview of which map command works in which mode.

--      COMMANDS                    MODES ~
-- :map   :noremap  :unmap     Normal, Visual, Select, Operator-pending
-- :nmap  :nnoremap :nunmap    Normal
-- :vmap  :vnoremap :vunmap    Visual and Select
-- :smap  :snoremap :sunmap    Select
-- :xmap  :xnoremap :xunmap    Visual
-- :omap  :onoremap :ounmap    Operator-pending
-- :map!  :noremap! :unmap!    Insert and Command-line
-- :imap  :inoremap :iunmap    Insert
-- :lmap  :lnoremap :lunmap    Insert, Command-line, Lang-Arg
-- :cmap  :cnoremap :cunmap    Command-line

g.mapleader = " "                                                                -- Use Space, like key for alternative hotkeys

-- VIM {{{
nm("<leader>s", "<cmd>update<CR>")                                               -- Save file
nm("<leader>q", "<cmd>quit<CR>")                                                 -- Quit file
nm("<leader>t", "<cmd>tabnew<CR>")                                               -- Open new tab
nm("<leader>n", "<cmd>tabnext<CR>")                                              -- Move to next tab
nm("<leader>p", "<cmd>tabprevious<CR>")                                          -- Move to prev tab
nm("<leader>c", "<cmd>tabclose<CR>")                                             -- Close current tab
nm("<leader><BS>", "za<CR>")                                                     -- Folding with the spacebar
-- }}}

-- LSP {{{
nm("K", "<cmd>lua vim.lsp.buf.hover()<CR>")                                      -- Hover object
nm("ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")                               -- Code actions
nm("gR", "<cmd>lua vim.lsp.buf.rename()<CR>")                                    -- Rename an object
nm("gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")                               -- Go to declaration
-- }}}

-- Telescope {{{
nm("gd", "<cmd>Telescope lsp_definitions<CR>")                                   -- Goto declaration
nm("<leader>O", "<cmd>Telescope oldfiles<CR>")                                   -- Show recent files
nm("<leader>o", "<cmd>Telescope find_files<CR>")                                 -- Search for a file (ignoring git-ignore)
nm("<leader>i", "<cmd>Telescope jumplist<CR>")                                   -- Show jumplist (previous locations)
nm("<leader>f", "<cmd>Telescope live_grep<CR>")                                  -- Find a string in project
nm("<leader>b", "<cmd>Telescope buffers<CR>")                                    -- Show all buffers
nm("<leader>a", "<cmd>Telescope<CR>")                                            -- Show all commands
-- }}}

-- Trouble {{{
nm("<leader>x", "<cmd>TroubleToggle<CR>")                                        -- Show all problems in project (with help of LSP)
-- }}}

-- Neo Tree {{{
nm("<leader>e", "<cmd>NeoTreeFocusToggle<CR>")                                   -- Toggle file explorer
-- }}}

-- Noice {{{
nm("<leader>h", "<cmd>Noice telescope<CR>")                                      -- Opens Noice message history in Telescope
-- }}}