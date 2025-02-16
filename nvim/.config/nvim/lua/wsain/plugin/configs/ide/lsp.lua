local plugin = require("wsain.plugin.template"):new()

plugin.shortUrl = "neovim/nvim-lspconfig"
plugin.dependencies = {
  "glepnir/lspsaga.nvim",
  "folke/trouble.nvim",
  "whitestarrain/lua-dev.nvim",
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
  },
  "mfussenegger/nvim-jdtls",
  "ray-x/lsp_signature.nvim",
  "williamboman/mason.nvim",
}
plugin.loadEvent = "VeryLazy"

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  local function buf_set_keymap(...)
    vim.keymap.set(...)
  end
  local function opts(desc)
    return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  buf_set_keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts("code action"))
  buf_set_keymap("n", "<M-enter>", "<cmd>Lspsaga code_action<CR>", opts("code action"))
  -- buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts("code action"))

  buf_set_keymap("v", "<leader>ca", ":<C-U><cmd>lua vim.lsp.buf.code_action()<CR>", opts("code action"))
  buf_set_keymap("v", "<M-enter>", ":<C-U><cmd>lua vim.lsp.buf.code_action()<CR>", opts("code action"))

  -- Pressing the key twice will enter the hover window
  if client["name"] == "jdtls" then
    buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts("hover"))
    buf_set_keymap("v", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts("hover"))
  else
    buf_set_keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts("hover"))
    buf_set_keymap("v", "K", "<cmd>Lspsaga hover_doc<CR>", opts("hover"))
  end

  -- java-test
  if client["name"] == "jdtls" then
    buf_set_keymap("n", "<leader>cTc", function()
      require("jdtls").test_class()
    end, opts("test_class"))
    buf_set_keymap("n", "<leader>cTm", function()
      require("jdtls").test_nearest_method()
    end, opts("method test"))
  end

  buf_set_keymap("n", "<leader>cD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts("declaration"))

  buf_set_keymap("n", "<leader>cd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts("definition"))
  buf_set_keymap("n", "<leader>cp", "<cmd>Lspsaga peek_definition<CR>", opts("definition"))
  -- buf_set_keymap("n", "<leader>cd", "<cmd>Lspsaga goto_definition<CR>", opts("definition"))

  buf_set_keymap("n", "<c-]>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts("definition"))
  -- buf_set_keymap("n", "<c-]>", "<cmd>Lspsaga goto_definition<CR>", opts("definition"))

  buf_set_keymap("n", "<leader>ci", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts("implementation"))

  -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts("references"))
  -- [lspsaga] definition 和 references都会显示
  buf_set_keymap("n", "<leader>cr", "<cmd>Lspsaga finder ref+imp+def<CR>", opts("references"))

  buf_set_keymap("n", "<leader>cs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts("signature_help"))

  -- <C-p><C-p> to enter hover win
  -- buf_set_keymap("i", "<c-p>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts("signature_help"))
  buf_set_keymap("i", "<c-p>", function()
    require("lsp_signature").toggle_float_win()
  end, opts("signature_help")) -- <C-p><C-p> to enter hover win

  buf_set_keymap("n", "<leader>ce", "<cmd>Lspsaga rename<CR>", opts("edit signature"))

  -- buf_set_keymap('n', 'go', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  -- buf_set_keymap("n", "<leader>ce", "<cmd>Lspsaga show_line_diagnostics<CR>", opts("show diagnostics"))

  -- buf_set_keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts("prev diagnostics"))
  -- buf_set_keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts("next diagnostics"))

  -- format
  buf_set_keymap("n", "<space>cf", ":Format<CR>", opts("format"))
  buf_set_keymap("v", "<space>cf", ":Format<CR>", opts("format"))
end

local on_init = function(client, _)
  -- disable semantic highlight
  local enable_semantic_tokens_lsps = {
    clangd = true,
  }
  if client.supports_method("textDocument/semanticTokens") and enable_semantic_tokens_lsps[client["name"]] == nil then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

local function lsp_signature_setup()
  if package.loaded["lsp_signature"] ~= nil then
    return
  end
  require("lsp_signature").setup({
    floating_window = false,
    hint_enable = false,
  })
end

local function fidgetSetup()
  if package.loaded["fidget"] ~= nil then
    return
  end
  require("fidget").setup({
    window = {
      blend = 0,
      relative = "editor",
    },
  })
end

local function troubleSetup()
  if package.loaded["trouble"] ~= nil then
    return
  end
  require("trouble").setup({
    mode = "document_diagnostics",
    auto_open = false,
    auto_close = false,
    auto_preview = false,
    auto_fold = false,
    auto_jump = { "lsp_definitions" },
  })
end

local function lspsagaSetup()
  if package.loaded["lspsaga"] ~= nil then
    return
  end
  require("lspsaga").setup({
    symbol_in_winbar = {
      enable = false,
      separator = "＞",
    },
    lightbulb = {
      enable = false,
      sign = false,
    },
  })
end

local function setupStatusCol()
  require("wsain.plugin.configs.ui.statuscol").setForLspConfig()
end

local function enableAutoCmp()
  require("wsain.utils").toggle_auto_cmp(true)
end

-- lsp configs are lazy-loaded or can be triggered after LSP installation,
-- so we need a way to make LSP clients attached to already existing buffers.
local attach_lsp_to_existing_buffers = vim.schedule_wrap(function()
  -- this can be easily achieved by firing an autocmd event for the open buffers.
  -- See lspconfig.configs (config.autostart)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local valid = vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, "buflisted")
    if valid and vim.bo[bufnr].buftype == "" then
      local augroup_lspconfig = vim.api.nvim_create_augroup("lspconfig", { clear = false })
      vim.api.nvim_exec_autocmds("FileType", { group = augroup_lspconfig, buffer = bufnr })
    end
  end
end)

local function ensureDepLoaded()
  setupStatusCol()
  lsp_signature_setup()
  fidgetSetup()
  lspsagaSetup()
  troubleSetup()
  enableAutoCmp()
end

local function setupLspWrap(fun, auto_attach)
  if auto_attach == nil then
    auto_attach = true
  end
  return function()
    ensureDepLoaded()
    fun()
    if auto_attach then
      attach_lsp_to_existing_buffers()
    end
  end
end

local function setupLuaLsp()
  local lspconfig = require("lspconfig")
  local luadev = require("lua-dev")

  local util = require("lspconfig/util")

  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "?.lua")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")

  local command = "lua-language-server"

  local luadevConfig = luadev.setup({
    lspconfig = {
      cmd = { command },
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = runtime_path,
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = {
            enable = false,
          },
        },
      },
      on_attach = on_attach,
      on_init = on_init,
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 150,
      },
      root_dir = function(fname)
        return util.root_pattern(".git")(fname) or util.path.dirname(fname)
      end,
    },
  })

  lspconfig.lua_ls.setup(luadevConfig)
end

local function setupBashLsp()
  local lspconfig = require("lspconfig")
  lspconfig.bashls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

local function setupCLsp()
  local lspconfig = require("lspconfig")
  lspconfig.clangd.setup({
    -- https://zhuanlan.zhihu.com/p/84876003
    cmd = {
      "clangd",
      "--background-index",
      "-j=12",
      "--clang-tidy",
      "--all-scopes-completion",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--pch-storage=disk",
    },
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

local function setupGoLsp()
  local lspconfig = require("lspconfig")
  lspconfig.gopls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    root_dir = lspconfig.util.root_pattern("go.mod"),
  })
end

local function setupVimLsp()
  local lspconfig = require("lspconfig")
  lspconfig.vimls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

local function setupFrontEndLsp()
  local lspconfig = require("lspconfig")
  local servers = {
    tsserver = "typescript-language-server",
    cssls = "vscode-css-language-server",
    htmlls = "vscode-html-language-server",
    emmet = "emmet-ls",
  }

  -- html lsp
  lspconfig.html.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })

  -- eslint. eslint-lsp depends on eslint
  lspconfig.eslint.setup({
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
      "vue",
    },
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })

  -- css lsp
  lspconfig.cssls.setup({
    filetypes = { "css", "scss", "less" },
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })

  -- json lsp
  lspconfig.jsonls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })

  -- tsserver
  lspconfig.tsserver.setup({
    cmd = { servers.tsserver, "--stdio" },
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    init_options = {
      hostInfo = "neovim",
    },
  })

  -- vue
  lspconfig.vuels.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

local function setupPythonLsp()
  local lspconfig = require("lspconfig")
  lspconfig.pylsp.setup({
    on_attach = on_attach,
    root_dir = function(fname)
      return lspconfig.util.root_pattern(
        ".git",
        "setup.py",
        "setup.cfg",
        "pyproject.toml",
        "requirements.txt",
        "pyrightconfig.json"
      )(fname) or lspconfig.util.path.dirname(fname)
    end,
  })
end

local function setupPyright()
  local lspconfig = require("lspconfig")
  lspconfig.basedpyright.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    root_dir = function(fname)
      return lspconfig.util.root_pattern(
        ".git",
        "setup.py",
        "setup.cfg",
        "pyproject.toml",
        "requirements.txt",
        "pyrightconfig.json"
      )(fname) or lspconfig.util.path.dirname(fname)
    end,
    -- config document: https://github.com/microsoft/pyright/blob/main/docs/configuration.md
    settings = {
      basedpyright = {
        analysis = {
          diagnosticMode = "openFilesOnly",
          typeCheckingMode = "off",
          diagnosticSeverityOverrides = {
            reportGeneralTypeIssues = "none",
          },
          useLibraryCodeForTypes = true,
          autoImportCompletions = true,
        },
      },
    },
    single_file_support = true,
  })
end

local function setupJedi()
  local lspconfig = require("lspconfig")
  lspconfig.jedi_language_server.setup({
    on_attach = on_attach,
    root_dir = function(fname)
      return lspconfig.util.root_pattern(
        ".git",
        "setup.py",
        "setup.cfg",
        "pyproject.toml",
        "requirements.txt",
        "pyrightconfig.json"
      )(fname) or lspconfig.util.path.dirname(fname)
    end,
  })
end

local function setupPhpLsp()
  local lspconfig = require("lspconfig")
  lspconfig.intelephense.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

local function setupJavaLsp()
  -- https://github.com/bmihovski/dusk.nvim/blob/1e595a4/nvim/lua/pluginconfigs/jdtls.lua
  local java_cmds = vim.api.nvim_create_augroup("java_cmds", { clear = true })
  local cache_vars = {}

  local root_markers = {
    ".git",
    "mvnw",
    "gradlew",
    "pom.xml",
    "build.gradle",
  }

  local features = {
    -- change this to `true` to enable codelens
    codelens = false,

    -- change this to `true` if you have `nvim-dap`,
    -- `java-test` and `java-debug-adapter` installed
    debugger = true,
  }

  local function get_jdtls_paths()
    if cache_vars.paths then
      return cache_vars.paths
    end

    local path = {}

    path.workspace_dir = vim.fn.stdpath("cache") .. "/nvim-jdtls"

    local jdtls_install = require("mason-registry").get_package("jdtls"):get_install_path()

    path.lombok = jdtls_install .. "/lombok.jar"
    path.launcher_jar = vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher_*.jar")

    if vim.fn.has("mac") == 1 then
      path.platform_config = jdtls_install .. "/config_mac"
    elseif vim.fn.has("unix") == 1 then
      path.platform_config = jdtls_install .. "/config_linux"
    elseif vim.fn.has("win32") == 1 then
      path.platform_config = jdtls_install .. "/config_win"
    end

    path.bundles = {}

    ---
    -- Include java-test bundle if present
    ---
    local java_test_path = require("mason-registry").get_package("java-test"):get_install_path()

    local java_test_bundle = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n")

    if java_test_bundle[1] ~= "" then
      for _, bundle in ipairs(java_test_bundle) do
        --These two jars are not bundles, therefore don't put them in the table
        if
          not vim.endswith(bundle, "com.microsoft.java.test.runner-jar-with-dependencies.jar")
          and not vim.endswith(bundle, "com.microsoft.java.test.runner.jar")
        then
          if java_test_bundle[1] ~= "" then
            table.insert(path.bundles, bundle)
          end
        end
      end
      vim.list_extend(path.bundles, java_test_bundle)
    end

    ---
    -- Include java-debug-adapter bundle if present
    ---
    local java_debug_path = require("mason-registry").get_package("java-debug-adapter"):get_install_path()

    local java_debug_bundle =
      vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n")

    if java_debug_bundle[1] ~= "" then
      vim.list_extend(path.bundles, java_debug_bundle)
    end

    ---
    -- Useful if you're starting jdtls with a Java version that's
    -- different from the one the project uses.
    ---
    path.runtimes = {
      -- Note: the field `name` must be a valid `ExecutionEnvironment`,
      -- you can find the list here:
      -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
      --
      -- This example assume you are using sdkman: https://sdkman.io
      -- {
      --   name = 'JavaSE-17',
      --   path = vim.fn.expand('~/.sdkman/candidates/java/17.0.6-tem'),
      -- },
      -- {
      --   name = 'JavaSE-18',
      --   path = vim.fn.expand('~/.sdkman/candidates/java/18.0.2-amzn'),
      -- },
    }

    cache_vars.paths = path

    return path
  end

  local function enable_codelens(bufnr)
    local status_ok = pcall(vim.lsp.codelens.refresh)
    if not status_ok then
      return
    end

    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = bufnr,
      group = java_cmds,
      desc = "refresh codelens",
      callback = function()
        pcall(vim.lsp.codelens.refresh)
      end,
    })
  end

  local function enable_debugger(_bufnr)
    require("jdtls").setup_dap({ hotcodereplace = "auto" })
    require("jdtls.dap").setup_dap_main_class_configs()
  end

  local function add_jdtls_keymaps(bufnr)
    require("wsain.plugin.whichkey").register({
      { "<leader>cJ", group = "java", mode = "v" },
      {
        "<leader>cJv",
        "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
        desc = "Extract Variable",
        mode = "v",
        silent = true,
        noremap = true,
        buffer = bufnr,
      },
      {
        "<leader>cJc",
        "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
        desc = "Extract Constant",
        mode = "v",
        silent = true,
        noremap = true,
        buffer = bufnr,
      },
      {
        "<leader>cJm",
        "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
        desc = "Extract Method",
        mode = "v",
        silent = true,
        noremap = true,
        buffer = bufnr,
      },
    })
  end

  local function jdtls_on_attach(client, bufnr)
    local jdtls = require("jdtls")
    jdtls.setup.add_commands()
    add_jdtls_keymaps(bufnr)

    if features.codelens then
      enable_codelens(bufnr)
    end

    if features.debugger then
      enable_debugger(bufnr)
    end

    on_attach(client, bufnr)
  end

  local basic_capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
    },
  }

  local function jdtls_setup(_event)
    local jdtls = require("jdtls")

    local path = get_jdtls_paths()
    local workspace_dir = path.workspace_dir .. "/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

    local project_root_dir = require("jdtls.setup").find_root(root_markers)

    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    local cmd = {
      -- 💀
      "java",

      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-javaagent:" .. path.lombok,
      "--add-modules=ALL-SYSTEM",
      "--add-opens",
      "java.base/java.util=ALL-UNNAMED",
      "--add-opens",
      "java.base/java.lang=ALL-UNNAMED",

      -- 💀
      "-jar",
      path.launcher_jar,

      -- 💀
      "-configuration",
      path.platform_config,

      -- 💀
      "-data",
      workspace_dir,
    }

    local lsp_settings = {
      java = {
        -- jdt = {
        --   ls = {
        --     vmargs = "-XX:+UseParallelGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx4G -Xms256m"
        --   }
        -- },
        eclipse = {
          downloadSources = true,
        },
        configuration = {
          updateBuildConfiguration = "interactive",
          runtimes = path.runtimes,
        },
        maven = {
          downloadSources = true,
        },
        implementationsCodeLens = {
          enabled = true,
        },
        signatureHelp = { enabled = true },
        referencesCodeLens = {
          enabled = true,
        },
        -- inlayHints = {
        --   parameterNames = {
        --     enabled = 'all' -- literals, all, none
        --   }
        -- },
        format = {
          enabled = true,
          -- settings = {
          --   profile = 'asdf'
          -- },
        },
      },
      signatureHelp = {
        enabled = true,
      },
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
      },
      contentProvider = {
        preferred = "fernflower",
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
    }

    local jdtls_on_init = function(client, _)
      client.notify("workspace/didChangeConfiguration", { settings = lsp_settings })
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        local valid = vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, "buflisted")
        if valid and vim.bo[bufnr].buftype == "" and vim.bo[bufnr].filetype == "java" then
          vim.lsp.buf_attach_client(bufnr, client.id)
        end
      end

      require("jdtls.dap").setup_dap_main_class_configs({ verbose = true })
    end

    local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
    extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

    -- This starts a new client & server,
    -- or attaches to an existing client & server depending on the `root_dir`.
    jdtls.start_or_attach({
      cmd = cmd,
      settings = lsp_settings,
      on_init = jdtls_on_init,
      on_attach = jdtls_on_attach,
      capabilities = basic_capabilities,
      root_dir = project_root_dir,
      flags = {
        allow_incremental_sync = true,
      },
      init_options = {
        bundles = path.bundles,
        extendedClientCapabilities = extendedClientCapabilities,
      },
    })
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = java_cmds,
    pattern = { "java" },
    desc = "Setup jdtls",
    callback = jdtls_setup,
  })

  vim.api.nvim_exec_autocmds("FileType", { group = java_cmds, buffer = 0 })
end

local function setupNixLsp()
  local lspconfig = require("lspconfig")
  lspconfig.nil_ls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

local function selectLSP()
  local lspconfig_map = {
    lua = setupLspWrap(setupLuaLsp),
    bash = setupLspWrap(setupBashLsp),
    ["c/cpp"] = setupLspWrap(setupCLsp),
    go = setupLspWrap(setupGoLsp),
    vim = setupLspWrap(setupVimLsp),
    frontend = setupLspWrap(setupFrontEndLsp),
    pylsp = setupLspWrap(setupPythonLsp),
    basedpyright = setupLspWrap(setupPyright),
    jedi = setupLspWrap(setupJedi),
    php = setupLspWrap(setupPhpLsp),
    java = setupLspWrap(setupJavaLsp, false),
    nix = setupLspWrap(setupNixLsp),
  }

  local n = 1
  local langs = {}
  for k, _ in pairs(lspconfig_map) do
    langs[n] = k
    n = n + 1
  end

  vim.ui.select(langs, { prompt = "select lsp" }, function(choice)
    if lspconfig_map[choice] == nil then
      vim.notify("unknown lang")
      return
    end
    lspconfig_map[choice]()
  end)
end

plugin.config = function()
  -- diagnostic config
  vim.diagnostic.config({
    float = {
      header = "",
      border = "single",
    },
  })
  -- diagnostic sign config
  local signs = { Error = "", Warn = "", Hint = "", Info = "" }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- lsp handler
  -- help vim.lsp.util.open_floating_preview() and according to the lua source code
  local lsp = vim.lsp
  -- Global handlers.
  lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, {
    border = "single",
    offset_x = 1,
    max_width = 100,
    max_height = 20,
  })

  lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, {
    border = "single",
    max_width = 100,
    max_height = 20,
  })

  -- enable semantic_tokens and under_line will gray out unused variable
  lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
    underline = false,
    update_in_insert = false,
    -- virtual_text = { spacing = 4, prefix = "\u{ea71}" },
    virtual_text = false,
    severity_sort = true,
    float = {
      header = "",
      border = "single",
    },
  })

  require("wsain.plugin.whichkey").register({
    { "<leader>c", group = "code" },
    { "<leader>c", group = "code", mode = "v" },
    { "<leader>cf", ":Format<cr>", desc = "format" },
    { "<leader>cf", ":Format<cr>", desc = "format", mode = "v" },
    { "<leader>cS", selectLSP, desc = "lsp server" },
  })
end

return plugin
