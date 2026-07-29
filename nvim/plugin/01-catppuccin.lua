-- Theme: Catppuccin with mini.icons
plugin.add({
  name = "catppuccin",
  src = {
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    -- nvim-web-devicons is deliberately NOT installed: mini.icons' mock below
    -- owns the "nvim-web-devicons" module name via package.preload, which wins
    -- over the package searchers, so the real plugin's Lua module would be
    -- permanently unreachable anyway. Its only other runtime file just sets
    -- g:nvim_web_devicons, which the mock sets too.
    "https://github.com/echasnovski/mini.icons",
  },
  config = function()
    -- Monkey-patch: many plugins require nvim-web-devicons. mini.icons ships
    -- the shim for that (mock_nvim_web_devicons installs its own
    -- `package.preload["nvim-web-devicons"]` returning a real mock table), so
    -- we call it directly instead of hand-rolling a preload loader — the
    -- hand-rolled one returned `package.loaded[...]`, which Lua only populates
    -- *after* the loader returns, so consumers could be handed `true` and blow
    -- up far from the cause. A plain require() also fails loudly, naming
    -- mini.icons, if the shim source is missing.
    require("mini.icons").mock_nvim_web_devicons()

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

    -- DAP sign highlights. catppuccin's `dap`/`dap_ui` integrations are off
    -- (see `integrations` above) and nothing else in the config defines these
    -- groups, so the `texthl` names used by the sign_define calls at the bottom
    -- of this file resolved to nothing and the signs rendered in the default
    -- colour. `:colorscheme` runs `hi clear`, so they must be re-applied from
    -- ColorScheme — which also covers the flavour swap on :BackgroundToggle.
    local function set_dap_highlights()
      local p = utils.get_palette()
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = p.red })
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = p.peach })
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = p.sky })
    end

    local theme_group = utils.augroup("Catppuccin")
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = theme_group,
      pattern = "*",
      callback = set_dap_highlights,
    })
    set_dap_highlights() -- the colorscheme above already fired ColorScheme

    -- Reload catppuccin when background changes (covers :BackgroundToggle,
    -- :set bg=dark, and any external trigger). Reentrancy guard prevents
    -- recursion if colorscheme application touches vim.o.background.
    --
    -- These re-theme themselves from their own ColorScheme autocmd, so the
    -- deferred ColorScheme re-fire below is all they need — do NOT re-add a
    -- per-plugin re-setup call for any of them:
    --   * neonvim.statusline (grouped ColorScheme -> setup_highlights)
    --   * modes.nvim         (ColorScheme -> H.define)
    --   * the Dap sign groups above (ColorScheme -> set_dap_highlights)
    -- Only fzf-lua (no ColorScheme autocmd at all) and hlargs (rebuilds its
    -- group, but from the hex frozen at setup time) need explicit handling.
    local reloading = false
    vim.api.nvim_create_autocmd("OptionSet", {
      group = theme_group,
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
        -- modes.nvim is deliberately NOT re-setup here. Its setup() creates 9
        -- UNGROUPED autocmds plus a vim.on_key callback and clears none of them
        -- (modes.nvim/lua/modes.lua:404-542), so every toggle leaked a
        -- keystroke handler and a duplicate autocmd set. It re-runs H.define
        -- from its own ColorScheme autocmd, so the Modes* groups get rebuilt
        -- for free. Caveat: `config` is a file-local with no accessor, so the
        -- explicit hexes passed by plugin/02-modes.lua (the single source of
        -- truth for those values) stay frozen at the startup flavour.
        -- TODO: to make mode colours flavour-aware, drop the explicit `colors`
        -- table in plugin/02-modes.lua so H.define falls back to
        -- `utils.get_bg('Modes<Mode>')` and reads the Modes* groups defined in
        -- custom_highlights above (ModesInsert/ModesFormat would need adding
        -- there, and modes.nvim resolves `change` to `delete` when unset).
        --
        -- Everything below runs one tick later, on purpose. Setting
        -- vim.o.background makes Neovim re-source the colorscheme *after* this
        -- handler returns, and that pass runs `hi clear` without firing
        -- ColorScheme — so any group written from inside this handler (or from
        -- a ColorScheme autocmd it triggered) is already gone by the time the
        -- toggle settles. Verified: a group set right before the assignment,
        -- the Dap groups, and hlargs' `Hlargs` all come back UNSET. Only
        -- catppuccin's own groups survive, because that re-source reapplies
        -- them. Deferring past the reload cycle is the only thing that sticks.
        vim.schedule(function()
          -- hlargs first: it re-creates its Hlargs group on ColorScheme, but
          -- from the hex captured at setup time, so re-running setup is what
          -- actually swaps flavour. It must happen BEFORE the ColorScheme
          -- re-fire below — hlargs writes with `default = true`, so whichever
          -- of the two writes lands first wins, and letting the stale one win
          -- makes the colour lag a full toggle behind. Safe to repeat: every
          -- autocmd it creates lives in an augroup with clear = true. Source of
          -- truth for the colour choice is plugin/02-hlargs.lua — keep in sync.
          local ok_hlargs, hlargs_mod = pcall(require, "hlargs")
          if ok_hlargs then
            hlargs_mod.setup({ color = utils.get_palette().maroon })
          end
          -- Re-fire ColorScheme now that the reload has unwound, so every
          -- consumer that themes from it rebuilds what the wipe destroyed:
          -- neonvim.statusline's St* groups, modes.nvim's derived
          -- Modes*CursorLine/Visual groups (H.define), and the Dap groups from
          -- the autocmd above. Measured without this: StSecX/StSecY and every
          -- Modes*CursorLine come back UNSET after one :BackgroundToggle. It is
          -- also the only way to re-theme modes.nvim without re-running its
          -- leaky setup(). `:colorscheme` fires these once already, so this only
          -- repeats work the toggle path was doing at the wrong time anyway.
          vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "catppuccin" })
          -- fzf-lua registers no ColorScheme autocmd of its own — it only calls
          -- setup_highlights() on module load and from setup() — so its FzfLua*
          -- groups and the light/dark terminal colour names need a manual nudge.
          -- Never call fzf.setup() here: with a falsy second argument it throws
          -- away the previous setup opts (fzf-lua/lua/fzf-lua/init.lua:183-193),
          -- which wiped everything configured in plugin/02-fzf-lua.lua —
          -- profile, winopts, grep.rg_opts, previewers — and re-registered
          -- fzf-lua as vim.ui.select by resetting `ui_select = false`.
          local ok_fzf, fzf = pcall(require, "fzf-lua")
          if ok_fzf then
            fzf.setup_highlights()
          end
          -- tiny-inline-diagnostic stores its TinyInline* groups from
          -- DiagnosticError/Warn/Info/Hint at ColorScheme time, so it needs the
          -- same deferred re-apply.
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

    -- Dap UI signs (texthl groups are defined by set_dap_highlights above)
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition",
      { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
    vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
  end,
})
