local lsat = require("mahdiMonza.configs.lsp_attach")
local jdtls = require("jdtls")
local dap_configs = require("mahdiMonza.configs.dap_configs")

-- Mason 2.x layout:
--   <data>/mason/packages/<pkg>  installed files
--   <data>/mason/share/<pkg>      shared files (config, plugins, jars)
--   <data>/mason/bin              executables (also added to $PATH)
local mason_root = vim.fn.stdpath("data") .. "/mason"

local function first_glob(pattern)
  return vim.fn.glob(pattern, true, true)[1]
end

local function mason_jars(pkg)
  local jars = {}
  for _, pattern in ipairs({
    vim.fs.joinpath(mason_root, "share", pkg, "*.jar"),
    vim.fs.joinpath(
      mason_root,
      "packages",
      pkg,
      "extension",
      "server",
      "*.jar"
    ),
  }) do
    vim.list_extend(jars, vim.fn.glob(pattern, true, true))
  end
  return jars
end

-- Only offer the JVMs that are actually installed.
local runtimes = {}
local jvm_candidates = {}
if vim.env.JAVA_HOME then
  table.insert(jvm_candidates, vim.env.JAVA_HOME)
elseif vim.fn.has("mac") == 1 then
  for _, dir in
    ipairs(
      vim.fn.glob(
        "/Library/Java/JavaVirtualMachines/*/Contents/Home",
        true,
        true
      )
    )
  do
    table.insert(jvm_candidates, dir)
  end
else
  for _, dir in ipairs(vim.fn.glob("/usr/lib/jvm/java-*-openjdk", true, true)) do
    table.insert(jvm_candidates, dir)
  end
end
for _, path in ipairs(jvm_candidates) do
  if vim.fn.isdirectory(path) == 1 then
    local version = nil
    local release = vim.fn.readfile(vim.fs.joinpath(path, "release"), "", 20)
    for _, line in ipairs(release or {}) do
      local v = line:match('JAVA_VERSION="([^"]+)"')
      if v then
        version = v:match("^(%d+)")
        break
      end
    end
    table.insert(
      runtimes,
      { name = "JavaSE-" .. (version or "?"), path = path }
    )
  end
end

local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
  return
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data")
  .. "/site/java/workspace-root/"
  .. project_name

-- Bundles for the java debugger and the java test runner.
local bundle = {}
for _, jar in ipairs(mason_jars("java-debug-adapter")) do
  if jar:match("com%.microsoft%.java%.debug%.plugin") then
    table.insert(bundle, jar)
  end
end
for _, jar in ipairs(mason_jars("java-test")) do
  table.insert(bundle, jar)
end

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local on_attach = function(_, bufnr)
  lsat.maps(
    "n",
    "<leader>oi",
    jdtls.organize_imports,
    "Organize Imports",
    bufnr
  )
  lsat.maps(
    "n",
    "<leader>xv",
    jdtls.extract_variable,
    "Extract Variable",
    bufnr
  )
  lsat.maps("v", "<leader>xv", function()
    jdtls.extract_variable({ visual = true })
  end, "Extract Variable", bufnr)
  lsat.maps(
    "n",
    "<leader>xc",
    jdtls.extract_constant,
    "Extract Constant",
    bufnr
  )
  lsat.maps("v", "<leader>xc", function()
    jdtls.extract_constant({ visual = true })
  end, "Extract Constant", bufnr)
  lsat.maps("v", "<leader>xm", function()
    jdtls.extract_method({ visual = true })
  end, "Extract Method", bufnr)
  lsat.maps("n", "<leader>dtc", jdtls.test_class, "Debug Test Class", bufnr)
  lsat.maps(
    "n",
    "<leader>dtm",
    jdtls.test_nearest_method,
    "Debug Test Method",
    bufnr
  )

  jdtls.setup_dap({ hotcodereplace = "auto" })
  require("jdtls.dap").setup_dap_main_class_configs({
    config_overrides = {
      -- A fresh coroutine per session, so the prompt works every time.
      args = dap_configs.arginp("Args: "),
      stepFilters = {
        skipClasses = { "java.lang.ClassLoader" },
      },
    },
  })
end

-- The launcher that Mason installs handles the platform specific
-- configuration and plugin directories, so prefer it over a hand written
-- `java -jar ...` command.
local launcher = vim.fn.exepath("jdtls")
if launcher == "" then
  launcher = vim.fs.joinpath(mason_root, "bin", "jdtls")
end

local cmd
if vim.fn.executable(launcher) == 1 then
  cmd = { launcher, "-data", workspace_dir }
else
  local path_to_jar = first_glob(
    vim.fs.joinpath(
      mason_root,
      "share",
      "jdtls",
      "plugins",
      "org.eclipse.equinox.launcher_*.jar"
    )
  ) or first_glob(
    vim.fs.joinpath(
      mason_root,
      "packages",
      "jdtls",
      "plugins",
      "org.eclipse.equinox.launcher_*.jar"
    )
  )
  local config_dir = first_glob(
    vim.fs.joinpath(mason_root, "share", "jdtls", "config")
  ) or vim.fs.joinpath(
    mason_root,
    "packages",
    "jdtls",
    (
      vim.fn.has("mac") == 1 and "config_mac"
      or (vim.fn.has("win32") == 1 and "config_win" or "config_linux")
    )
  )
  if not path_to_jar then
    vim.notify(
      "jdtls is not installed. Run :MasonInstall jdtls",
      vim.log.levels.WARN
    )
    return
  end
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    path_to_jar,
    "-configuration",
    config_dir,
    "-data",
    workspace_dir,
  }
end

local config = {
  cmd = cmd,
  root_dir = root_dir,
  capabilities = lsat.capabilities(),
  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = runtimes,
        maven = { downloadSources = true },
        implementationCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        references = { includeDecompiledSources = true },
        format = {
          enabled = true,
          settings = {
            url = vim.fn.stdpath("config")
              .. "/lang_servers/intellij-java-google-style.xml",
            profile = "GoogleStyle",
          },
        },
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
  },
  init_options = {
    bundles = bundle,
  },
  on_attach = on_attach,
}

jdtls.start_or_attach(config)
