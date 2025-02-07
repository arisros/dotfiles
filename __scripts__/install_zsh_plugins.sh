OS="$(uname -s)"

install_mac() {
    echo "🛠 Installing Zsh plugins on macOS..."
    brew install zsh-syntax-highlighting zsh-autosuggestions fzf
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
}

install_linux() {
    echo "🛠 Installing Zsh plugins on Linux..."
    sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting
    sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/zsh-autosuggestions
    sudo apt install -y fzf  # Debian/Ubuntu
}

# Run the correct installer
if [[ "$OS" == "Darwin" ]]; then
    install_mac  # macOS (Darwin)
elif [[ "$OS" == "Linux" ]]; then
    install_linux  # Linux
else
    echo "❌ Unsupported OS: $OS"
    exit 1
fi

echo "✅ Zsh plugins installed!"


