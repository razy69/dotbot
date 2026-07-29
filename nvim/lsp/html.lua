-- vscode-html-language-server: HTML LSP with embedded CSS/JS support
---@type vim.lsp.Config
return {
  mason = "html-lsp",
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "templ" },
  root_markers = {
    "package.json",
    ".git",
  },
  settings = {},
  init_options = {
    provideFormatter = true,
    -- Enable intellisense for embedded CSS and JS blocks
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { "html", "css", "javascript" },
  },
}
