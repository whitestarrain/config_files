-- 不会用

local key_binding = require('lsp_keybing_config')
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require'lspconfig'.flow.setup {
  cmd = { "npx", "--no-install", "flow", "lsp" },
  on_attach = key_binding.on_attach,
  capabilities = capabilities
}
