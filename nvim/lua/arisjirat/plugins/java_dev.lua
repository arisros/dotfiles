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

		local function java_home_candidates()
			local candidates = {}
			-- mise names installs <vendor>-<version>, never "21", and `mise where`
			-- additionally honours a per-project pin, so it goes first.
			if vim.fn.executable("mise") == 1 then
				local mise_home = trim(vim.fn.system({ "mise", "where", "java" }))
				if vim.v.shell_error == 0 and mise_home ~= "" then
					table.insert(candidates, mise_home)
				end
			end
			if vim.env.JAVA_HOME ~= nil and vim.env.JAVA_HOME ~= "" then
				table.insert(candidates, vim.env.JAVA_HOME)
			end
			local globs = {
				"/usr/lib/jvm/*",
				"/opt/homebrew/opt/openjdk*/libexec/openjdk.jdk/Contents/Home",
				"/Library/Java/JavaVirtualMachines/*/Contents/Home",
				"~/.sdkman/candidates/java/*",
				"~/.local/share/mise/installs/java/*",
			}
			for _, pattern in ipairs(globs) do
				vim.list_extend(candidates, vim.fn.glob(vim.fs.normalize(pattern), true, true))
			end
			return candidates
		end

		local function find_java_home(min_major)
			for _, path in ipairs(java_home_candidates()) do
				if vim.fn.isdirectory(path) == 1 then
					local major = java_major(path)
					if major ~= nil and major >= min_major then
						return path, major
					end
				end
			end
			return nil
		end

		local project_home, project_major = find_java_home(21)
		if project_home == nil then
			vim.notify("Java 21+ is required for jdtls. Install Java 21 and set JAVA_HOME.", vim.log.levels.WARN)
			return
		end

		-- jdtls itself needs Java 25 since 1.5x; the project keeps compiling against project_home.
		local server_home = find_java_home(25)
		if server_home == nil then
			vim.notify("jdtls needs Java 25+ to run (mise install java@temurin-25).", vim.log.levels.WARN)
			server_home = project_home
		end

		vim.env.JAVA_HOME = project_home
		local java_bin_dir = project_home .. "/bin"
		if not vim.env.PATH:find(vim.pesc(java_bin_dir), 1, false) then
			vim.env.PATH = java_bin_dir .. ":" .. vim.env.PATH
		end

		local root_markers = {
			"mvnw",
			"gradlew",
			"pom.xml",
			"build.gradle",
			"build.gradle.kts",
			".git",
		}

		local jdtls_cmd = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
		if vim.fn.executable(jdtls_cmd) == 0 then
			jdtls_cmd = "jdtls"
		end

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local blink_ok, blink = pcall(require, "blink.cmp")
		if blink_ok then
			capabilities = blink.get_lsp_capabilities(capabilities)
		end

		local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
		local bundles = vim.fn.glob(
			mason_packages .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
			true,
			true
		)
		-- the runner and jacoco jars are launched by java-test itself, loading them as bundles breaks jdtls
		local test_excluded = {
			["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
			["jacocoagent.jar"] = true,
		}
		for _, jar in ipairs(vim.fn.glob(mason_packages .. "/java-test/extension/server/*.jar", true, true)) do
			if not test_excluded[vim.fn.fnamemodify(jar, ":t")] then
				table.insert(bundles, jar)
			end
		end

		local function on_attach(_, bufnr)
			local function map(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
			end
			map("<leader>Jt", jdtls.test_nearest_method, "Java: test nearest method")
			map("<leader>JT", jdtls.test_class, "Java: test class")
			map("<leader>Jp", jdtls.pick_test, "Java: pick test")
			map("<leader>Jo", jdtls.organize_imports, "Java: organize imports")
		end

		local function start()
			local root_dir = vim.fs.root(0, root_markers) or vim.fn.getcwd()
			local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root_dir, ":t")

			jdtls.start_or_attach({
				cmd = { jdtls_cmd, "--java-executable", server_home .. "/bin/java", "-data", workspace_dir },
				root_dir = root_dir,
				capabilities = capabilities,
				on_attach = on_attach,
				dap = { hotcodereplace = "auto" },
				settings = {
					java = {
						configuration = {
							runtimes = {
								{ name = "JavaSE-" .. project_major, path = project_home, default = true },
							},
						},
						references = {
							includeDecompiledSources = true,
						},
						maven = {
							downloadSources = true,
						},
					},
				},
				init_options = {
					bundles = bundles,
				},
			})
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("arisjirat_jdtls", { clear = true }),
			pattern = "java",
			callback = start,
		})
		start()
	end,
}
