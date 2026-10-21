@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-windows.ps1" %*
set "setup_exit=%ERRORLEVEL%"
if not "%setup_exit%"=="0" echo Installation stopped. See the output above and %%LOCALAPPDATA%%\dotfiles\install.log.
if not defined DOTFILES_NO_PAUSE pause
exit /b %setup_exit%
