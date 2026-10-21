#Requires AutoHotkey v2.0
#SingleInstance Force
; Scope the layer to terminal/editor applications. Caps remains normal elsewhere.
IsTerminal() {
    return WinActive("ahk_exe WindowsTerminal.exe")
        || WinActive("ahk_exe wezterm-gui.exe")
        || WinActive("ahk_exe nvim-qt.exe")
        || WinActive("ahk_exe alacritty.exe")
}
#HotIf IsTerminal()
CapsLock & a::Send "{Home}"
CapsLock & d::Send "{End}"
CapsLock & w::Send "^{Home}"
CapsLock & s::Send "^{End}"
; A custom combination suppresses the prefix key; restore its tap behavior.
CapsLock::SetCapsLockState(GetKeyState("CapsLock", "T") ? "Off" : "On")
#HotIf
