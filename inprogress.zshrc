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

# ---- Two-column quick reference (auto-width + colors) ----
# Tweakables (optional):
: ${CHEAT_COL_MIN:=40}        # minimum width of each column
: ${CHEAT_KEYW:=26}           # width reserved for key chord inside each column
: ${CHEAT_SEP:=" │ "}         # column separator text

show_cheatsheet_test() {
  # Colors (turn off with: export CHEAT_NO_COLOR=1)
  if [[ -n $CHEAT_NO_COLOR ]]; then
    local B="" DIM="" HI="" GR="" R=""
  else
    local B=$'\e[1m'          # bold
    local DIM=$'\e[2m'        # dim
    local HI=$'\e[38;5;81m'   # cyan-ish for keys
    local GR=$'\e[38;5;244m'  # grey for rulers
    local R=$'\e[0m'          # reset
  fi

  # Layout
  local C=${COLUMNS:-$(tput cols 2>/dev/null || echo 100)}
  local SEP="$CHEAT_SEP"
  local W=$(( (C - ${#SEP}) / 2 ))
  (( W < CHEAT_COL_MIN )) && W=$CHEAT_COL_MIN

  local KEYW=$CHEAT_KEYW
  (( KEYW > W-8 )) && KEYW=$(( W-8 ))
  local ACTW=$(( W - KEYW - 3 ))   # " - " + action

  local ruleL=$(printf '%*s' $W '' | tr ' ' '-')
  local ruleR=$ruleL

  _hdr() {
    printf "\n${B}%-*s${R}%s${B}%-*s${R}\n" $W "$1" "$SEP" $W "$2"
    printf "${GR}%-*s${R}%s${GR}%-*s${R}\n" $W "$ruleL" "$SEP" $W "$ruleR"
  }

  _row() {
    # $1=leftKey $2=leftAction $3=rightKey $4=rightAction
    printf "%s%-${KEYW}s%s - ${DIM}%-*s${R}%s%s%-${KEYW}s%s - ${DIM}%-*s${R}\n" \
      "$HI$B" "${1}" "$R" $ACTW "${2}" "$SEP" "$HI$B" "${3}" "$R" $ACTW "${4}"
  }

  _blank() { printf "%-${W}s%s%-${W}s\n" "" "$SEP" ""; }

  _hdr "Ghostty (terminal)" "Zsh / fzf / zoxide / plugins"

  _row "SUPER + CTRL + SHIFT + PLUS " "equalize splits"           "CTRL-A / CTRL-E"           "start / end of line"
  _row "SUPER + CTRL + SHIFT + ARROW"           "resize split 10"           "CTRL-U / CTRL-K"           "kill to start / end"
  _row "CTRL  + ALT  + ARROW        "           "goto split"                "CTRL-W / CTRL-Y"           "delete word / yank"
  _row "SUPER+CTRL+[ / ]"              "prev / next split"          "CTRL-L"                    "clear screen"
  _row "CTRL+SHIFT+ENTER"              "toggle split zoom"          "CTRL-Space"                "set mark (select)"
  _row "CTRL+SHIFT+T / W"        "new / close tab"            "↑ / ↓"                     "history by prefix"
  _row "CTRL+SHIFT+LEFT/RIGHT"   "prev / next tab"            "CTRL-R"                    "incremental history (fzf overrides)"
  _row "ALT+1..9 / ALT+9"        "goto tab / last tab"        ""                          ""
  _row "CTRL+Tab / PgUp/Dn"      "next / prev tab"            ""                          ""

  _blank
  _row "CTRL+SHIFT+C / V"        "copy / paste"               "CTRL-R (fzf)"              "fuzzy history"
  _row "CTRL+Insert"             "copy selection"             "CTRL-T"                    "insert file path"
  _row "SHIFT+Insert"            "paste selection"            "ALT-C / CTRL-F"            "fzf cd into dir"
  _row "SHIFT+ARROW"            "adjust selection"           "ALT-Space"                 "fzf file picker + preview"
  _row "SHIFT+PgUp/PgDn"         "scroll page"                ""                          ""
  _row "SHIFT+Home / End"        "scroll top / bottom"        ""                          ""

  _blank
  _row "CTRL+Comma"              "open config"                "z <query>"                 "jump to best match"
  _row "CTRL+SHIFT+I"            "inspector toggle"           "zi"                        "interactive jump (fzf)"
  _row "C+A+SHIFT+J / C+S+J"     "screenfile open / paste"    "zoxide query"              "list indexed directories"
  _row "CTRL+SHIFT+E / O"        "new split down / right"     "zoxide add <dir>"          "add directory manually"
  _row "CTRL+SHIFT+,"            "reload config"              ""                          ""
  _row "CTRL+ENTER"              "fullscreen"                 ""                          ""
  _row "ALT+F4 / C+S+Q"          "close window / quit"        ""                          ""
  _row "CTRL+0 / - / ="          "reset / dec / inc font"     ""                          ""

  _blank
  _row ""                        ""                           "git"                       "gst, gaa, gcmsg, gco, gp"
  _row ""                        ""                           "docker"                    "dps, dcu, …"
  _row ""                        ""                           "npm / node"                "nr, ni, helpers"
  _row ""                        ""                           "kubectl"                   "k, kga, …"
  _row ""                        ""                           "web-search"                "google <q>, wiki <q>"

  _blank
  _row ""                        ""                           "ll / la"                   "long / all list"
  _row ""                        ""                           "fd"                        "fdfind"
  _row ""                        ""                           "bat"                       "batcat"

  _blank
  _row ""                        ""                           "sc"                        "show this sheet"
  echo
}


show_cheatsheet_t() {
  # --- Define key color variables ---
  local RESET='\033[0m'
  local SUPER_KEY='\033[38;5;206mSUPER\033[0m'   # PINK?
  local CTRL_KEY='\033[0;33mCTRL\033[0m'     # yellow
  local SHIFT_KEY='\033[0;35mSHIFT\033[0m'   # purple
  local ALT_KEY='\033[0;33mALT\033[0m'       # yellow
  local ENTER_KEY='\033[1;36mENTER\033[0m'   # cyan
  local TAB_KEY='\033[1;36mTAB\033[0m'
  local ARROW_KEY='\033[0;32mARROWS\033[0m'  # green
  local PLUS_KEY='\033[1;37mPLUS\033[0m'     # white/bright
  local F4_KEY='\033[0;36mF4\033[0m'

  # --- Print rows ---
  echo -e "${SUPER_KEY} + ${CTRL_KEY} + ${SHIFT_KEY} + ${PLUS_KEY}   →  Equalize splits"
  echo -e "${SUPER_KEY} + ${CTRL_KEY} + ${SHIFT_KEY} + ${ARROW_KEY} →  Resize split 10"
  echo -e "${CTRL_KEY} + ${ALT_KEY} + ${ARROW_KEY}                →  Goto split"
  echo -e "${CTRL_KEY} + ${SHIFT_KEY} + ${ENTER_KEY}              →  Toggle split zoom"
  echo -e "${ALT_KEY} + ${F4_KEY} / ${CTRL_KEY} + ${SHIFT_KEY} + ${F4_KEY} → Close window / quit"
}

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

# --- preset KEY labels (edit colors if you like) ---
SUPER=$(color blue   SUPER)
CTRL=$(color yellow CTRL)
SHIFT=$(color orange SHIFT)
ALT=$(color cyan    ALT)
ENTER=$(color lime ENTER)
PLUS=$(color orange PLUS)
ARROW=$(color green ARROW)
SLASH=$(color cyan  SLASH)
TAB=$(color brown TAB)
F4=$(color sky F4)
PGUP=$(color teal PGUP)
PGDN=$(color teal PGDN)
H0ME=$(color cyan HOME)
END=$(color cyan END)
LEFT=$(color cyan LEFT)
RIGHT=$(color cyan RIGHT)
INS=$(color cyan INS)
COMMA=$(color cyan INS)

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
  h1 "GHOSTTY"

  h2 "Splits / Tabs"
  print_row "${SUPER} + ${CTRL}  + ${SHIFT} + ${PLUS}"   "equalize splits"
  print_row "${SUPER} + ${CTRL}  + ${SHIFT} + ${ARROW}"  "resize split 10"
  print_row "${SUPER} + ${CTRL}  + ${SLASH}"             "[TOGGLE] prev / next split"
  print_row "${CTRL}  + ${ALT}   + ${ARROW}"             "target split"
  print_row "${CTRL}  + ${SHIFT} + ${ENTER}"             "[TOGGLE] split zoom"
  print_row "${CTRL}  + ${SHIFT} + T"                    "new tab"
  print_row "${CTRL}  + ${SHIFT} + W"                    "close tab"
  print_row "${CTRL}  + ${SHIFT} + ${LEFT}"              "prev tab"
  print_row "${CTRL}  + ${SHIFT} + ${RIGHT}"             "next tab"
  print_row "${ALT}   + 1-9"                             "goto tab"
  print_row "${ALT}   + 9"                               "last tab"
  print_row "${CTRL}  + ${TAB}   + ${PGUP}"              "next tab"
  print_row "${CTRL}  + ${TAB}   + ${PGDN}"              "prev tab"
  nl

  h2 "General"
  print_row "${CTRL}  + ${SHIFT} + C"                    "copy"
  print_row "${CTRL}  + ${SHIFT} + V"                    "paste"
  print_row "${CTRL}  + ${INS}"                          "copy selection"
  print_row "${SHIFT} + ${INS}"                          "paste selection"
  print_row "${SHIFT} + ${ARROW}"                        "adjust selection"
  print_row "${SHIFT} + ${PGUP}"                         "scroll up"
  print_row "${SHIFT} + ${PGDN}"                         "scroll down"
  print_row "${SHIFT} + ${H0ME}"                         "scroll top"
  print_row "${SHIFT} + ${END}"                          "scroll bottom"
  nl

  h2 "Something"
  print_row "${CTRL}  + ${COMMA}"                        "open config (GHOSTTY)"
  print_row "${CTRL}  + ${SHIFT} + I"                    "[TOGGLE] inspector"
  print_row "${CTRL}  + ${INS}"                          "copy selection"
  print_row "${SHIFT} + ${INS}"                          "paste selection"
  print_row "${SHIFT} + ${ARROW}"                        "adjust selection"
  print_row "${SHIFT} + ${PGUP}"                         "scroll up"
  print_row "${SHIFT} + ${PGDN}"                         "scroll down"
  print_row "${SHIFT} + ${H0ME}"                         "scroll top"
  print_row "${SHIFT} + ${END}"                          "scroll bottom"
  nl

  h1 "Zsh"
  print_row "${CTRL} + A"                               "start of line"
  print_row "${CTRL} + E"                               "end of line"
  print_row "${CTRL} + U"                               "kill to start"
  print_row "${CTRL} + K"                               "kill to end"
  nl

  h1 "fzf"
  print_row "${CTRL} + R"               "fuzzy history"
  print_row "${CTRL} + T"               "insert file path"
  nl

  rule
}

# --- optional: preview the 16 colors so you can pick ---
show_palette() {
  local k
  for k in red orange amber yellow lime green teal cyan sky blue indigo violet magenta pink peach brown lightgray darkgray; do
    printf '%-10s %s\n' "$k" "$(color $k '██████████')"
  done
}



# Print on interactive shell start
[[ $- == *i* ]] && show_cheatsheet

# Alias to recall it anytime
alias sc='show_cheatsheet'





/snap/ghostty/103/bin
❯ ghostty +list-keybinds --default

super + ctrl  + shift + plus    equalize_splits
super + ctrl  + shift + up      resize_split:up,10
super + ctrl  + shift + down    resize_split:down,10
super + ctrl  + shift + right   resize_split:right,10
super + ctrl  + shift + left    resize_split:left,10
ctrl  + alt   + shift + j       write_screen_file:open
super + ctrl  + left_bracket    goto_split:previous
super + ctrl  + right_bracket   goto_split:next
ctrl  + alt   + up              goto_split:up
ctrl  + alt   + down            goto_split:down
ctrl  + alt   + right           goto_split:right
ctrl  + alt   + left            goto_split:left
ctrl  + shift + a               select_all
ctrl  + shift + c               copy_to_clipboard
ctrl  + shift + e               new_split:down
ctrl  + shift + i               inspector:toggle
ctrl  + shift + j               write_screen_file:paste
ctrl  + shift + n               new_window
ctrl  + shift + o               new_split:right
ctrl  + shift + q               quit
ctrl  + shift + t               new_tab
ctrl  + shift + v               paste_from_clipboard
ctrl  + shift + w               close_tab
ctrl  + shift + comma           reload_config
ctrl  + shift + right           next_tab
ctrl  + shift + left            previous_tab
ctrl  + shift + page_up         jump_to_prompt:-1
ctrl  + shift + page_down       jump_to_prompt:1
ctrl  + shift + enter           toggle_split_zoom
ctrl  + shift + tab             previous_tab
alt   + one                     goto_tab:1
alt   + two                     goto_tab:2
alt   + three                   goto_tab:3
alt   + four                    goto_tab:4
alt   + five                    goto_tab:5
alt   + six                     goto_tab:6
alt   + seven                   goto_tab:7
alt   + eight                   goto_tab:8
alt   + nine                    last_tab
alt   + f4                      close_window
ctrl  + zero                    reset_font_size
ctrl  + comma                   open_config
ctrl  + minus                   decrease_font_size:1
ctrl  + plus                    increase_font_size:1
ctrl  + equal                   increase_font_size:1
ctrl  + insert                  copy_to_clipboard
ctrl  + page_up                 previous_tab
ctrl  + page_down               next_tab
ctrl  + enter                   toggle_fullscreen
ctrl  + tab                     next_tab
shift + up                      adjust_selection:up
shift + down                    adjust_selection:down
shift + right                   adjust_selection:right
shift + left                    adjust_selection:left
shift + home                    scroll_to_top
shift + end                     scroll_to_bottom
shift + insert                  paste_from_selection
shift + page_up                 scroll_page_up
shift + page_down               scroll_page_down
