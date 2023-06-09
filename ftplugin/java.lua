local lsat = require('mahdiMonza.configs.lsp_attach')
local jdtls = require('jdtls')
local mpkg = '/mason/packages/'
local jdtls_dir = vim.fn.stdpath('data') .. mpkg .. 'jdtls'
local jdebug_dir = vim.fn.stdpath('data') .. mpkg .. 'java-debug-adapter'
local jtest_dir = vim.fn.stdpath('data') .. mpkg .. 'java-test'
local ext_ser = '/extension/server/'
local config_dir = jdtls_dir .. '/config_linux'
local plugins_dir = jdtls_dir .. '/plugins/'
local path_to_jar = plugins_dir .. 'org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar'

local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require('jdtls.setup').find_root(root_markers)
if root_dir == "" then
  return
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/site/java/workspace-root/' .. project_name
local bundle = {
  vim.fn.glob(jdebug_dir .. ext_ser .. 'com.microsoft.java.debug.plugin-*.jar', true),
}
vim.list_extend(bundle, vim.split(vim.fn.glob(jtest_dir .. ext_ser .. '*.jar', true), "\n"))
-- os.execute("mkdir " .. workspace_dir)

local extendedClientCapabilities = jdtls.extendedClientCapabilities;
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true;

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  --[[require('lsp_signature').on_attach({
        bind = true,
        padding = '',
        handler_opts = { border = 'rounded' },
        bufnrs
      }) ]]
  -- Remap keys for LSP diagnostics
  lsat.on_attach(client, bufnr)

  local function arginp()
    return coroutine.create(function(dap_run_co)
      vim.ui.input({ prompt = 'Args: ' }, function(argstr)
        coroutine.resume(dap_run_co, argstr)
      end)
    end)
  end

  lsat.maps('n', '<leader>oi', jdtls.organize_imports, 'Organize Imports', bufnr)
  lsat.maps('n', '<leader>xv', jdtls.extract_variable, 'Extract Variable', bufnr)
  lsat.maps('v', '<leader>xv', function() jdtls.extract_variable(true) end, 'Extract Variable', bufnr)
  lsat.maps('n', '<leader>xc', jdtls.extract_constant, 'Extract Constant', bufnr)
  lsat.maps('v', '<leader>xc', function() jdtls.extract_constant(true) end, 'Extract Constant', bufnr)
  lsat.maps('v', '<leader>xm', function() jdtls.extract_method(true) end, 'Extract Method', bufnr)
  lsat.maps('n', '<leader>dm', function()
    require('jdtls.dap').setup_dap_main_class_configs({
      config_overrides = {
        args = arginp,
        stepFilters = {
          skipClasses = { 'java.lang.ClassLoader' }
        },
      }
    }, 'Setup DAP Main Class Configs', bufnr)
  end
  , 'Debug Main Setup')
  lsat.maps('n', '<leader>dtc', jdtls.test_class, 'Debug Test Class', bufnr)
  lsat.maps('n', '<leader>dtm', jdtls.test_nearest_method, 'Debug Test Method', bufnr)

  jdtls.setup_dap({ hotcodereplace = 'auto' })
  require('jdtls.dap').setup_dap_main_class_configs({
    config_overrides = {
      args = arginp,
      stepFilters = {
        skipClasses = { 'java.lang.ClassLoader' }
      },
    }
  })                                    -- discover main class
  require('jdtls.setup').add_commands() -- not related to debugging but you probably want this
  -- vim.nvim_create_user_command({
  --   bang = true,
  --   buffer = true,
  --   name = 'JdtCustomDebugConfigs',
  --   command =   })
end

-- Main Config
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {

    'java', -- or '/path/to/java17_or_newer/bin/java'

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

    '-jar', path_to_jar,
    '-configuration', config_dir,
    '-data', workspace_dir,
  },
  root_dir = root_dir,
  capabilities = lsat.capabilities,
  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      home = os.getenv('JAVA_HOME'),
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-17",
            path = os.getenv('JAVA_HOME'),
          }
        },
        maven = { downloadSources = true },
        implementationCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        references = { includeDecompiledSources = true },
        format = {
          enabled = true,
          settigns = {
            url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
            profile = "GoogleStyle"
          },
        }
      },
      signatureHelp = { enabled = true },
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
        importOrder = { "java", "javax", "com", "org" },
      },
      extendedClientCapabilities = extendedClientCapabilities,
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
    },

    flags = {
      allow_incremental_sync = true,
    },
    -- Language server `initializationOptions`
    -- You need to extend the `bundles` with paths to jar files
    -- if you want to use additional eclipse.jdt.ls plugins.
    --
    -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
    -- TODO: find some way to not repeat myself
    -- on_attach = on_attach,
  },
}
config['init_options'] = {
  bundles = bundle,
}
config['on_attach'] = on_attach

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach(config)
require('fidget').setup()
