-- return {
-- 	"mfussenegger/nvim-jdtls",
-- 	ft = { "java" },
-- 	config = function()
-- 		local jdtls = require("jdtls")
-- 		local home = os.getenv("HOME")
-- 		local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
-- 		local workspace_dir = home .. "/.local/share/eclipse/" .. project_name
--
-- 		-- Use mise-managed Java
-- 		local java_home = vim.fn.trim(vim.fn.system("mise which java | xargs dirname | xargs dirname"))
--
-- 		-- Root detection
-- 		local root_markers = { "pom.xml", ".git", "build.gradle", "gradlew" }
-- 		local root_dir = require("jdtls.setup").find_root(root_markers)
-- 		if root_dir == nil then
-- 			return
-- 		end
--
-- 		local config = {
-- 			cmd = {
-- 				java_home .. "/bin/java",
-- 				"-Declipse.application=org.eclipse.jdt.ls.core.id1",
-- 				"-Dosgi.bundles.defaultStartLevel=4",
-- 				"-Declipse.product=org.eclipse.jdt.ls.core.product",
-- 				"-Dlog.protocol=true",
-- 				"-Dlog.level=ALL",
-- 				"-Xms1g",
-- 				"--add-modules=ALL-SYSTEM",
-- 				"--add-opens",
-- 				"java.base/java.util=ALL-UNNAMED",
-- 				"--add-opens",
-- 				"java.base/java.lang=ALL-UNNAMED",
-- 				"-jar",
-- 				vim.fn.glob(
-- 					vim.fn.stdpath("data") .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"
-- 				),
-- 				"-configuration",
-- 				vim.fn.stdpath("data") .. "/mason/packages/jdtls/config_mac",
-- 				"-data",
-- 				workspace_dir,
-- 			},
--
-- 			root_dir = root_dir,
--
-- 			settings = {
-- 				java = {
-- 					configuration = {
-- 						runtimes = {
-- 							{
-- 								name = "JavaSE-17",
-- 								path = java_home,
-- 							},
-- 						},
-- 					},
-- 				},
-- 			},
--
-- 			init_options = {
-- 				bundles = {},
-- 			},
-- 		}
--
-- 		vim.api.nvim_create_autocmd("FileType", {
-- 			pattern = "java",
-- 			callback = function()
-- 				jdtls.start_or_attach(config)
-- 			end,
-- 		})
-- 	end,
-- }
--
return {
	"nvim-java/nvim-java",
	dependencies = {
		"nvim-java/lua-async-await",
		"nvim-java/nvim-java-core",
		"nvim-java/nvim-java-test",
		"nvim-java/nvim-java-dap",
		"mfussenegger/nvim-jdtls",
		"neovim/nvim-lspconfig",
	},
	ft = { "java" },
	config = function()
		local java_opts = {
			root_markers = {
				"settings.gradle",
				"settings.gradle.kts",
				"pom.xml",
				"build.gradle",
				"mvnw",
				"gradlew",
				"build.gradle.kts",
			},
			jdk = {
				auto_install = false,
				home = "/Users/justtest/.local/share/mise/installs/java/temurin-21.0.6+7.0.LTS",
			},
			java_debug_adapter = {
				enable = true, -- set false if you don't want DAP
			},
		}

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = function()
				require("java").setup(java_opts)
			end,
		})
	end,
}
--
-- return {
-- 	"nvim-java/nvim-java",
-- 	config = false,
-- 	dependencies = {
-- 		{
-- 			"neovim/nvim-lspconfig",
-- 			opts = {
-- 				servers = {
-- 					jdtls = {
-- 						-- Your custom jdtls settings goes here
-- 					},
-- 				},
-- 				setup = {
-- 					jdtls = function()
-- 						require("java").setup({
-- 							-- Your custom nvim-java configuration goes here
-- 						})
-- 					end,
-- 				},
-- 			},
-- 		},
-- 	},
-- }
