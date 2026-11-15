@echo off
rem Claude-Code theme for OpenCode Desktop: one-click uninstaller.
rem
rem Double-click this file. It removes the plugin entry from the global
rem OpenCode config and deletes %LOCALAPPDATA%\opencode-claude-code-theme.

setlocal
chcp 65001 >nul 2>&1
title Claude-Code theme for OpenCode Desktop - uninstall

set "PS1=%~dp0install.ps1"

if not exist "%PS1%" (
  echo Downloading the installer...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/PenicillinC3/opencode-claude-code-theme/main/install.ps1' -OutFile '%PS1%'"
  if errorlevel 1 (
    echo.
    echo Could not download install.ps1.
    echo Download the repository ZIP and run uninstall.bat from the extracted folder.
    echo.
    pause
    exit /b 1
  )
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Uninstall %*
set "CODE=%ERRORLEVEL%"

echo.
if "%CODE%"=="0" (
  echo Finished.
) else (
  echo Failed with exit code %CODE%.
)
echo.
pause
exit /b %CODE%
