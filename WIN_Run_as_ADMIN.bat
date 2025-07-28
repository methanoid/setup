:: This script is downloaded from Github by the AutoUnattend.XML file on the ISO
@echo off
title Windows Customization - Be patient

:check
ping www.google.com -n 1 -w 1000>nul && cls
if errorlevel 1 (echo "This script needs you to connect to internet" & wait 5 & goto check) else (echo Beginning installs - be patient)


:: ==TWEAKS===========================================================================================================================

title Name PC
cls & set /p NUNAME=What name do you want this PC to be called? :
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v "ComputerName" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /v "ComputerName" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t REG_SZ /d %NUNAME% /f >nul

title Power Planning
:choice
cls & set /P c=Is this machine a (V)irtual Machine, (D)esktop or (L)aptop? [V/D/L]?
if /I "%c%" EQU "V" goto :vm
if /I "%c%" EQU "D" goto :desk
if /I "%c%" EQU "L" goto :laptop
goto :choice
:vm
echo Setting up for a VM
powercfg -setactive scheme_min
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowSleepOption" /t REG_SZ /d "0" /f >nul
goto done
:desk
echo Setting up for a Desktop
powercfg -setactive scheme_balanced
goto done
:laptop
echo Setting up for a Laptop
powercfg -setactive scheme_max
REM  Here perhaps add HP Laptop Hotkeys util ?
:done

:: Switch to Dark mode system-wide
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force;
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force;
taskkill /im explorer.exe /f
start explorer.exe

title Windows Activation
powershell -command "& ([ScriptBlock]::Create((irm https://get.activated.win))) /hwid"
label C: Win11 >nul

title Tweaks
::  Set PC network discoverable & enable file sharing
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul

:: LanmanWorkstation to Enable Connection to unRAID
reg add HKLM\Software\Policies\Microsoft\Windows\LanmanWorkstation /v AllowInsecureGuestAuth /t REG_DWORD /d "1" /f >nul

:: Remove Gallery from Explorer
reg add HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c} /f /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0x00000000

:: Remove Home from Explorer & Remove Pin to QuickAccess
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /f >nul
reg delete "HKCR\AllFilesystemObjects\shell\pintohome" /f
reg delete "HKCR\Drive\shell\pintohome" /f
reg delete "HKCR\Folder\shell\pintohome" /f
reg delete "HKCR\Network\shell\pintohome" /f

:: Stop Explorer from showing external drives twice
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul

:: Hide Recommended Section on Start Menu (which is soon to be hidden anyway!)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d "1" /f >nul

:: Make sure Defender icon IS in tray
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /f >nul

:: Remove Realtek Control Panel (will error if not present)
reg delete HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run /v "RTHDVCPL" /f >nul

:: Disable Taskbar Transparency (needed for NV 7 Series)
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]" /v "EnableTransparency" /t REG_DWORD /d "0" /f >nul

:: Auto Arrange Icons On
reg add "HKCU\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" /v FFLAGS /t REG_DWORD /d 40200224 /f >nul     :: DOESNT WORK!!!!!!!!!

rd /s /q "c:\Perflogs" >nul 2>&1

:: Enable Quick Machine Recovery
reagentc.exe /enable >nul 2>&1


:: ==INSTALLS========================================================================================================================

title Installing Winget
powershell -command "Install-PackageProvider -Name NuGet -Force | Out-Null"
powershell -command "Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null"
powershell -command "Repair-WinGetPackageManager"

title Debloating Last AppX
::Remove-AppXProvisionedPackage -Online -PackageName Microsoft.MicrosoftEdgeDevToolsClient* -AllUsers
::Remove-AppXProvisionedPackage -Online -PackageName Microsoft.Edge.GameAssist* -AllUsers
::Remove-AppXProvisionedPackage -Online -PackageName Microsoft.MicrosoftEdge.Stable* -AllUsers
::del /s "c:\Users\Administrator\Desktop\Microsoft Edge.lnk" >nul 2>&1
powershell -command "Remove-AppXProvisionedPackage -Online -PackageName Microsoft.OutlookForWindows* -AllUsers"
powershell -command "Remove-AppXProvisionedPackage -Online -PackageName Microsoft.Windows.NarratorQuickStart*"
powershell -command "Remove-AppXProvisionedPackage -Online -PackageName Microsoft.Windows.DevHome*"
powershell -command "Remove-AppXProvisionedPackage -Online -PackageName AppUp.IntelGraphicsExperience*"
:: ***************************** FAILS ***********************



title Installing Wintoys
winget install -e -h 9P8LTPGCBZXD --accept-package-agreements

title Installing UniGetUI
winget install -e -h --id XPFFTQ032PTPHF --accept-package-agreements

title Installing Brave
winget install -e -h --id Brave.Brave --accept-package-agreements
del /s "c:\Users\%username%\Desktop\Brave.lnk" >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "BraveSoftware Update" /f
for /f "tokens=1 delims=," %%x in ('schtasks /query /fo csv ^| find "Brave"') do schtasks /Delete /TN %%x /F

title Installing NVcleanstall
winget install -e -h --id TechPowerUp.NVCleanstall

title Gaming Installs
:choice
set /P c=Is this machine for Gaming? [Y/N]?
if /I "%c%" EQU "Y" goto :yes
if /I "%c%" EQU "N" goto :no
goto :choice
:yes
echo Installing clients - please wait
:choco upgrade -y steam ubisoft-connect epicgameslauncher goggalaxy ea-app >nul 2>&1
winget install -e -h --id Valve.Steam HeroicGamesLauncher.HeroicGamesLauncher GOG.Galaxy Ubisoft.Connect ElectronicArts.EADesktop
:no

title Installing 7Zip
winget install -e -h --id 7zip.7zip

title Installing Notepad++
winget install -e -h --id Notepad++.Notepad++

title Installing Redist Files
winget install -e -h --id Microsoft.VCRedist.2015+.x64

title Installing OnlyOffice
winget install -e -h --id ONLYOFFICE.DesktopEditors

title Installing Putty
winget install -e -h --id PuTTY.PuTTY
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/Putty.lnk -OutFile C:\Users\Administrator\Desktop\Putty.lnk"

title Installing Windhawk customizer
winget install -e -h --id RamenSoftware.Windhawk
schtasks /delete /tn WindhawkUpdateTask /f
md "c:\Users\Administrator\Desktop\Open Windhawk and install Windows 11 Start Menu Styler"

title Installing SumatraPDF
winget install -e -h --id SumatraPDF.SumatraPDF
del /s "c:\Users\Administrator\Desktop\SumatraPDF.lnk" >nul 2>&1

title Installing ImgBurn
winget install -e -h --id LIGHTNINGUK.ImgBurn
del /s "c:\Users\%username%\Desktop\ImgBurn.lnk" >nul 2>&1
del /s "c:\Users\Public\Desktop\ImgBurn.lnk" >nul 2>&1

title Installing KLite Codecs
winget install -e -h --id CodecGuide.K-LiteCodecPack.Standard
del /s "c:\Users\%username%\Desktop\MPC-HC x64.lnk" >nul 2>&1
del /s "c:\Users\Public\Desktop\mpc-be.lnk" >nul 2>&1
schtasks /delete /tn klcp_update /f >nul 2>&1

title Installing Minecraft Launcher
winget install -e -h --id PrismLauncher.PrismLauncher

title Installing LockHunter
winget install -e -h --id CrystalRich.LockHunter
taskkill /F /IM msedge.exe /T

title Installing Hashtab
winget install -e -h --id namazso.OpenHashTab

title Installing Privado VPN
winget install -e -h --id PrivadoNetworksAG.PrivadoVPN
del /s "c:\Users\Public\Desktop\PrivadoVPN.lnk" >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" /v "AssumeUDPEncapsulationContextOnSendRule" /t REG_DWORD /d "2" /f >nul      
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "PrivadoVPN" /f

title Installing Bleachbit
winget install -e -h --id BleachBit.BleachBit
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/bleachbit.ini -OutFile C:\Users\Administrator\AppData\Local\BleachBit\bleachbit.ini"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/winapp2.ini -OutFile C:\Users\Administrator\AppData\Local\BleachBit\cleaners\winapp2.ini"

title Installing CCleaner
winget install -e -h --id Piriform.CCleaner
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/ccleaner.ini -OutFile 'C:\Program Files\CCleaner\ccleaner.ini'"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/winapp2.ini -OutFile 'C:\Program Files\CCleaner\winapp2.ini'"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/CCenhancer.exe -OutFile 'C:\Program Files\CCleaner\CCenhancer.exe'"
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "CCleaner Smart Cleaning" /f >nul
for /f "tokens=1 delims=," %%x in ('schtasks /query /fo csv ^| find "CCleaner"') do schtasks /Delete /TN %%x /F

title Installing Wise Disk Cleaner
winget install -e -h --id WiseCleaner.WiseDiskCleaner
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/config.ini -OutFile 'C:\Program Files (x86)\Wise\Wise Disk Cleaner\config.ini'"

title Installing Wise Force Deleter
winget install -e -h --id WiseCleaner.WiseForceDeleter

title Installing Wise Registry Cleaner
winget install -e -h --id WiseCleaner.WiseRegistryCleaner

title Installing MKVtoolnix
winget install -e -h --id MoritzBunkus.MKVToolNix
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/MKVToolnix.lnk -OutFile C:\Users\Administrator\Desktop\MKVtoolnix.lnk"

title Installing Shutup10++
winget install -e -h --id OO-Software.ShutUp10
shutup10

title Installing DriverBooster
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/DB.exe -OutFile C:\Users\Administrator\Desktop\DB.exe"
C:\Users\Administrator\Desktop\DB.exe -Y
del C:\Users\Administrator\Desktop\DB.exe

title Installing CBX Shell
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/CBX.exe -OutFile C:\Users\Administrator\Desktop\CBX.exe"
C:\Users\Administrator\Desktop\CBX.exe  /SP /VERYSILENT
del C:\Users\Administrator\Desktop\CBX.exe >nul 2>&1

title Installing Plasma Screensaver
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/PSS.exe -OutFile C:\Users\Administrator\Desktop\PSS.exe"
C:\Users\Administrator\Desktop\PSS.exe /S
del C:\Users\Administrator\Desktop\PSS.exe >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "c:\Windows\system32\plasma.scr" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "600" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "0" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "0" /f >nul




::   NEED FIXES FOR BELOW COS FILES ABOVE 25MB GITHUB LIMIT - MAYBE SPLIT ZIPS?

title Installing VideoReDo
REM VideoReDo.TVSuite.6.63.7.836
"c:\Portable Apps\VRD.exe" /s
del /s "c:\Portable Apps\VRD.exe" >nul 2>&1

title Installing Samsung Printer Driver
"c:\Portable Apps\SamsungUPD3.exe"
del /s "c:\Portable Apps\SamsungUPD3.exe" >nul 2>&1





:: ==CLEANUPS========================================================================================================================

title Some File Cleaning
"C:\Users\Administrator\AppData\Roaming\BleachBit\bleachbit_console.exe" -c --preset >nul 2>&1
"C:\Program Files\CCleaner\CCleaner64.exe" /AUTO                 :: Runs Ccleaner

:: Run applications (needs manual intervention)
"C:\Program Files\CCleaner\CCleaner64.exe" /REGISTRY             :: Opens CCleaner on Registry Screen
"C:\Program Files (x86)\Wise\Wise Disk Cleaner\WiseDiskCleaner.exe"


:: ==REBOOT==++======================================================================================================================

echo "Rebooting now - enjoy!"
shutdown -r -t 5


==REDUNDANT?=================================
pause
title Installing DirectX
winget install -e -h --id microsoft.directx
winget install StartIsBack.StartAllBack --scope machine
:: Windows update check and update
wuauclt /detectnow
wuauclt /updatenow
