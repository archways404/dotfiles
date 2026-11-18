@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0ssh-windows.ps1" %*
set "ssh_setup_exit=%ERRORLEVEL%"
if not defined DOTFILES_NO_PAUSE pause
exit /b %ssh_setup_exit%
