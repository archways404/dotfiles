cd "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"

New-Item -ItemType SymbolicLink -Path autoexec.cfg -Target "C:\Users\phili\Documents\REPO\dotfiles\config\cs2\autoexec.cfg"

New-Item -ItemType SymbolicLink -Path demoexec.cfg -Target "C:\Users\phili\Documents\REPO\dotfiles\config\cs2\demoexec.cfg"

New-Item -ItemType SymbolicLink -Path cfgdeps -Target "C:\Users\phili\Documents\REPO\dotfiles\config\cs2\cfgdeps"


run command:
.\scripts\setup-cs2.ps1
