@echo off
title Installs

:check
ping www.google.com -n 1 -w 1000>nul && cls
if errorlevel 1 (echo "This script needs you to connect to internet" & wait 5 & goto check) else (echo Beginning installs - be patient)

:: ==INSTALLS========================================================================================================================

title Installing Winget
powershell -command "Install-PackageProvider -Name NuGet -Force | Out-Null"
powershell -command "Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null"
powershell -command "Repair-WinGetPackageManager"

title Installing UniGetUI
winget install -e -h --id XPFFTQ032PTPHF --accept-source-agreements --accept-package-agreements

title Installing Brave
winget install -e -h --id Brave.Brave
del /s "c:\Users\%username%\Desktop\Brave.lnk" >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "BraveSoftware Update" /f
for /f "tokens=1 delims=," %%x in ('schtasks /query /fo csv ^| find "Brave"') do schtasks /Delete /TN %%x /F
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/pttb.exe -OutFile C:\pttb.exe"
c:\pttb.exe C:\Users\Administrator\AppData\Local\BraveSoftware\Brave-Browser\Application\brave.exe
del c:\pttb.exe

title Installing NVcleanstall
winget install -e -h --id TechPowerUp.NVCleanstall

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

title Installing SumatraPDF
winget install -e -h --id SumatraPDF.SumatraPDF
del /s "c:\Users\Administrator\Desktop\SumatraPDF.lnk" >nul 2>&1

title Installing ImgBurn
winget install -e -h --id LIGHTNINGUK.ImgBurn
del /s "c:\Users\%username%\Desktop\ImgBurn.lnk" & del /s "c:\Users\Public\Desktop\ImgBurn.lnk" & cls

title Installing KLite Codecs
winget install -e -h --id CodecGuide.K-LiteCodecPack.Standard
del /s "c:\Users\%username%\Desktop\MPC-HC x64.lnk" & del /s "c:\Users\Public\Desktop\mpc-be.lnk" & schtasks /delete /tn klcp_update /f & cls

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
mkdir "C:\Users\Administrator\AppData\Local\BleachBit\cleaners"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/winapp2.ini -OutFile C:\Users\Administrator\AppData\Local\BleachBit\cleaners\winapp2.ini"

title Installing CCleaner
winget install -e -h --id Piriform.CCleaner
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/ccleaner.ini -OutFile 'C:\Program Files\CCleaner\ccleaner.ini'"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/winapp2.ini -OutFile 'C:\Program Files\CCleaner\winapp2.ini'"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/CCEnhancer.exe -OutFile 'C:\Program Files\CCleaner\CCEnhancer.exe'"
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "CCleaner Smart Cleaning" /f >nul
for /f "tokens=1 delims=," %%x in ('schtasks /query /fo csv ^| find "CCleaner"') do schtasks /Delete /TN %%x /F

title Installing Wise Disk Cleaner
winget install -e -h --id WiseCleaner.WiseDiskCleaner
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/config.ini -OutFile 'C:\Program Files (x86)\Wise\Wise Disk Cleaner\config.ini'"

title Installing Wise Force Deleter
winget install -e -h --id WiseCleaner.WiseForceDeleter

title Installing Wise Registry Cleaner
winget install -e -h --id WiseCleaner.WiseRegistryCleaner

title Installing Shutup10++
winget install -e -h --id OO-Software.ShutUp10

title Installing Plasma Screensaver
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/PSS.exe -OutFile C:\Users\Administrator\Desktop\PSS.exe"
C:\Users\Administrator\Desktop\PSS.exe /S
del C:\Users\Administrator\Desktop\PSS.exe >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "c:\Windows\system32\plasma.scr" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "600" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "0" /f >nul
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "0" /f >nul

title Installing MKVtoolnix
winget install -e -h --id MoritzBunkus.MKVToolNix
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/MKVToolnix.lnk -OutFile C:\Users\Administrator\Desktop\MKVtoolnix.lnk"

title Installing CBX Shell
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/CBX.exe -OutFile C:\Users\Administrator\Desktop\CBX.exe"
C:\Users\Administrator\Desktop\CBX.exe /SP /VERYSILENT
del C:\Users\Administrator\Desktop\CBX.exe >nul 2>&1

title Installing VideoReDo
REM VideoReDo.TVSuite.6.63.7.836
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/VRD_Split.exe -OutFile C:\VRD_Split.exe"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/VRD_Split.7z.001 -OutFile C:\VRD_Split.7z.001"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/VRD_Split.7z.002 -OutFile C:\VRD_Split.7z.002"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/VRD_Split.7z.003 -OutFile C:\VRD_Split.7z.003"
C:\VRD_Split.exe -oC:\ -y
"C:\VideoReDo.TVSuite.6.63.7.836 - Patched SFX.exe" /s
del /s "C:\VRD*.*" >nul 2>&1
del "C:\VideoReDo.TVSuite.6.63.7.836 - Patched SFX.exe" >nul 2>&1

title Installing Samsung Printer Driver
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/SPTR.exe -OutFile C:\SPTR.exe"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/SPTR.7z.001 -OutFile C:\SPTR.7z.001"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/SPTR.7z.002 -OutFile C:\SPTR.7z.002"
C:\SPTR.exe -oC:\ -y
C:\PTR.exe /s
del /s "C:\*PTR*.*" >nul 2>&1

title Putting DriverBooster on Desktop
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/DB.exe -OutFile C:\Users\Administrator\Desktop\DB.exe"
C:\Users\Administrator\Desktop\DB.exe -Y
del C:\Users\Administrator\Desktop\DB.exe

title Installing ExplorerPatcher
winget install -e -h --id valinet.ExplorerPatcher
:: REG FILE FROM GITHUB, INSTALL SETTINGS, DELETE?

title Remove Edge Cleanly
powershell -command 'iex "&{$(irm https://cdn.jsdelivr.net/gh/he3als/EdgeRemover@main/get.ps1)} -UninstallEdge -RemoveEdgeData -InstallWebView"'
echo Displaying remaining installed AppX
powershell -command "Get-AppxProvisionedPackage -Online | Format-Table DisplayName, PackageName"

pause
