-- Theme: Catppuccin with mini.icons
plugin.add({
  name = "catppuccin",
  src = {
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/echasnovski/mini.icons",
  },
  config = function()
    -- Monkey-patch: many plugins require nvim-web-devicons; this intercepts
    -- those require() calls and redirects them to mini.icons instead.
    package.preload["nvim-web-devicons"] = function()
      local ok, icons = pcall(require, "mini.icons")
      if ok then
        icons.mock_nvim_web_devicons()
      end
      return package.loaded["nvim-web-devicons"]
    end

    -- Catppuccin options saved for reuse by the OptionSet handler below.
    -- custom_highlights uses catppuccin's function form so the palette is
    -- re-fetched per flavor (dark/light) instead of captured once.
    local catppuccin_opts = {
      flavour = utils.get_flavor(),
      transparent_background = false, -- disables setting the background color.
      show_end_of_buffer = false,     -- shows the "~" characters after the end of buffers
      term_colors = true,             -- sets terminal colors (e.g. `g:terminal_color_0`)
      dim_inactive = {
        enabled = false,              -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.45,            -- percentage of the shade to apply to the inactive window
      },
      compile = {
        enabled = true,
        path = vim.fn.stdpath("cache") .. "/catppuccin",
      },
      no_italic = true,    -- Force no italic
      no_bold = false,     -- Force no bold
      no_underline = true, -- Force no underline
      integrations = {
        blink_cmp = true,
        blink_indent = true,
        blink_pairs = true,
        dap = false,
        dap_ui = false,
        dropbar = { enabled = true, color_mode = true },
        flash = true,
        fzf = true,
        gitsigns = true,
        illuminate = { enabled = true, lsp = false },
        diffview = true,
        lsp_trouble = true,
        markdown = true,
        mini = { enabled = true },
        mason = true,
        native_lsp = { enabled = true, inlay_hints = { background = false } },
        neotest = true,
        nvim_surround = true,
        render_markdown = true,
        snacks = { enabled = true },
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      custom_highlights = function(colors)
        return {
          FloatBorder              = { fg = colors.blue, bg = colors.base },
          GitSignsCurrentLineBlame = { fg = colors.sky, bg = colors.base },
          -- neonvim.glow — region flashes on yank/undo/redo/paste/search/focus.
          -- surface2 tint + themed fg keeps the flash readable on frappe and
          -- latte without the hard-coded hexes undo-glow used to ship.
          GlowYank                 = { bg = colors.surface2, fg = colors.yellow },
          GlowUndo                 = { bg = colors.surface2, fg = colors.red },
          GlowRedo                 = { bg = colors.surface2, fg = colors.green },
          GlowPaste                = { bg = colors.surface2, fg = colors.teal },
          GlowSearch               = { bg = colors.surface2, fg = colors.mauve },
          GlowCursor               = { bg = colors.surface1 },
          -- Per-mode source colours. modes.nvim reads each `Modes<Mode>`
          -- hl group's bg and blends it against Normal.bg using
          -- line_opacity (see 02-modes.lua) to produce the selection /
          -- cursorline tint. fg doesn't matter here — modes.nvim only
          -- consults bg.
          ModesVisual              = { bg = colors.mauve }, -- visual/select selection → mauve
          ModesCopy                = { bg = colors.yellow }, -- yank flash → yellow
          ModesChange              = { bg = colors.green }, -- change (cc) → green
          ModesDelete              = { bg = colors.red }, -- delete (dd) → red
          ModesReplace             = { bg = colors.peach }, -- replace → peach (was yellow, but clashed with yank)
          NoiceMini                = { bg = colors.base },
          NormalFloat              = { fg = colors.text, bg = colors.base },
          SymbolUsageRounding      = { fg = colors.surface0 },
          SymbolUsageContent       = { fg = colors.overlay2, bg = colors.surface0 },
          SymbolUsageRef           = { fg = colors.blue, bg = colors.surface0 },
          SymbolUsageDef           = { fg = colors.yellow, bg = colors.surface0 },
          SymbolUsageImpl          = { fg = colors.mauve, bg = colors.surface0 },
          WhichKey                 = { fg = colors.yellow },
          WhichKeyDesc             = { fg = colors.text },
          WhichKeySeparator        = { fg = colors.pink },
          WhichKeyValue            = { fg = colors.subtext1 },
        }
      end,
    }

    -- Configure theme
    require("catppuccin").setup(catppuccin_opts)

    -- Apply colorscheme
    vim.cmd("colorscheme catppuccin")

    -- Reload catppuccin when background changes (covers :BackgroundToggle,
    -- :set bg=dark, and any external trigger). Reentrancy guard prevents
    -- recursion if colorscheme application touches vim.o.background.
    local reloading = false
    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      callback = function()
        if reloading then return end
        reloading = true
        -- Clear all catppuccin modules so stale palette/highlight caches don't persist
        for key in pairs(package.loaded) do
          if key:match("^catppuccin") then
            package.loaded[key] = nil
          end
        end
        catppuccin_opts.flavour = utils.get_flavor()
        require("catppuccin").setup(catppuccin_opts)
        vim.cmd("colorscheme catppuccin")
        -- Refresh dependent plugins that cache their theme
        local ok_statusline, statusline = pcall(require, "neonvim.statusline")
        if ok_statusline then
          statusline.refresh_highlights()
        end
        local ok_fzf, fzf = pcall(require, "fzf-lua")
        if ok_fzf then
          fzf.setup({ fzf_colors = true })
        end
        local ok_hlargs, hlargs_mod = pcall(require, "hlargs")
        if ok_hlargs then
          hlargs_mod.setup({ color = utils.get_palette().maroon })
        end
        -- modes.nvim captures `config.colors` at setup time and reuses those
        -- hex values from its ColorScheme autocmd. Re-running setup() swaps
        -- them to the new flavour so Modes* groups reflect latte on light /
        -- frappe on dark instead of staying frozen at the startup flavour.
        local ok_modes, modes_mod = pcall(require, "modes")
        if ok_modes then
          local p = utils.get_palette()
          modes_mod.setup({
            set_cursorline = true,
            colors = {
              copy = p.yellow,
              delete = p.red,
              change = p.teal,
              format = p.peach,
              insert = p.blue,
              replace = p.blue,
              visual = p.mauve,
            },
            line_opacity = {
              copy = 0.15,
              delete = 0.15,
              change = 0.15,
              format = 0.15,
              insert = 0.15,
              replace = 0.15,
              select = 0.5,
              visual = 0.5,
            },
          })
        end
        -- tiny-inline-diagnostic stores its TinyInline* highlight groups from
        -- DiagnosticError/Warn/Info/Hint at ColorScheme time. Setting
        -- vim.o.background re-sources the colorscheme re-entrantly (the
        -- compiled catppuccin cache writes back to 'background'), which
        -- causes a later `hi clear` to wipe the freshly-applied TinyInline
        -- groups after the plugin's own ColorScheme autocmd has run. We
        -- re-apply them once the reload cycle has fully unwound so the
        -- final state is consistent.
        vim.schedule(function()
          local ok_tiny, tiny = pcall(require, "tiny-inline-diagnostic")
          if ok_tiny and type(tiny.change) == "function" then
            pcall(tiny.change)
          end
        end)
        reloading = false
      end,
    })

    -- Toggle dark/light mode (OptionSet autocmd above handles the reload)
    vim.api.nvim_create_user_command("BackgroundToggle", function()
      vim.o.background = (vim.o.background == "dark") and "light" or "dark"
    end, { range = true })

    -- Dap UI signs
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition",
      { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
    vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
  end,
})
