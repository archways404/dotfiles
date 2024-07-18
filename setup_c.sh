#!/bin/bash

# SETUP SCRIPT

# 1. Create the script file in /usr/local/bin
cd /usr/local/bin || { echo "Failed to change directory to /usr/local/bin"; exit 1; }
touch c
chmod +x c

# 2. Write the content to the script file
cat > c << 'EOF'
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
EOF

# 3. Ensure the script is executable
chmod +x /usr/local/bin/c

# 4. Update ~/.bashrc to include /usr/local/bin in the PATH
if ! grep -q "/usr/local/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
    source ~/.bashrc
fi

echo "Setup complete. You can now use the 'c' command to download and customize the Makefile."
