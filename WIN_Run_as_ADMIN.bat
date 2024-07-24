@echo off
:check
ping www.google.com -n 1 -w 1000>nul && cls
if errorlevel 1 (echo "This script needs you to connect to internet" & wait 5 & goto check) else (echo "Beginning customizations - be patient")

title Installing Chocolatey
powershell "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" >nul
START "Choco installs" /MIN "choco" "upgrade -y hashtab directx >nul"
REM start "Choco installs" choco_installs.bat
cls

:: Now install Winget & installs

title Installing Winget
powershell -ExecutionPolicy Bypass -Command "irm asheroto.com/winget | iex" >nul
REM powershell -ExecutionPolicy Bypass -Command "./winget-install.ps1" >nul

title Installing Redist Files
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements --id abbodi1406.vcredist >nul

title Installing Brave
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements Brave.Brave >nul
del /s "c:\Users\%username%\Desktop\Brave.lnk" >nul 2>&1

title Installing OnlyOffice
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements ONLYOFFICE.DesktopEditors >nul

title Installing 7Zip
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements 7zip.7zip >nul

title Installing Notepad++
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements Notepad++.Notepad++ >nul

title Installing Putty
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements PuTTY.PuTTY >nul

title Installing SumatraPDF
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements SumatraPDF.SumatraPDF >nul
del /s "c:\Users\%username%\Desktop\SumatraPDF.lnk" >nul 2>&1

title Installing ImgBurn
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements LIGHTNINGUK.ImgBurn >nul
del /s "c:\Users\%username%\Desktop\ImgBurn.lnk" >nul 2>&1
del /s "c:\Users\Public\Desktop\ImgBurn.lnk" >nul 2>&1

title Installing KLite Codecs
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements CodecGuide.K-LiteCodecPack.Standard >nul
del /s "c:\Users\%username%\Desktop\MPC-HC x64.lnk" >nul 2>&1
del /s "c:\Users\Public\Desktop\mpc-be.lnk" >nul 2>&1

title Installing Minecraft Launcher
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements PrismLauncher.PrismLauncher >nul

title Installing UnigetUI
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements SomePythonThings.WingetUIStore >nul
del /s "c:\Users\Public\Desktop\UniGetUI (formerly WingetUI).lnk" >nul 2>&1

title Installing LockHunter
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements CrystalRich.LockHunter >nul 2>&1

move "c:\Portable Apps\Wise Disk Cleaner.lnk" "c:\Users\%username%\Desktop\" >nul 2>&1




title Installing Privado VPN
https://privadovpn.com/apps/win/Setup_PrivadoVPN_latest.exe
OK_PrivadoVPN_latest.exe /s
del /s "c:\Users\Public\Desktop\PrivadoVPN.lnk" >nul 2>&1




title Installing VideoReDo
OK_VideoReDo.TVSuite.6.63.7.836.exe /s

title Installing CBX Shell
OK_CBX-Shell-setup.exe /SP /VERYSILENT

title Installing Plasma Screensaver
OK_Plasma_Screensaver.exe /s

:: Small Page File and No Hibernation   (prob not needed!)
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=16,MaximumSize=2048 >nul
powercfg -h off >nul

::  Set PC network discoverable
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul

:: Tidying up scheduled tasks
schtasks /delete /tn BraveUpdateTaskMachineCore /f >nul 2>&1
schtasks /delete /tn BraveUpdateTaskMachineUA /f >nul 2>&1
schtasks /delete /tn klcp_update /f >nul 2>&1

:: Renaming C Drive to Win Version
ver | find "Version 10"
if %ERRORLEVEL% EQU 0 label C: Win10 >nul
ver | find "Version 11"
if %ERRORLEVEL% EQU 0 label C: Win11 >nul

:: Registry Tweaks

:: Setup Plasma screensaver for 10m
reg add "HKCU\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "c:\Windows\system32\plasma.scr" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "600" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "0" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "0" /f >nul

:: Hide Recently Added items from Start Menu
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /V HideRecentlyAddedApps /T REG_DWORD /D 1 /F

:: LanmanWorkstation to Enable Connection to unRAID
reg add HKLM\Software\Policies\Microsoft\Windows\LanmanWorkstation /v AllowInsecureGuestAuth /t REG_DWORD /d "1" /f >nul
net use z: \\UBERSERVER\data 2>nul
net use y: \\UBERSERVER\isos 2>nul

:: Disable UAC
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f

:: Remove Taskview icon from Taskbar
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\MultiTaskingView\AllUpView" /V Enabled /F
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V ShowTaskViewButton /T REG_DWORD /D 0 /F
REM NOT NEEDED as Bleachbit restarts explorer
REM taskkill /f >nul /im explorer.exe  2>nul 
REM start c:\windows\explorer.exe  2>nul 

:: Auto Arrange Icons On
reg add "HKCU\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" /v FFLAGS /t REG_DWORD /d 1075839525 /f >nul

:: Fix for VPN adding
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" /v "AssumeUDPEncapsulationContextOnSendRule" /t REG_DWORD /d "2" /f >nul      

:: Fix for removing SwapFile.sys for Metro apps
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SwapfileControl" /t REG_DWORD /d "0" /f >nul 

:: Add Network Icon
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /t REG_DWORD /d "0" /f >nul

:: Add This PC Icon
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "0" /f >nul

:: Show File Extensions in Explorer
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f >nul

:: Remove QuickAccess Navigation pane from Explorer
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "HubMode" /t REG_DWORD /d "1" /f >nul

:: Stop Explorer from showing external drives twice
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul

:: Put Shortcut Arrow on Shortcuts back
reg add "HKCR\IE.AssocFile.URL" /v "IsShortcut" /t REG_SZ /d "" /f >nul
reg add "HKCR\InternetShortcut" /v "IsShortcut" /t REG_SZ /d "" /f >nul
reg add "HKCR\lnkfile" /v "IsShortcut" /t REG_SZ /d "" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "29" /t REG_SZ /d "%%windir%%\System32\shell32.dll,-30" /f >nul

:: Reduce Adverts
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d "0" /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d "0" /f >nul

:: Hide Search Icon on Taskbar
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul     

:: W10 Only Logoff Fix
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "StartMenuLogoff" /t REG_DWORD /d "1" /f >nul        
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "HideFastUserSwitching" /t REG_DWORD /d "1" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableLockWorkstation" /t REG_DWORD /d "1" /f >nul




:: Remove 3D Objects (import file to delete reg keys)
reg import Remove-3D-Objects-Folder-W10.reg

[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]
[-HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f >nul





:: Run applications silently :-)
"C:\Portable Apps\ShutUp10\shutup10.exe" "C:\Portable Apps\ShutUp10\OOSU10.cfg" /quiet /nosrp
"C:\Portable Apps\CCleaner\CCleaner64.exe" /AUTO                 :: Runs Ccleaner
"C:\Portable Apps\BleachBit\bleachbit_console.exe" -c --preset >nul 2>&1

:: Run applications (needs manual intervention)
"C:\Portable Apps\CCleaner\CCleaner64.exe" /REGISTRY             :: Opens CCleaner on Registry Screen
"C:\Portable Apps\Wise Disk Cleaner\WiseDiskCleaner.exe"
"SamsungUniversalPrintDriver3.exe"

:: Gaming OPTIONS
:choice
set /P c=Is this machine for Gaming? [Y/N]?
if /I "%c%" EQU "Y" goto :yes
if /I "%c%" EQU "N" goto :no
goto :choice
:yes
echo Installing clients - please wait
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements Valve.Steam >nul
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements Ubisoft.Connect >nul
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements EpicGames.EpicGamesLauncher >nul
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements GOG.Galaxy >nul
winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements ElectronicArts.EADesktop >nul
:no

::  Set PC Name
set /p NUNAME=What name do you want this PC to be called? :
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v "ComputerName" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /v "ComputerName" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t REG_SZ /d %NUNAME% /f >nul

:: Needs some time to install before deleting
del /s "c:\Users\Public\Desktop\UniGetUI (formerly WingetUI).lnk" >nul 2>&1

:: Enables Performance Plan & Disables Sleep
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61

:: Activation time & then Wallpaper
powershell.exe -ex bypass "irm https://get.activated.win | iex"
powershell -ExecutionPolicy Bypass -Command "./WIN_wallpaper.ps1" >nul

:: Reboot if done?
echo "Rebooting now - enjoy!"
shutdown -r -t 5