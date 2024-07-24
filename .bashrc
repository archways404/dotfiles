# Go environment
export GOROOT="/c/Program Files/Go"
export PATH=$PATH:"/c/Program Files/Go/bin"

# MSYS2 and Mingw64
export PATH=$PATH:/c/msys64/usr/bin
export PATH=$PATH:/c/msys64/mingw64/bin

# Local bin
export PATH=$PATH:/usr/local/bin

export PATH=$PATH:/c/C_Lib/libxml2/bin
export PATH=$PATH:/c/C_Lib/curl/bin


# CARGO COMMANDS

# alias cargo-watch='cargo watch -x run'

cargo() {
  if [[ "$1" == "watch" ]]; then
    shift
    command cargo watch -x run "$@"
  else
    command cargo "$@"
  fi
}
