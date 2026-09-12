#!/usr/bin/env bash
# Version managers that are not available from a package manager.
set -euo pipefail

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
curl -fsSL https://fvm.app/install.sh | bash
