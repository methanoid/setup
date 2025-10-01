o:: ==INSTALLS========================================================================================================================

@echo off
cls
tzutil /s "GMT Standard Time" >nul 2>&1
w32tm /resync /force >nul 2>&1

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
  powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/ExplorerPatcher.reg -OutFile C:\ExplorerPatcher.reg"
  reg import c:\ExplorerPatcher.reg
  del /s c:\ExplorerPatcher.reg >nul 2>&1
  taskkill /im explorer.exe /f & start explorer.exe
  powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/pttb.exe -OutFile C:\pttb.exe"
  c:\pttb.exe C:\windows\explorer.exe >nul 2>&1

) else (
  echo Detected Windows 10
  echo Changing to LTSC IOT Edition
  slmgr.vbs /ipk QPM6N-7J2WJ-P88HH-P3YRH-YY74H 
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
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/pttb.exe -OutFile C:\pttb.exe"
c:\pttb.exe C:\Users\Administrator\AppData\Local\BraveSoftware\Brave-Browser\Application\brave.exe >nul 2>&1
del /s c:\pttb.exe >nul 2>&1
echo:

title Remove Edge Cleanly
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/Die_Edge_Die.ps1 -OutFile C:\Users\Administrator\Desktop\Die_Edge_Die.ps1"
powershell -file "C:\Users\Administrator\Desktop\Die_Edge_Die.ps1"
del C:\Users\Administrator\Desktop\Die_Edge_Die.ps1
powershell -command "Get-ScheduledTask 'MicrosoftEdgeUpdate*' | Unregister-ScheduledTask -Confirm:$false" >nul 2>&1
echo Displaying remaining installed AppX
powershell -command "Get-AppxProvisionedPackage -Online | Format-Table DisplayName, PackageName"

title Installing 7Zip
winget install -e -h --id 7zip.7zip
echo:

title Installing Notepad++
winget install -e -h --id Notepad++.Notepad++
echo:

title Installing Redist Files
winget install -e -h --id Microsoft.VCRedist.2015+.x64
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
del /s "c:\Users\Administrator\Desktop\ImgBurn.lnk" & del /s "c:\Users\Public\Desktop\ImgBurn.lnk" >nul 2>&1
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

title Installing Privado VPN
winget install -e -h --id PrivadoNetworksAG.PrivadoVPN
del /s "c:\Users\Public\Desktop\PrivadoVPN.lnk" >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" /v "AssumeUDPEncapsulationContextOnSendRule" /t REG_DWORD /d "2" /f >nul 2>&1      
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "PrivadoVPN" /f >nul 2>&1
echo:

title Installing Bleachbit
winget install -e -h --id BleachBit.BleachBit
del /s "c:\Users\Administrator\Desktop\BleachBit.lnk" >nul 2>&1
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/bleachbit.ini -OutFile C:\Users\Administrator\AppData\Local\BleachBit\bleachbit.ini"
mkdir "C:\Users\Administrator\AppData\Local\BleachBit\cleaners" >nul 2>&1
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/winapp2.ini -OutFile C:\Users\Administrator\AppData\Local\BleachBit\cleaners\winapp2.ini"
echo:

title Installing CCleaner
winget install -e -h --id Piriform.CCleaner
del /s "c:\Users\Public\Desktop\CCleaner.lnk" >nul 2>&1
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/ccleaner.ini -OutFile 'C:\Program Files\CCleaner\ccleaner.ini'"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/winapp2.ini -OutFile 'C:\Program Files\CCleaner\winapp2.ini'"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/CCEnhancer.exe -OutFile 'C:\Program Files\CCleaner\CCEnhancer.exe'"
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "CCleaner Smart Cleaning" /f >nul 2>&1
schtasks /delete /TN "CCleanerCrashReporting" /F >nul 2>&1
powershell -command "Get-ScheduledTask 'CCleaner*' | Unregister-ScheduledTask -Confirm:$false" >nul 2>&1
echo:

title Installing Wise Disk Cleaner
winget install -e -h --id WiseCleaner.WiseDiskCleaner
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/config.ini -OutFile 'C:\Program Files (x86)\Wise\Wise Disk Cleaner\config.ini'"
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
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/PSS.exe -OutFile C:\Users\Administrator\Desktop\PSS.exe"
C:\Users\Administrator\Desktop\PSS.exe /S  
del /s C:\Users\Administrator\Desktop\PSS.exe >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "c:\Windows\system32\plasma.scr" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "600" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "0" /f >nul 2>&1
echo:

title Installing MKVtoolnix
winget install -e -h --id MoritzBunkus.MKVToolNix
echo:

title Installing CBX Shell
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/CBX.exe -OutFile C:\Users\Administrator\Desktop\CBX.exe"
C:\Users\Administrator\Desktop\CBX.exe /SP /VERYSILENT
del /s C:\Users\Administrator\Desktop\CBX.exe >nul 2>&1
echo:

title Putting DriverBooster on Desktop
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/DB.exe -OutFile C:\Users\Administrator\Desktop\DB.exe"
C:\Users\Administrator\Desktop\DB.exe -Y
del C:\Users\Administrator\Desktop\DB.exe >nul 2>&1
echo:

title Installing Samsung Printer Driver
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/UPD.exe -OutFile C:\UPD.exe"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/UPD.7z.001 -OutFile C:\UPD.7z.001"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/UPD.7z.002 -OutFile C:\UPD.7z.002"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/UPD.7z.002 -OutFile C:\UPD.7z.003"
C:\UPD.exe -oC:\ -y & del /s c:\UPD*.* >nul 2>&1
C:\SamsungUPD3.exe /s & del /s c:\SamsungUPD3.exe >nul 2>&1
echo:

title Installing VideoReDo.TVSuite.6.63.7.836
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/VRD_Split.exe -OutFile C:\VRD_Split.exe"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/VRD_Split.7z.001 -OutFile C:\VRD_Split.7z.001"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/VRD_Split.7z.002 -OutFile C:\VRD_Split.7z.002"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/VRD_Split.7z.003 -OutFile C:\VRD_Split.7z.003"
C:\VRD_Split.exe -oC:\ -y
"C:\VideoReDo.TVSuite.6.63.7.836 - Patched SFX.exe" /s
del /s "c:\Users\Public\Desktop\VideoReDo TVSuite V6.lnk" >nul 2>&1
del /s "C:\VRD*.*" >nul 2>&1
del /s "C:\VideoReDo.TVSuite.6.63.7.836 - Patched SFX.exe" >nul 2>&1
echo:
