# .zshrc

# --- OS detection ---
case "$OSTYPE" in
  darwin*) OS="mac" ;;
  linux*)  OS="linux" ;;
  *)       OS="other" ;;
esac

# ---- Oh My Zsh core ----
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="refined"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Fast Node Manager (fnm)
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

# Extra completions
fpath=(${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions/src $fpath)
autoload -U compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit -C
else
  compinit
fi

# Plugins
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
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Debian/Ubuntu alias shims
alias fd='fdfind'
alias bat='batcat'

# ls Alternatives
if command -v eza >/dev/null 2>&1; then
  alias ll='eza -lh --group-directories-first --git-ignore --git'
  alias la='eza -lha --group-directories-first --git-ignore --git'
elif command -v exa >/dev/null 2>&1; then
  alias ll='exa -lh --group-directories-first --git-ignore --git'
  alias la='exa -lha --group-directories-first --git-ignore --git'
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# fzf integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- keep emacs keymap defaults ---
bindkey -e
export KEYTIMEOUT=1

# --- fzf file finder on ALT+Space (leave CTRL-Space alone) ---
fzf-file-widget() {
  local previewer
  if command -v batcat >/dev/null 2>&1; then
    previewer='batcat --style=numbers --color=always --paging=never'
  elif command -v bat >/dev/null 2>&1; then
    previewer='bat --style=numbers --color=always --paging=never'
  else
    previewer='cat'
  fi

  local file
  file=$(fzf --preview "$previewer {}" --height=40%)
  [[ -n $file ]] && LBUFFER+="$file"
}
zle -N fzf-file-widget

# CTRL+F → same as ALT+C (fzf cd into dir)
bindkey '^F' fzf-cd-widget

# ALT+Space → custom file picker with preview
bindkey '^[ ' fzf-file-widget

# --- override zoxide's alias and provide a truly interactive zi ---
# The zoxide plugin defines: alias zi='z -i'
# Remove that alias/function before defining our own.
unalias zi 2>/dev/null
unset -f zi 2>/dev/null

zi() {
  local dir
  # Show the full ranked list; do not auto-select.
  dir=$(zoxide query -l | fzf \
        --height=40% --prompt='zoxide> ' \
        --preview 'ls -la --color=always {}' --preview-window=down:10)
  [[ -n $dir ]] && cd "$dir"
}

# ---- Cheat Sheet ----

# --- palette (xterm 256 colors) ---
# 16 distinct hues + light/dark gray
typeset -A PALETTE
PALETTE=(
  red        $'\e[38;5;196m'
  orange     $'\e[38;5;208m'
  amber      $'\e[38;5;214m'
  yellow     $'\e[38;5;226m'
  lime       $'\e[38;5;118m'
  green      $'\e[38;5;046m'
  teal       $'\e[38;5;049m'
  cyan       $'\e[38;5;051m'
  sky        $'\e[38;5;039m'
  blue       $'\e[38;5;027m'
  indigo     $'\e[38;5;054m'
  violet     $'\e[38;5;141m'
  magenta    $'\e[38;5;201m'
  pink       $'\e[38;5;206m'
  peach      $'\e[38;5;216m'
  brown      $'\e[38;5;130m'
  lightgray  $'\e[38;5;250m'
  darkgray   $'\e[38;5;240m'
)

RESET=$'\e[0m'

# --- helper to color arbitrary text: color <name> <text...> ---
color() {
  local name=$1; shift
  printf '%s%s%s' "${PALETTE[$name]}" "$*" "$RESET"
}

# ----- visible width + padding (ANSI-safe) -----
# visible_len: strip ANSI escapes, then count characters
visible_len() {
  print -rn -- "$1" | sed -E 's/\x1B\[[0-9;]*[A-Za-z]//g' | wc -m | tr -d '[:space:]'
}
# pad_to "<string (may have colors)>" <width>
pad_to() {
  local s="$1" w=$2 len pad
  len=$(visible_len "$s")
  pad=$(( w - len ))
  (( pad < 0 )) && pad=0
  printf '%s%*s' "$s" $pad ''
}

# --- Key label strings that differ per OS ---
if [[ $OS == mac ]]; then
  SUPER=$(color blue ⌘)
  CTRL=$(color yellow ⌃)
  SHIFT=$(color orange SHIFT)
  ALT=$(color cyan ⌥)
  ENTER=$(color lime ENTER)
  TAB=$(color brown TAB)
  # SPECIAL
  PGUP=$(color teal PGUP)
  PGDN=$(color teal PGDN)
  H0ME=$(color cyan HOME)
  END=$(color cyan END)
  INS=$(color cyan INS)
  DEL=$(color red DEL)
  F4=$(color sky F4)
  # ARROW
  UP=$(color cyan ↑)
  DOWN=$(color cyan ↓)
  LEFT=$(color cyan ←)
  RIGHT=$(color cyan →)
  ARROW=$(color cyan ↑↓←→)
  # BRACKETS
  LBR=$(color cyan  [)
  RBR=$(color cyan  ])
  # SYMBOLS
  PLUS=$(color orange +)
  SLASH=$(color cyan  /)
  COMMA=$(color cyan ,)
  NUM=$(color cyan NUMBER)
  UNDER=$(color cyan _)
  SPACE=$(color cyan SPACE)
else
  SUPER=$(color blue   SUPER)
  CTRL=$(color yellow CTRL)
  SHIFT=$(color orange SHIFT)
  ALT=$(color cyan    ALT)
  ENTER=$(color lime ENTER)
  TAB=$(color brown TAB)
  # SPECIAL
  PGUP=$(color teal PGUP)
  PGDN=$(color teal PGDN)
  H0ME=$(color cyan HOME)
  END=$(color cyan END)
  INS=$(color cyan INS)
  DEL=$(color red DEL)
  F4=$(color sky F4)
  # ARROW
  UP=$(color cyan ↑)
  DOWN=$(color cyan ↓)
  LEFT=$(color cyan ←)
  RIGHT=$(color cyan →)
  ARROW=$(color cyan ↑↓←→)
  # BRACKETS
  LBR=$(color cyan  [)
  RBR=$(color cyan  ])
  # SYMBOLS
  PLUS=$(color orange +)
  SLASH=$(color cyan  /)
  COMMA=$(color cyan ,)
  NUM=$(color cyan NUMBER)
  UNDER=$(color cyan _)
  SPACE=$(color cyan SPACE)
fi

# Optional “spacer” (a few spaces) – visible on purpose
SP=$(printf '%s' '   ')  # 3 spaces; change if you want more

# ----- row printer: left keys padded to GUTTER, then description -----
print_row() {
  local left="$1" right="$2" GUTTER=30
  pad_to "$left" $GUTTER
  printf ' - %s\n' "$right"
}

# ========= pretty printers (headers, rules, newlines) =========

# nl [N]  → print N blank lines (default 1)
nl() {
  local n=${1:-1}
  while (( n-- > 0 )); do printf '\n'; done
}

# rule [char] [color] [width]  → horizontal rule across width (defaults: '-' gray $COLUMNS)
rule() {
  local ch=${1:--} col=${2:-gray} w=${3:-${COLUMNS:-80}}
  local bar
  bar=$(printf '%*s' $w '' | tr ' ' "$ch")
  printf '%s\n' "$(color "$col" "$bar")"
}

# center_title <text> [width] [rule-color]
# A centered title with rules on both sides (like your “GHOSTTY” bar).
center_title() {
  local text="$1" w=${2:-${COLUMNS:-80}} rcol=${3:-gray}
  local tlen l r
  tlen=$(visible_len "$text")
  (( tlen > w-2 )) && text="${text[1,$((w-2))]}" && tlen=$((w-2))   # truncate if too long
  l=$(( (w - tlen - 2) / 2 ))
  r=$(( w - tlen - 2 - l ))
  printf '%s %s %s\n' \
    "$(color "$rcol" "$(printf '%*s' $l '' | tr ' ' '-')")" \
    "$text" \
    "$(color "$rcol" "$(printf '%*s' $r '' | tr ' ' '-')")"
}

center_text() {
  local text="$1" w=${2:-${COLUMNS:-80}} rcol=${3:-gray}
  local tlen l r
  tlen=$(visible_len "$text")
  (( tlen > w-2 )) && text="${text[1,$((w-2))]}" && tlen=$((w-2))   # truncate if too long
  l=$(( (w - tlen - 2) / 2 ))
  r=$(( w - tlen - 2 - l ))
  printf '%s %s %s\n' \
    "$(color "$rcol" "$(printf '%*s' $l '' | tr ' ' ' ')")" \
    "$text" \
    "$(color "$rcol" "$(printf '%*s' $r '' | tr ' ' ' ')")"
}

h0() { center_text "$(color white "$*")"; nl; }

# h1 <text>         → big header (centered bar + a blank line)
h1() { center_title "$(color white "$*")"; nl; }

# h2 <text>         → section subtitle (left-aligned, underlined rule)
h2() {
  local label="$(color gray "$*")"
  printf '%s\n' "$label"
  printf '%s\n' "$(color gray "$(printf '%*s' "$(visible_len "$*")" '' | tr ' ' '-')")"
  nl
}

# h3 <text>         → small caption (dim)
h3() { printf '%s\n\n' "$(color gray "$*")"; }

show_cheatsheet() {
  h1 "CHEAT SHEET"
  h0 "v0.0.1"
  nl
  nl
  h0 "created by archways404"
  nl
  nl
  nl
  h1 "GHOSTTY"
  nl

  h2 "General"
  print_row "${CTRL}   ${SHIFT}  N"                     "new_window"
  print_row "${CTRL}   ${SHIFT}  Q"                     "quit"
  print_row "${CTRL}   ${SHIFT}  ${PGUP}"               "jump_to_prompt:-1"
  print_row "${CTRL}   ${SHIFT}  ${PGDN}"               "jump_to_prompt:1"
  print_row "${ALT}    ${F4}"                           "close_window"
  nl

  h2 "Splits"
  print_row "${SUPER}  ${CTRL}   ${SHIFT}  ${PLUS}"     "equalize splits"
  print_row "${SUPER}  ${CTRL}   ${SHIFT}  ${ARROW}"    "resize_split 10"
  print_row "${SUPER}  ${CTRL}   ${LBR}"                "goto_split:previous"
  print_row "${SUPER}  ${CTRL}   ${RBR}"                "goto_split:next"
  print_row "${CTRL}   ${ALT}    ${ARROW}"              "target split"
  print_row "${CTRL}   ${SHIFT}  ${ENTER}"              "toggle_split_zoom"
  print_row "${CTRL}   ${SHIFT}  E"                     "new_split:down"
  print_row "${CTRL}   ${SHIFT}  O"                     "new_split:right"
  nl

  h2 "Tabs"
  print_row "${CTRL}   ${SHIFT}  T"                     "new tab"
  print_row "${CTRL}   ${SHIFT}  W"                     "close tab"
  print_row "${CTRL}   ${SHIFT}  ${LEFT}"               "previous_tab"
  print_row "${CTRL}   ${SHIFT}  ${RIGHT}"              "next_tab"
  print_row "${CTRL}   ${PGDN}"                         "next_tab"
  print_row "${CTRL}   ${PGUP}"                         "previous_tab"
  print_row "${ALT}    ${NUM}"                          "goto_tab NUMBER"
  print_row "${ALT}    9"                               "last_tab"
  nl

  h2 "Scrolling"
  print_row "${SHIFT}   ${H0ME}"                        "scroll_to_top"
  print_row "${SHIFT}   ${END}"                         "scroll_to_bottom"
  print_row "${SHIFT}   ${PGUP}"                        "scroll_page_up"
  print_row "${SHIFT}   ${PGDN}"                        "scroll_page_down"
  nl

  h2 "Editing"
  print_row "${CTRL}   ${SHIFT}  C"                     "copy"
  print_row "${CTRL}   ${SHIFT}  V"                     "paste"
  print_row "${CTRL}   ${SHIFT}  A"                     "select_all"
  nl

  h2 "Config & Misc"
  print_row "${CTRL}   ${SHIFT}  I"                     "inspector:toggle"
  print_row "${CTRL}   ${SHIFT}  ${COMMA}"              "reload_config"
  print_row "${CTRL}   ${COMMA}"                        "open_config"
  nl

  h1 "Zsh"

  h2 "Navigation"
  print_row "${ALT}   F"                                "Move cursor to next word"
  print_row "${ALT}   B"                                "Move cursor to previous word"
  print_row "${CTRL}  A"                                "Move cursor to beginning of command"
  print_row "${CTRL}  E"                                "Move cursor to end of command"
  print_row "${CTRL}  X,X"                              "Toggle between the start of line and current cursor position"
  nl

  h2 "Editing"
  print_row "${ALT}  C"                                 "Capitalize word"
  print_row "${ALT}  D"                                 "Delete next word"
  print_row "${ALT}  ${DEL}"                            "Delete previous word"
  print_row "${ALT}  L"                                 "Lowercase word"
  print_row "${ALT}  U"                                 "Uppercase word"
  print_row "${ALT}  L"                                 "Cancel the changes, revert"
  print_row "${ALT}  T"                                 "Swap current word with previous"
  print_row "${ALT}  W"                                 "Delete until beginning (zsh)"
  print_row "${CTRL}  ${UNDER}"                         "Undo"
  print_row "${CTRL}  K"                                "Cut till end"
  print_row "${CTRL}  T"                                "Swap the last two characters before the cursor"
  print_row "${CTRL}  U"                                "Delete whole line (zsh)/ cut until beginning (bash)"
  print_row "${CTRL}  W"                                "Cut previous word"
  # NOT TESTED
  print_row "${CTRL}  A"                                "start of line"
  print_row "${CTRL}  E"                                "end of line"
  print_row "${CTRL}  U"                                "kill to start"
  print_row "${CTRL}  K"                                "kill to end"
  nl

  h2 "Modes + Misc"
  print_row "${CTRL}  X,V"                              "vi mode (zsh)"
  print_row "bindkey -e"                                "Emacs mode"
  print_row "${CTRL}  L"                                "Clear screen"
  nl

  h1 "fzf"
  print_row "${CTRL}  F"                                "Fuzzy find all subdirectories of the working directory"
  print_row "${ALT}   C"                                "Fuzzy find all subdirectories of the working directory"
  # NOT TESTED
  print_row "${CTRL}  R"                                "fuzzy history"
  print_row "${CTRL}  T"                                "insert file path"
  nl

  h1 "Zoxide"
  print_row "zi"                                        "interactive jump (fzf)"
  # NOT TESTED
  print_row "z foo"                                     "cd into highest ranked directory matching foo"
  print_row "z foo bar"                                 "cd into highest ranked directory matching foo and bar"
  print_row "z foo /"                                   "cd into a subdirectory starting with foo"
  print_row "z ~/foo"                                   "z also works like a regular cd command"
  print_row "z foo/"                                    "cd into relative path"
  print_row "z .."                                      "cd one level up"
  print_row "z -"                                       "cd into previous directory"
  print_row "zi foo"                                    "cd with interactive selection (using fzf)"
  print_row "z foo ${SPACE}  ${TAB}"                    "show interactive completions (zoxide v0.8.0+, bash 4.4+/fish/zsh only)"
  nl

  print_row "sc"                   "show cheat sheet"
  nl
  rule
}
# Print on interactive shell start
[[ $- == *i* ]] && show_cheatsheet

# Alias to recall it anytime
alias sc='show_cheatsheet'
