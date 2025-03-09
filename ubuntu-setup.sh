#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root (use sudo)." 
   exit 1
fi

USER_HOME=$(eval echo ~$SUDO_USER)

echo "Updating and upgrading packages..."
apt update && apt upgrade -y

echo "Installing essential packages..."
apt install -y \
    curl \
    git \
    zsh \
    wget \
    unzip \
    build-essential \
    software-properties-common \
    fzf \
    python3 \
    python3-pip \
    vim

echo "Installing Docker..."
apt install -y docker.io
usermod -aG docker $SUDO_USER
echo "Docker installed. You may need to log out and back in for group changes to apply."

if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sudo -u $SUDO_USER sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    chsh -s $(which zsh) $SUDO_USER
else
    echo "Oh My Zsh already installed."
fi

if [ ! -d "$USER_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo "Installing Zsh Autosuggestions..."
    sudo -u $SUDO_USER git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$USER_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi

echo "Setting up Passion theme..."
sudo -u $SUDO_USER wget -O "$USER_HOME/.oh-my-zsh/themes/passion.zsh-theme" \
    https://raw.githubusercontent.com/ChesterYue/ohmyzsh-theme-passion/master/passion.zsh-theme

echo "Configuring Zsh..."
sudo -u $SUDO_USER tee "$USER_HOME/.zshrc" > /dev/null <<EOF
export ZSH="$USER_HOME/.oh-my-zsh"
ZSH_THEME="passion"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source \$ZSH/oh-my-zsh.sh
EOF

echo "Setting up Git..."
read -p "Enter your Git name: " git_name
read -p "Enter your Git email: " git_email

sudo -u $SUDO_USER git config --global user.name "$git_name"
sudo -u $SUDO_USER git config --global user.email "$git_email"
sudo -u $SUDO_USER git config --global core.editor "vim"

if [ ! -f "$USER_HOME/.ssh/id_rsa" ]; then
    echo "Generating SSH key..."
    sudo -u $SUDO_USER ssh-keygen -t rsa -b 4096 -C "$git_email" -f "$USER_HOME/.ssh/id_rsa" -N ""
    echo "Your public key (add this to GitHub/GitLab):"
    cat "$USER_HOME/.ssh/id_rsa.pub"
fi

echo "Setup complete! Restart your terminal and enjoy your new setup. 🚀"