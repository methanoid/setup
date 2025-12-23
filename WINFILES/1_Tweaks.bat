:: == WINDOWS CUSTOMIZER SCRIPT for WINDOWS 10 & 11 LTSC ========== $OEM$ inc Customizer & EdgeDie on W10 ============================

:: ==TWEAKS===========================================================================================================================
@echo off
title Tweaks

:check
ping www.google.com -n 1 -w 1000>nul && cls
if errorlevel 1 (echo "This script needs you to connect to internet" & wait 5 & goto check) else (echo Starting)

echo Hide Recommended Section and Recently Added Apps
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecentlyAddedApps" /t REG_DWORD /d "1" /f >nul 2>&1
cls

echo Switch to Dark mode system-wide
powershell -command "Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force;"
powershell -command "Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force;"
taskkill /im explorer.exe /f >nul 2>&1
start explorer.exe >nul 2>&1
rd /s /q "c:\Perflogs" >nul 2>&1
cls

echo Set Sharing for unRAID
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul 2>&1
powershell -command "Set-NetFirewallRule -Group '*-32752*' -Enabled 'True'"
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul 2>&1
reg add HKLM\Software\Policies\Microsoft\Windows\LanmanWorkstation /v AllowInsecureGuestAuth /t REG_DWORD /d "1" /f >nul 2>&1
reg add HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters /v EnableSecuritySignature /t REG_DWORD /d "0" /f >nul 2>&1
sc config "LanmanWorkstation" start=automatic >nul 2>&1     REM Needed for Samba Share
cls

echo Remove Gallery from Explorer
reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c} /f /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0x00000000 >nul 2>&1

echo Remove Home and 3D Objects from Explorer and Pin to QuickAccess
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f  >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /f >nul 2>&1
reg delete "HKCR\AllFilesystemObjects\shell\pintohome" /f >nul 2>&1
reg delete "HKCR\Drive\shell\pintohome" /f >nul 2>&1
reg delete "HKCR\Folder\shell\pintohome" /f >nul 2>&1
reg delete "HKCR\Network\shell\pintohome" /f >nul 2>&1
cls

echo Stop Explorer from showing external drives twice
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul 2>&1
cls

echo Make sure Defender icon IS in tray
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /f >nul 2>&1
cls

echo Remove Realtek Control Panel (will error if not present)
reg delete HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run /v "RTHDVCPL" /f >nul 2>&1
cls

echo Disable Taskbar Transparency (needed for NV 7 Series)
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f >nul 2>&1
cls

echo Enable Quick Machine Recovery
reagentc.exe /enable >nul 2>&1
cls

echo Set PageFile size
wmic computersystem where name="NEW_INSTALL" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=512,MaximumSize=2048
cls

echo Disable System Restore
reg add "HKLM\Software\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableSR" /t REG_DWORD /d "1" /f
schtasks /Change /TN "Microsoft\Windows\SystemRestore\SR" /Disable >nul 2>&1
vssadmin Resize ShadowStorage /For=C: /On=C: /Maxsize=320MB >nul 2>&1
cls
