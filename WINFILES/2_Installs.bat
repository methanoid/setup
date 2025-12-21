o:: ==INSTALLS========================================================================================================================

@echo off
cls
tzutil /s "GMT Standard Time" >nul 2>&1
w32tm /resync /force >nul 2>&1
c:\pttb.exe C:\windows\explorer.exe >nul 2>&1

title Installing Winget
REM Use wsreset -i and then install unigetui from msstore as an ALT
powershell -command "irm https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1 | iex"
echo:

:: Windows10/11 Differences

for /f "tokens=3 delims=." %%i in ('ver') do set build=%%i
if %build% geq 22000 (
  echo Detected Windows 11
  label c: Win11
  title Installing ExplorerPatcher
  winget install -e -h --id valinet.ExplorerPatcher --accept-source-agreements --accept-package-agreements
  reg import c:\ExplorerPatcher.reg
  del /s c:\ExplorerPatcher.reg >nul 2>&1
  taskkill /im explorer.exe /f & start explorer.exe

) else (
  echo Changing to W10 LTSC IOT
  cscript //B slmgr.vbs /ipk QPM6N-7J2WJ-P88HH-P3YRH-YY74H 
  label c: Win10
)

title Installing UniGetUI
winget install -e -h --id XPFFTQ032PTPHF --accept-source-agreements --accept-package-agreements
del /s "c:\Users\Public\Desktop\UniGetUI.lnk"
echo:

title Installing Brave
winget install -e -h --scope machine --id Brave.Brave 
del /s "c:\Users\Administrator\Desktop\Brave.lnk" >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "BraveSoftware Update" /f >nul 2>&1
for /f "tokens=2" %%x in ('schtasks /query /xml ^| findstr Brave') do schtasks /Delete /TN %%x /f >nul 2>&1
sc config "Brave" start=disabled >nul 2>&1
sc config "BraveM" start=disabled >nul 2>&1
c:\pttb.exe C:\Users\Administrator\AppData\Local\BraveSoftware\Brave-Browser\Application\brave.exe >nul 2>&1
c:\pttb.exe C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe >nul 2>&1
del /s c:\pttb.exe >nul 2>&1
echo:

title Remove Edge Cleanly
powershell -file "C:\Die_Edge_Die.ps1"
del C:\Users\Administrator\Desktop\Die_Edge_Die.ps1
powershell -command "Get-ScheduledTask 'MicrosoftEdgeUpdate*' | Unregister-ScheduledTask -Confirm:$false" >nul 2>&1
echo Displaying remaining installed AppX
powershell -command "Get-AppxProvisionedPackage -Online | Format-Table DisplayName, PackageName"

title Installing Driver Store Explorer and Driver Booster
move "c:\Driver Booster" "c:\Program Files\Driver Booster" -y >nul 2>&1
move DriverBooster.lnk c:\Users\Administrator\Desktop\DriverBooster.lnk -y >nul 2>&1 
winget install -e -h --id lostindark.DriverStoreExplorer
echo:

title Installing Redist Files
winget install -e -h --id Microsoft.VCRedist.2015+.x64
echo:

title Installing 7Zip
winget install -e -h --id 7zip.7zip
echo:

title Installing Notepad++
winget install -e -h --id Notepad++.Notepad++
echo:

title Installing OnlyOffice
winget install -e -h --id ONLYOFFICE.DesktopEditors
del /s "c:\Users\Public\Desktop\ONLYOFFICE.lnk" >nul 2>&1
echo:

title Installing Putty
winget install -e -h --id PuTTY.PuTTY
REM powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/Putty.lnk -OutFile C:\Users\Administrator\Desktop\Putty.lnk"
echo:

title Installing SumatraPDF
winget install -e -h --id SumatraPDF.SumatraPDF
del /s "c:\Users\Administrator\Desktop\SumatraPDF.lnk" >nul 2>&1
echo:

title Installing ImgBurn
winget install -e -h --id LIGHTNINGUK.ImgBurn
del /s "c:\Users\Administrator\Desktop\ImgBurn.lnk" >nul 2>&1 & del /s "c:\Users\Public\Desktop\ImgBurn.lnk" >nul 2>&1
echo:

title Installing KLite Codecs
winget install -e -h --id CodecGuide.K-LiteCodecPack.Standard
del /s "c:\Users\Administrator\Desktop\MPC-HC x64.lnk" >nul 2>&1
del /s "c:\Users\Public\Desktop\mpc-be.lnk" >nul 2>&1
schtasks /delete /tn klcp_update /f >nul 2>&1
echo:

title Installing Minecraft Launcher
winget install -e -h --id PrismLauncher.PrismLauncher
echo:

title Installing LockHunter
winget install -e -h --id CrystalRich.LockHunter
taskkill /F /T /IM iexplore.exe >nul 2>&1
taskkill /F /T /IM brave.exe >nul 2>&1
echo:

title Installing Hashtab
winget install -e -h --id namazso.OpenHashTab
echo:

title Installing Surfshark VPN
winget install -e -h --id Surfshark.Surfshark
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" /v "AssumeUDPEncapsulationContextOnSendRule" /t REG_DWORD /d "2" /f >nul 2>&1      
echo:

title Installing Bleachbit
winget install -e -h --id BleachBit.BleachBit
del /s "c:\Users\Administrator\Desktop\BleachBit.lnk" >nul 2>&1
move c:\bleachbit.ini C:\Users\Administrator\AppData\Local\BleachBit\bleachbit.ini -y >nul 2>&1
mkdir "C:\Users\Administrator\AppData\Local\BleachBit\cleaners" >nul 2>&1
copy c:\winapp2.ini C:\Users\Administrator\AppData\Local\BleachBit\cleaners\winapp2.ini -y >nul 2>&1
echo:

title Installing CCleaner
winget install -e -h --id Piriform.CCleaner.Slim
del /s "c:\Users\Public\Desktop\CCleaner.lnk" >nul 2>&1
move c:\ccleaner.ini "C:\Program Files\CCleaner\ccleaner.ini" -y >nul 2>&1
move c:\winapp2.ini "C:\Program Files\CCleaner\winapp2.ini" -y >nul 2>&1
move c:\CCEnhancer.exe "C:\Program Files\CCleaner\CCEnhancer.exe" -y >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "CCleaner Smart Cleaning" /f >nul 2>&1
schtasks /delete /TN "CCleanerCrashReporting" /F >nul 2>&1
powershell -command "Get-ScheduledTask 'CCleaner*' | Unregister-ScheduledTask -Confirm:$false" >nul 2>&1
echo:

title Installing Wise Disk Cleaner
winget install -e -h --id WiseCleaner.WiseDiskCleaner
move c:\config.ini "C:\Program Files (x86)\Wise\Wise Disk Cleaner\config.ini" -y >nul 2>&1
del /s "c:\Users\Public\Desktop\Wise Disk Cleaner.lnk" >nul 2>&1
echo:

title Installing Wise Registry Cleaner
winget install -e -h --id WiseCleaner.WiseRegistryCleaner
del /s "c:\Users\Public\Desktop\Wise Registry Cleaner.lnk" >nul 2>&1
echo:

title Installing Shutup10++
winget install -e -h --id OO-Software.ShutUp10
echo:

title Installing Plasma Screensaver
C:\PSS.exe /S  
del /s C:\PSS.exe >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "c:\Windows\system32\plasma.scr" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "600" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "0" /f >nul 2>&1
echo:

title Installing MKVtoolnix
winget install -e -h --id MoritzBunkus.MKVToolNix
echo:

title Installing CBX Shell
C:\CBX.exe /SP /VERYSILENT
del /s C:\CBX.exe >nul 2>&1
echo:

title Installing Samsung Printer Driver
C:\SamsungUPD3.exe /s
del /s c:\SamsungUPD3.exe >nul 2>&1
echo:

title Installing VideoReDo.TVSuite.6.63.7.836
"C:\VideoReDo.TVSuite.6.63.7.836 - Patched SFX.exe" /s
del /s "c:\Users\Public\Desktop\VideoReDo TVSuite V6.lnk" >nul 2>&1
del /s "C:\VideoReDo.TVSuite.6.63.7.836 - Patched SFX.exe" >nul 2>&1
echo:
