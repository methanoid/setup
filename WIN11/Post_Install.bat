@echo off
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
echo Setting up for a VM & powercfg -setactive scheme_min
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowSleepOption" /t REG_SZ /d "0" /f >nul
goto done
:desk
echo Setting up for a Desktop & powercfg -setactive scheme_balanced 
goto done
:laptop
echo Setting up for a Laptop & powercfg -setactive scheme_max
REM  Here perhaps add HP Laptop Hotkeys util ?
:done

title Windows Activation
powershell -command "& ([ScriptBlock]::Create((irm https://get.activated.win))) /hwid"

title Gaming Installs
:choice
set /P c=Is this machine for Gaming? [Y/N]?
if /I "%c%" EQU "Y" goto :yes
if /I "%c%" EQU "N" goto :no
goto :choice
:yes
echo Installing clients - please wait
winget install -e -h --id Valve.Steam HeroicGamesLauncher.HeroicGamesLauncher GOG.Galaxy Ubisoft.Connect ElectronicArts.EADesktop
:no

title Silence Any Telemetry
shutup10

echo All Done!

pause

