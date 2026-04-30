---@meta
-- Type-only declarations for globals registered in init.lua. The `---@meta`
-- annotation tells lua-language-server to read this file for types only —
-- it's never `require`d at runtime, so these declarations have no effect
-- on the editor session. Their job is to give hover, goto-definition, and
-- signature help for `plugin.*`, `utils.*`, and `get_fold_text` everywhere
-- they're referenced.

---@type neonvim.plugin
_G.plugin = nil

---@type neonvim.utils
_G.utils = nil

---@type fun(): string
_G.get_fold_text = nil
