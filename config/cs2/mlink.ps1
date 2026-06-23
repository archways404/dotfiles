cd "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"

# Backup existing files first
ren autoexec.cfg autoexec.cfg.bak
ren demoexec.cfg demoexec.cfg.bak

# Create symlinks
New-Item -ItemType SymbolicLink `
    -Path autoexec.cfg `
    -Target "C:\Users\phili\Documents\REPO\dotfiles\config\cs2\autoexec.cfg"

New-Item -ItemType SymbolicLink `
    -Path demoexec.cfg `
    -Target "C:\Users\phili\Documents\REPO\dotfiles\config\cs2\demoexec.cfg"
”