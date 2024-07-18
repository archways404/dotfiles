# SETUP SCRIPT

```sh
curl -O https://raw.githubusercontent.com/archways404/dotfiles/main/setup_c.sh
chmod +x setup_c.sh
sudo ./setup_c.sh
./setup_c.sh
```

# SETUP MANUAL

```sh
cd /usr/local/bin
```

```sh
touch c
```

```sh
nano c
```
# C
```sh
#!/bin/bash

# URL to the Makefile on GitHub
MAKEFILE_URL="https://raw.githubusercontent.com/archways404/dotfiles/main/c-script"

# Download the Makefile using curl
curl -o Makefile $MAKEFILE_URL

# Check if a filename argument is provided
if [ "$1" ]; then
    # Replace the TARGET variable in the Makefile with the provided filename
    sed -i "s/^TARGET = .*/TARGET = $1/" Makefile
    echo "Makefile has been downloaded and the target has been renamed to $1 in $(pwd)"
else
    echo "Makefile has been downloaded to $(pwd)"
fi
```

```sh
chmod +x /usr/local/bin/c
```

```sh
nano ~/.bashrc
```

## bashrc:
```sh
export PATH=$PATH:/usr/local/bin/c
```

```sh
source ~/.bashrc
```

# USAGE
```c``` will create the Makefile (defaults to TARGET = main)

```c [args]``` will create the Makefile (TARGET = [args])
