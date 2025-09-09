:: ==TWEAKS===========================================================================================================================

@echo off
title Tweaks

:check
ping www.google.com -n 1 -w 1000>nul && cls
if errorlevel 1 (echo "This script needs you to connect to internet" & wait 5 & goto check) else (echo Starting)

:: Windows update check and update
echo Asking Windows Update to start
wuauclt /detectnow
wuauclt /updatenow

echo Switch to Dark mode system-wide
powershell -command "Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force;"
powershell -command "Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force;"
taskkill /im explorer.exe /f & start explorer.exe & label C: Win11 >nul & rd /s /q "c:\Perflogs" >nul 2>&1

echo Set Sharing for unRAID
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul
reg add HKLM\Software\Policies\Microsoft\Windows\LanmanWorkstation /v AllowInsecureGuestAuth /t REG_DWORD /d "1" /f >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters /v EnableSecuritySignature /t REG_DWORD /d "0" /f >nul

echo Remove Gallery from Explorer
reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c} /f /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0x00000000

echo Remove Home from Explorer and Pin to QuickAccess
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /f >nul
reg delete "HKCR\AllFilesystemObjects\shell\pintohome" /f & reg delete "HKCR\Drive\shell\pintohome" /f & reg delete "HKCR\Folder\shell\pintohome" /f & reg delete "HKCR\Network\shell\pintohome" /f

echo Stop Explorer from showing external drives twice
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul

echo Hide Recommended Section on Start Menu (which is soon to be hidden anyway!)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d "1" /f >nul

echo Make sure Defender icon IS in tray
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /f >nul

echo Remove Realtek Control Panel (will error if not present)
reg delete HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run /v "RTHDVCPL" /f >nul

echo Disable Taskbar Transparency (needed for NV 7 Series)
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]" /v "EnableTransparency" /t REG_DWORD /d "0" /f >nul

echo Enable Quick Machine Recovery
reagentc.exe /enable >nul 2>&1

pause




