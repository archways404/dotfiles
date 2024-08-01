#!/bin/bash

# Define variables
NVIM_CONFIG_REPO="https://github.com/archways404/dotfiles.git"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
PACKER_INSTALL_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

# Clone the repository
if [ ! -d "$NVIM_CONFIG_DIR" ]; then
  git clone $NVIM_CONFIG_REPO $HOME/dotfiles
  mkdir -p $NVIM_CONFIG_DIR
  cp -r $HOME/dotfiles/nvim/config/* $NVIM_CONFIG_DIR
else
  echo "Neovim configuration directory already exists."
  exit 1
fi

# Install packer.nvim
if [ ! -d "$PACKER_INSTALL_DIR" ]; then
  git clone --depth 1 https://github.com/wbthomason/packer.nvim $PACKER_INSTALL_DIR
else
  echo "packer.nvim is already installed."
fi

# Install dependencies for different platforms
case "$(uname -s)" in
  Darwin)
    echo "Installing dependencies on macOS"
    # Install Homebrew if not installed
    if ! command -v brew &> /dev/null; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install neovim
    brew install node
    brew install npm
    brew install python3
    pip3 install neovim
    ;;
  Linux)
    echo "Installing dependencies on Linux"
    sudo apt update
    sudo apt install -y neovim python3-neovim npm curl
    curl -sL install-node.now.sh/lts | bash
    ;;
  *)
    echo "Unsupported OS"
    exit 1
    ;;
esac

# Install plugins
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

echo "Neovim configuration is set up."
