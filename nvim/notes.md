# NVIM INSTALLATION

### Windows

*init.lua*
```
mkdir -p $HOME/AppData/Local/nvim
cd $HOME/AppData/Local/nvim
curl -o init.lua https://raw.githubusercontent.com/archways404/dotfiles/main/nvim/init.lua
```

#

### MacOS

*init.lua*
```
mkdir -p ~/.config/nvim
cd ~/.config/nvim
curl -o init.lua https://raw.githubusercontent.com/archways404/dotfiles/main/nvim/init.lua
```



# TEMP

### Windows

*packer.nvim*
```
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

*build-init.lua*
```
mkdir -p $HOME/AppData/Local/nvim
cd $HOME/AppData/Local/nvim
curl -o init.lua https://raw.githubusercontent.com/archways404/dotfiles/main/nvim/build-init.lua
```

*LSP*
```
npm install -g pyright
npm install -g typescript typescript-language-server prettier
go install golang.org/x/tools/gopls@latest
rustup component add rust-analyzer
brew install stylua
```

*Packer*
```
nvim
:PackerInstall
```

#

### MacOS

*Neovim*
```
brew install neovim
```

*build-init.lua*
```
mkdir -p ~/.config/nvim
cd ~/.config/nvim
curl -o init.lua https://raw.githubusercontent.com/archways404/dotfiles/main/nvim/build-init.lua
```

*packer.nvim*
```
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

*build-init.lua*
```
mkdir -p $HOME/AppData/Local/nvim
cd $HOME/AppData/Local/nvim
curl -o init.lua https://raw.githubusercontent.com/archways404/dotfiles/main/nvim/build-init.lua
```

*LSP*
```
npm install -g pyright
npm install -g typescript typescript-language-server prettier
go install golang.org/x/tools/gopls@latest
rustup component add rust-analyzer
brew install stylua
```

*Packer*
```
nvim
:PackerInstall
```
