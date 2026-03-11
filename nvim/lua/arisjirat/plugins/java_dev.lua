return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	dependencies = {
		"williamboman/mason.nvim",
		"neovim/nvim-lspconfig",
	},
	config = function()
		local ok, jdtls = pcall(require, "jdtls")
		if not ok then
			return
		end

		local function trim(s)
			return (s:gsub("^%s+", ""):gsub("%s+$", ""))
		end

		local function java_major(java_home)
			local java_bin = java_home .. "/bin/java"
			if vim.fn.executable(java_bin) == 0 then
				return nil
			end
			local out = vim.fn.system({ java_bin, "-version" })
			local version = out:match('version%s+"(%d+)')
			if version == nil then
				version = out:match('version%s+"1%.(%d+)')
			end
			if version == nil then
				return nil
			end
			return tonumber(version)
		end

		local function find_java_21_home()
			local brew_java_21 = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
			if vim.fn.isdirectory(brew_java_21) == 1 then
				local major = java_major(brew_java_21)
				if major ~= nil and major >= 21 then
					return brew_java_21
				end
			end

			if vim.fn.executable("/usr/libexec/java_home") == 1 then
				local out = trim(vim.fn.system("/usr/libexec/java_home -v 21 2>/dev/null"))
				if out ~= "" and vim.fn.isdirectory(out) == 1 then
					return out
				end
			end

			local sdkman_current = vim.fn.expand("~/.sdkman/candidates/java/current")
			if vim.fn.isdirectory(sdkman_current) == 1 then
				local major = java_major(sdkman_current)
				if major ~= nil and major >= 21 then
					return sdkman_current
				end
			end

			local env_java_home = vim.env.JAVA_HOME
			if env_java_home ~= nil and env_java_home ~= "" and vim.fn.isdirectory(env_java_home) == 1 then
				local major = java_major(env_java_home)
				if major ~= nil and major >= 21 then
					return env_java_home
				end
			end

			return nil
		end

		local java_home = find_java_21_home()
		if java_home == nil then
			vim.notify("Java 21+ is required for jdtls. Install Java 21 and set JAVA_HOME.", vim.log.levels.WARN)
			return
		end

		vim.env.JAVA_HOME = java_home
		local java_bin_dir = java_home .. "/bin"
		if not vim.env.PATH:find(vim.pesc(java_bin_dir), 1, false) then
			vim.env.PATH = java_bin_dir .. ":" .. vim.env.PATH
		end

		local root_markers = {
			".git",
			"mvnw",
			"gradlew",
			"pom.xml",
			"build.gradle",
			"build.gradle.kts",
		}
		local root_dir = require("jdtls.setup").find_root(root_markers)
		if root_dir == nil or root_dir == "" then
			root_dir = vim.fn.getcwd()
		end

		local project_name = vim.fn.fnamemodify(root_dir, ":p:t")
		local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name
		local jdtls_cmd = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
		if vim.fn.executable(jdtls_cmd) == 0 then
			jdtls_cmd = "jdtls"
		end

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
		if cmp_ok then
			capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
		end

		local config = {
			cmd = { jdtls_cmd, "-data", workspace_dir },
			root_dir = root_dir,
			capabilities = capabilities,
			settings = {
				java = {
					references = {
						includeDecompiledSources = true,
					},
					maven = {
						downloadSources = true,
					},
				},
			},
			init_options = {
				bundles = {},
			},
		}

		jdtls.start_or_attach(config)
	end,
}
