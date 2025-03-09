#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root (use sudo)." 
   exit 1
fi

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
usermod -aG docker $USER
newgrp docker

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    chsh -s $(which zsh)
else
    echo "Oh My Zsh already installed."
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing Zsh Autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

echo "Setting up Passion theme..."
wget -O $HOME/.oh-my-zsh/themes/passion.zsh-theme https://raw.githubusercontent.com/ChesterYue/ohmyzsh-theme-passion/master/passion.zsh-theme

echo "Configuring Zsh..."
cat <<EOF > $HOME/.zshrc
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="passion"
plugins=(git zsh-autosuggestions)
source \$ZSH/oh-my-zsh.sh
EOF

echo "Setting up Git..."
read -p "Enter your Git name: " git_name
read -p "Enter your Git email: " git_email

git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global core.editor "vim"

if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -C "$git_email" -f "$HOME/.ssh/id_rsa" -N ""
    echo "Your public key:"
    cat "$HOME/.ssh/id_rsa.pub"
fi

echo "Setup complete! Restart your terminal and enjoy your new setup. 🚀"