# Convenience targets for the dotfiles repo. Mirrors what CI runs.

SHELL_SCRIPTS := install.sh \
                 scripts/install_nvim.sh \
                 scripts/install_rust_tools.sh \
                 scripts/install_zsh_plugins.sh \
                 scripts/install_karabiner_rules.sh \
                 scripts/karabiner-prefix-indicator.sh \
                 scripts/lib.sh \
                 scripts/bootstrap-debian.sh \
                 scripts/bootstrap-mac.sh

.PHONY: lint smoke install install-minimal

lint: ## Run shellcheck on all bash scripts (same as CI)
	shellcheck -x --severity=warning $(SHELL_SCRIPTS)

smoke: ## Build the Debian smoke image and run install.sh (minimal) in it
	docker run --rm -v "$(CURDIR)":/dotfiles -w /dotfiles \
		-e DEBIAN_FRONTEND=noninteractive -e DOTFILES_MINIMAL=1 \
		debian:12 bash install.sh

install: ## Full install on this machine
	bash install.sh

install-minimal: ## Stow configs only, skip toolchain + fonts
	DOTFILES_MINIMAL=1 bash install.sh
