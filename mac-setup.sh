#!/bin/bash

# Check if Homebrew is installed, install if not
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Updating Homebrew..."
    brew update
fi

formulae=(
    bat
    awscli
    azcopy
    azure-cli
    gh
    helm
    htop
    jq
    kubent
    mailsy
    terraform
    terragrunt
    tldr
    wget
    watch
)

brew install "${formulae[@]}"

casks=(
    1password-cli
    docker
    devtoys
    discord
    figma
    google-chrome
    firefox
    hyper
    visual-studio-code
    zed
    lm-studio
)

brew install --cask "${casks[@]}"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed"
fi

if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"
if [[ ! -f "$THEME_DIR/passion.zsh-theme" ]]; then
    echo "Installing Passion theme..."
    mkdir -p "$THEME_DIR"
    curl -fsSL "https://raw.githubusercontent.com/ChesterYue/ohmyzsh-theme-passion/master/passion.zsh-theme" -o "$THEME_DIR/passion.zsh-theme"
fi

ZSHRC="$HOME/.zshrc"

echo "Configuring fresh .zshrc..."
cat > "$ZSHRC" <<EOL
export ZSH="\$HOME/.oh-my-zsh"

ZSH_THEME="passion"

plugins=(git zsh-autosuggestions)

source \$ZSH/oh-my-zsh.sh

# Enable autosuggestions color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan"

# Aliases
alias ll="ls -lah"
alias gs="git status"
alias vsc="code ."

# Load custom scripts (if any)
[[ -f ~/.zsh_custom ]] && source ~/.zsh_custom
EOL

chmod 644 "$ZSHRC"

if [[ $SHELL != "/bin/zsh" ]]; then
    echo "Changing default shell to Zsh..."
    chsh -s /bin/zsh
fi

echo "Setup complete! Restart your terminal or run 'exec zsh' to apply changes."