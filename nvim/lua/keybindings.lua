require "helpers/globals"
require "helpers/keyboard"

g.mapleader = " "                                                                -- Use Space, like key for alternative hotkeys

-- VIM {{{
nm("<C-e>", "<cmd>ene!<CR>")                                                     -- Edit a new, unnamed buffer. Discard any changes to the current buffer.
nm("<C-t>", "<cmd>tabnew<CR>")                                                   -- Open new tab
nm("<C-n>", "<cmd>tabnext<CR>")                                                  -- Move to next tab
nm("<C-p>", "<cmd>tabprevious<CR>")                                              -- Move to prev tab
nm("<C-c>", "<cmd>tabclose<CR>")                                                 -- Close current tab
nm("<C-space>", "za<CR>")                                                        -- Folding with the spacebar
-- }}}

-- LSP {{{
nm("K", "<cmd>lua vim.lsp.buf.hover()<CR>")                                      -- Hover object
nm("ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")                               -- Code actions
nm("gR", "<cmd>lua vim.lsp.buf.rename()<CR>")                                    -- Rename an object
nm("gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")                               -- Go to declaration
-- }}}

-- Telescope {{{
nm("gd", "<cmd>Telescope lsp_definitions<CR>")                                   -- Goto declaration
nm("<leader>p", "<cmd>Telescope oldfiles<CR>")                                   -- Show recent files
nm("<leader>O", "<cmd>Telescope git_files<CR>")                                  -- Search for a file in project
nm("<leader>o", "<cmd>Telescope find_files<CR>")                                 -- Search for a file (ignoring git-ignore)
nm("<leader>i", "<cmd>Telescope jumplist<CR>")                                   -- Show jumplist (previous locations)
nm("<leader>b", "<cmd>Telescope git_branches<CR>")                               -- Show git branches
nm("<leader>f", "<cmd>Telescope live_grep<CR>")                                  -- Find a string in project
nm("<leader>q", "<cmd>Telescope buffers<CR>")                                    -- Show all buffers
nm("<leader>a", "<cmd>Telescope<CR>")                                            -- Show all commands
nm("<leader>t", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>")              -- Search for dynamic symbols
-- }}}

-- Trouble {{{
nm("<leader>x", "<cmd>TroubleToggle<CR>")                                        -- Show all problems in project (with help of LSP)
nm("gr", "<cmd>Trouble lsp_references<CR>")                                      -- Show use of object in project
-- }}}

-- Neo Tree {{{
nm("<C-o>", "<cmd>NeoTreeFocusToggle<CR>")                                       -- Toggle file explorer
-- }}}