--[[
	File: codecompanion_.lua
	Description: Code with LLMs and Agents via the in-built adapters, the community adapters or by building your own.
  Link: https://github.com/olimorris/codecompanion.nvim
]]

local llm_adapter = os.getenv("LLM_ADAPTER")
local llm_url = os.getenv("LLM_URL")
local llm_token = os.getenv("LLM_TOKEN")

require("codecompanion").setup({
  extensions = {
    mcphub = {
      callback = "mcphub.extensions.codecompanion",
      opts = {
        make_vars = true,
        make_slash_commands = true,
        show_result_in_chat = true,
      },
    },
  },
  strategies = {
    chat = { adapter = llm_adapter },
    inline = { adapter = llm_adapter },
    cmd = { adapter = llm_adapter },
  },
  adapters = {
    acp = { show_defaults = false },
    http = {
      opts = { show_defaults = false, show_model_choices = true },
      ovhcloud = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {
            url = llm_url,
            api_key = llm_token,
            chat_url = "/chat/completions",
            models_endpoint = "/models",
          },
          schema = {
            model = {
              default = "code_completion@latest",
            },
          },
        })
      end,
    },
  },
})
