:: This script is downloaded from Github by the AutoUnattend.XML file on the ISO
@echo off
title Windows Customization - Be patient

:check
ping www.google.com -n 1 -w 1000>nul && cls
if errorlevel 1 (echo "This script needs you to connect to internet" & wait 5 & goto check) else (echo Beginning installs - be patient)


:: ==TWEAKS===========================================================================================================================

::  Set PC Name
set /p NUNAME=What name do you want this PC to be called? :
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v "ComputerName" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /v "ComputerName" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t REG_SZ /d %NUNAME% /f >nul

title Activation and Wallpaper
powershell.exe -ex bypass "irm https://get.activated.win | iex"
powershell -ex bypass -Command "irm https://raw.githubusercontent.com/methanoid/setup/main/WIN_wallpaper.ps1 | iex" >nul

label C: Win11 >nul

title RegTweaks

::  Set PC network discoverable
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul

:: Remove Realtek Control Panel (will error if not present)
reg delete HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run /v "RTHDVCPL" /f >nul

:: Auto Arrange Icons On
reg add "HKCU\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" /v FFLAGS /t REG_DWORD /d 1075839525 /f >nul

:: Add Network Icon
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /t REG_DWORD /d "0" /f >nul

:: Add This PC Icon
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "0" /f >nul

:: Stop Explorer from showing external drives twice
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul

:: Put Shortcut Arrow on Shortcuts back
reg add "HKCR\IE.AssocFile.URL" /v "IsShortcut" /t REG_SZ /d "" /f >nul
reg add "HKCR\InternetShortcut" /v "IsShortcut" /t REG_SZ /d "" /f >nul
reg add "HKCR\lnkfile" /v "IsShortcut" /t REG_SZ /d "" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "29" /t REG_SZ /d "-" /f >nul

:: Disable Taskbar Transparency (needed for NV 7 Series)
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]" /v "EnableTransparency" /t REG_DWORD /d "0" /f >nul

:: Removing a few bits
PowerShell "Disable-WindowsOptionalFeature -FeatureName "WindowsMediaPlayer" -Online"

title Power Planning
:choice
set /P c=Is this machine a (V)irtual Machine, (D)esktop or (L)aptop? [V/D/L]?
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
REM Maybe add HP laptop utils ?
:done


:: This script is downloaded from Github by the AutoUnattend.XML file on the ISO
@echo off
title Windows Customization - Be patient


:: ==INSTALLS========================================================================================================================

"C:\Portable Apps\d3dx43.exe"

:: Drivers (not needed if DISM updated)
"C:\Portable Apps\Driver Booster\DriverBoosterPortable.exe"

:: Now install Chocolatey
title Installing Chocolatey
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

title Installing Brave
:choco upgrade -y brave >nul
winget install -e --id Brave.Brave
del /s "c:\Users\%username%\Desktop\Brave.lnk" >nul 2>&1
schtasks /delete /tn BraveUpdateTaskMachineCore /f >nul 2>&1
schtasks /delete /tn BraveUpdateTaskMachineUA /f >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "BraveSoftware Update" /f

title Installing Samsung Printer Driver
"c:\Portable Apps\SamsungUPD3.exe"
del /s "c:\Portable Apps\SamsungUPD3.exe" >nul 2>&1

title Gaming Installs
:choice
set /P c=Is this machine for Gaming? [Y/N]?
if /I "%c%" EQU "Y" goto :yes
if /I "%c%" EQU "N" goto :no
goto :choice
:yes
echo Installing clients - please wait
:choco upgrade -y steam ubisoft-connect epicgameslauncher goggalaxy ea-app >nul 2>&1
winget install -e --id Valve.Steam
winget install -e --id HeroicGamesLauncher.HeroicGamesLauncher
winget install -e --id GOG.Galaxy
winget install -e --id Ubisoft.Connect
winget install -e --id ElectronicArts.EADesktop
:no

title Installing 7Zip
:choco upgrade -y 7zip >nul
winget install -e --id 7zip.7zip

title Installing Notepad++
:choco upgrade -y notepadplusplus.install >nul
winget install -e --id Notepad++.Notepad++

title Installing Redist Files
:choco upgrade -y vcredist140 >nul
winget install -e --id Microsoft.VCRedist.2015+.x64

title Installing OnlyOffice
:choco upgrade -y onlyoffice >nul
winget install -e --id ONLYOFFICE.DesktopEditors
net stop "OnlyOffice Update Service" >nul
sc config "OnlyOffice Update Service" start= disabled >nul

title Installing Putty
:choco upgrade -y putty.install >nul
winget install -e --id PuTTY.PuTTY

title Installing SumatraPDF
:choco upgrade -y sumatrapdf >nul
winget install -e --id SumatraPDF.SumatraPDF
del /s "c:\Users\Public\Desktop\SumatraPDF.lnk" >nul 2>&1

title Installing ImgBurn
:choco upgrade -y imgburn >nul
winget install -e --id LIGHTNINGUK.ImgBurn
del /s "c:\Users\%username%\Desktop\ImgBurn.lnk" >nul 2>&1
del /s "c:\Users\Public\Desktop\ImgBurn.lnk" >nul 2>&1

title Installing KLite Codecs
:choco upgrade -y k-litecodecpack-standard >nul
winget install -e --id CodecGuide.K-LiteCodecPack.Standard
del /s "c:\Users\%username%\Desktop\MPC-HC x64.lnk" >nul 2>&1
del /s "c:\Users\Public\Desktop\mpc-be.lnk" >nul 2>&1
schtasks /delete /tn klcp_update /f >nul 2>&1

title Installing Minecraft Launcher
:choco upgrade -y prismLauncher >nul
winget install -e --id PrismLauncher.PrismLauncher

title Installing LockHunter
:choco upgrade --ignore-checksums -y lockHunter >nul
winget install -e --id CrystalRich.LockHunter
:taskkill /F /IM iexplore.exe /T

title Installing Hashtab
:choco upgrade -y hashtab >nul
winget install -e --id namazso.OpenHashTab

title Installing Privado VPN
:powershell -Command "Invoke-WebRequest https://privadovpn.com/apps/win/Setup_PrivadoVPN_latest.exe -OutFile c:\Privado.exe"
:c:\Privado.exe /s
:del /s "c:\Privado.exe" >nul 2>&1
winget install -e --id PrivadoNetworksAG.PrivadoVPN
:: Fix for VPN adding
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" /v "AssumeUDPEncapsulationContextOnSendRule" /t REG_DWORD /d "2" /f >nul      
del /s "c:\Users\Public\Desktop\PrivadoVPN.lnk" >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "PrivadoVPN" /f

title Installing CBX Shell
"c:\Portable Apps\CBX.exe" /SP /VERYSILENT
del /s "c:\Portable Apps\CBX.exe" >nul 2>&1

title Installing Plasma Screensaver
"c:\Portable Apps\PSS.exe" /s
del /s "c:\Portable Apps\PSS.exe" >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "c:\Windows\system32\plasma.scr" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "600" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "0" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "0" /f >nul

title Installing VideoReDo
REM VideoReDo.TVSuite.6.63.7.836
"c:\Portable Apps\VRD.exe" /s
del /s "c:\Portable Apps\VRD.exe" >nul 2>&1


:: This script is downloaded from Github by the AutoUnattend.XML file on the ISO
@echo off
title Windows Customization - Be patient

:: ==CLEANUPS========================================================================================================================


title Some File Cleaning
"C:\Portable Apps\BleachBit\bleachbit_console.exe" -c --preset >nul 2>&1        ::   MSVCR100 ERROR!!!!
"C:\Portable Apps\ShutUp10\shutup10.exe" "C:\Portable Apps\ShutUp10\OOSU10.cfg" /quiet /nosrp
"C:\Portable Apps\CCleaner\CCleaner64.exe" /AUTO                 :: Runs Ccleaner

:: Run applications (needs manual intervention)
"C:\Portable Apps\CCleaner\CCleaner64.exe" /REGISTRY             :: Opens CCleaner on Registry Screen
"C:\Portable Apps\Wise Disk Cleaner\WiseDiskCleaner.exe"
move "C:\Portable Apps\Wise Disk Cleaner.lnk" "c:\Users\%username%\Desktop\" >nul 2>&1

:: ==REBOOT==++======================================================================================================================

:: Reboot
echo "Rebooting now - enjoy!"
PAUSE
shutdown -r -t 5


==REDUDNANT?=================================


title Installing DirectX
choco upgrade -y directx >nul

:: LanmanWorkstation to Enable Connection to unRAID & Map Z drive
:: reg add HKLM\Software\Policies\Microsoft\Windows\LanmanWorkstation /v AllowInsecureGuestAuth /t REG_DWORD /d "1" /f >nul
:: net use z: \\UBERSERVER\data 2>nul
:: taskkill /f >nul /im explorer.exe  2>nul 
:: start c:\windows\explorer.exe  2>nul 

:: Windows update check and update
:: wuauclt /detectnow
:: wuauclt /updatenow
