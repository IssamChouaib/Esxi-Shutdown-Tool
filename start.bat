@echo off
mode con: cols=20 lines=3

REM -- PowerShell 5
if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
  "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -NoProfile -File esxi_shutdown.ps1 >nul 2>&1
  exit /b
)
REM -- PowerShell 7
if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" (
  "%ProgramFiles%\PowerShell\7\pwsh.exe" -NoProfile -File esxi_shutdown.ps1 >nul 2>&1
  exit /b
)
REM -- Aviso si no hay PowerShell compatible
mshta "javascript:alert('No compatible version of PowerShell was found.');close();"
