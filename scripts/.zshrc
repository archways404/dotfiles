# ---- Oh My Zsh core ----
export ZSH="$HOME/.oh-my-zsh"

# Theme (pick one)
ZSH_THEME="refined"               
# ZSH_THEME="powerlevel10k/powerlevel10k"  # if installed

# Make sure user bins are visible BEFORE OMZ plugins load
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# fnm (Fast Node Manager)
export FNM_DIR="$HOME/.fnm"
if [ -s "$FNM_DIR/fnm" ]; then
  eval "$($FNM_DIR/fnm env --use-on-cd)"
fi

# Extra completions
fpath=(${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions/src $fpath)
autoload -U compinit && compinit -C

# Plugins (keep syntax-highlighting LAST)
plugins=(
  git
  zsh-completions
  zoxide
  fzf
  web-search
  docker
  npm
  node
  kubectl
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ---- User configuration ----
# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Debian/Ubuntu alias shims
alias fd='fdfind'
alias bat='batcat'

# ls alternatives (prefer eza if present, else exa)
if command -v eza >/dev/null 2>&1; then
  alias ll='eza -lh --group-directories-first --git-ignore --git'
  alias la='eza -lha --group-directories-first --git-ignore --git'
elif command -v exa >/dev/null 2>&1; then
  alias ll='exa -lh --group-directories-first --git-ignore --git'
  alias la='exa -lha --group-directories-first --git-ignore --git'
fi

# zoxide init
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
# fnm
FNM_PATH="/home/archways/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi
