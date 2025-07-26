@echo off
SETLOCAL
SET "ScriptDir=%~dp0"
SET "PS1=%ScriptDir%PNG-compressor-GUI.ps1"

REM Try PowerShell 7
WHERE pwsh.exe >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo Launching PowerShell 7...
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
) ELSE (
    REM PowerShell 7 not found - try Windows PowerShell    
    echo pwsh.exe not found, trying Windows PowerShell...
    SET "WinPS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
    IF EXIST "%WinPS%" (
        echo Launching Windows PowerShell...
        "%WinPS%" -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
    ) ELSE (
        echo ERROR: Neither PowerShell 7 nor Windows PowerShell found.
        pause
    )
)

ENDLOCAL
