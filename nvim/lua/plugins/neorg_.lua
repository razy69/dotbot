--[[
  File: neorg_.lua
  Description: Structured note taking, project and task management, time tracking, slideshows, writing typeset documents and much more.
  Link: https://github.com/nvim-neorg/neorg
]]


require("neorg").setup({
  load = {
    ["core.defaults"] = {},
    ["core.concealer"] = {},
    ["core.completion"] = {
      config = { engine = { module_name = "external.lsp-completion" } },
    },
    ["core.dirman"] = {
      config = {
        workspaces = {
          notes = "~/notes",
        },
        default_workspace = "notes",
      },
    },
    ["external.interim-ls"] = {
      config = {
        -- default config shown
        completion_provider = {
          -- Enable or disable the completion provider
          enable = true,

          -- Show file contents as documentation when you complete a file name
          documentation = true,

          -- Try to complete categories provided by Neorg Query. Requires `benlubas/neorg-query`
          categories = false,

          -- suggest heading completions from the given file for `{@x|}` where `|` is your cursor
          -- and `x` is an alphanumeric character. `{@name}` expands to `[name]{:$/people:# name}`
          people = {
            enable = false,

            -- path to the file you're like to use with the `{@x` syntax, relative to the
            -- workspace root, without the `.norg` at the end.
            -- ie. `folder/people` results in searching `$/folder/people.norg` for headings.
            -- Note that this will change with your workspace, so it fails silently if the file
            -- doesn't exist
            path = "people",
          }
        }
      }
    },
  }
})
