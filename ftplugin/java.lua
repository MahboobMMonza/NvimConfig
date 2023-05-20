-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local jdtls = require('jdtls')
local mpkg = '/mason/packages/'
local jdtls_dir = vim.fn.stdpath('data') .. mpkg .. 'jdtls'
local jdebug_dir = vim.fn.stdpath('data') .. mpkg .. 'java-debug-adapter'
local jtest_dir = vim.fn.stdpath('data') .. mpkg .. 'java-test'
local extser = '/extension/server/'
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
  vim.fn.glob(jdebug_dir .. extser .. 'com.microsoft.java.debug.plugin-*.jar', true),
}
vim.list_extend(bundle, vim.split(vim.fn.glob(jtest_dir .. extser .. '*.jar', true), "\n"))
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
  local function momap(mode, keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc, noremap = true })
  end

  local function arginp()
    return coroutine.create(function(dap_run_co)
      vim.ui.input({ prompt = 'Args: ' }, function(argstr)
        coroutine.resume(dap_run_co, argstr)
      end)
    end)
  end

  momap('n', '<leader>rn', vim.lsp.buf.rename, 'Rename')
  momap('n', '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
  momap('n', '<leader>oi', "<Cmd>lua require('jdtls').organize_imports()<cr>", 'Organize Imports')
  momap('n', '<leader>xv', "<Cmd>lua require('jdtls').extract_variable()<cr>", 'Extract Variable')
  momap('v', '<leader>xv', "<Esc><Cmd>lua require('jdtls').extract_variable(true)<cr>", 'Extract Variable')
  momap('n', '<leader>xc', "<Cmd>lua require('jdtls').extract_constant()<cr>", 'Extract Constant')
  momap('v', '<leader>xc', "<Esc><Cmd>lua require('jdtls').extract_constant(true)<cr>", 'Extract Constant')
  momap('v', '<leader>xm', "<Esc><Cmd>lua require('jdtls').extract_method(true)<cr>", 'Extract Method')
  momap('x', '<leader>ca', ':<C-u>lua vim.lsp.buf.range_code_action()<cr>', 'Ranged Code Action')
  momap('n', 'gd', vim.lsp.buf.definition, 'Goto Definition')
  momap('n', '<leader>gr', require('telescope.builtin').lsp_references, 'Goto References')
  momap('n', '<leader>gI', vim.lsp.buf.implementation, 'Goto Implementation')
  momap('n', '<leader>D', vim.lsp.buf.type_definition, 'Type Definition')
  momap('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
  momap('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')
  momap('n', '<leader>dm', function()
    require('jdtls.dap').setup_dap_main_class_configs({
      config_overrides = {
        args = arginp,
        stepFilters = {
          skipClasses = { 'java.lang.ClassLoader' }
        },
      }
    })
  end
  , 'Debug Main Setup')
  momap('n', '<leader>dtc', require('jdtls').test_class, 'Debug Test Class')
  momap('n', '<leader>dtm', require('jdtls').test_nearest_method, 'Debug Test Method')

  -- See `:help K` for why this keymap
  momap('n', 'K', vim.lsp.buf.hover, 'Hover Documentation')
  momap('n', '<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  momap('n', 'gD', vim.lsp.buf.declaration, 'Goto Declaration')
  momap('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, 'Workspace Add Folder')
  momap('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Workspace Remove Folder')
  momap('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, 'Workspace List Folders')

  -- Create a motion ` fmt` local to the LSP buffer
  momap('n', '<leader>fmt', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, 'Format current buffer')
  require('jdtls').setup_dap({ hotcodereplace = 'auto' })
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
  capabilities = capabilities,
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
require('jdtls').start_or_attach(config)
require('fidget').setup()
