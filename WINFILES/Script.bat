:: == WINDOWS CUSTOMIZER SCRIPT for WINDOWS 10 & 11 LTSC =============================================================================

echo "Make sure updates have been applied BEFORE running this script"
pause
cls

:: ==TWEAKS===========================================================================================================================
@echo off
title Tweaks

:check
ping www.google.com -n 1 -w 1000>nul && cls
if errorlevel 1 (echo "This script needs you to connect to internet" & wait 10 & goto check) else (echo Starting)
attrib -R c:\CUSTOM /s >nul 2>&1

title Switch to Dark mode system-wide
powershell -command "Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force;"
powershell -command "Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force;"
taskkill /im explorer.exe /f >nul 2>&1
start explorer.exe >nul 2>&1
rd /s /q "c:\Perflogs" >nul 2>&1
cls

title Set Sharing for unRAID
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul 2>&1
powershell -command "Set-NetFirewallRule -Group '*-32752*' -Enabled 'True'"
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul 2>&1
reg add HKLM\Software\Policies\Microsoft\Windows\LanmanWorkstation /v AllowInsecureGuestAuth /t REG_DWORD /d "1" /f >nul 2>&1
reg add HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters /v EnableSecuritySignature /t REG_DWORD /d "0" /f >nul 2>&1
sc config "LanmanWorkstation" start=automatic >nul 2>&1     REM Needed for Samba Share
cls

title More Reg Tweaks
echo Hide Recommended Section and Recently Added Apps
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecentlyAddedApps" /t REG_DWORD /d "1" /f >nul 2>&1
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

echo Disable System Restore
reg add "HKLM\Software\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableSR" /t REG_DWORD /d "1" /f
schtasks /Change /TN "Microsoft\Windows\SystemRestore\SR" /Disable >nul 2>&1
vssadmin Resize ShadowStorage /For=C: /On=C: /Maxsize=320MB >nul 2>&1
cls

echo Disable Delivery Optimization
powershell -command 'Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" ` -Name "DODownloadMode" -Value 9'
cls

:: ==INSTALLS========================================================================================================================

@echo off
cls
tzutil /s "GMT Standard Time" >nul 2>&1
w32tm /resync /force >nul 2>&1
c:\CUSTOM\pttb.exe C:\windows\explorer.exe >nul 2>&1

title Installing Winget
REM Use wsreset -i and then install unigetui from msstore as an ALT
powershell -command "irm https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1 | iex"
wait 2
cls

:: Windows10/11 Differences

for /f "tokens=3 delims=." %%i in ('ver') do set build=%%i
if %build% geq 22000 (
  echo Detected Windows 11
  label c: Win11
  title Installing ExplorerPatcher
  winget install -e -h --id valinet.ExplorerPatcher --accept-source-agreements --accept-package-agreements
  reg import c:\CUSTOM\ExplorerPatcher.reg
  taskkill /im explorer.exe /f & start explorer.exe
  title Installing WMIC
  powershell -command "add-WindowsCapability -online -name WMIC"

) else (
  echo Changing to W10 LTSC IOT
  cscript //B slmgr.vbs /ipk QPM6N-7J2WJ-P88HH-P3YRH-YY74H 
  label c: Win10
)
del /s c:\CUSTOM\ExplorerPatcher.reg >nul 2>&1
cls

title Setting PageFile size
wmic computersystem where name="NEW_INSTALL" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=512,MaximumSize=2048
cls

title Installing UniGetUI
winget install -e -h --id XPFFTQ032PTPHF --accept-source-agreements --accept-package-agreements
del /s "c:\Users\Public\Desktop\UniGetUI.lnk"
cls

title Installing Brave
winget install -e -h --scope machine --id Brave.Brave 
del /s "c:\Users\Public\Desktop\Brave.lnk" >nul 2>&1
del /s "c:\Users\Administrator\Desktop\Brave.lnk" >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "BraveSoftware Update" /f >nul 2>&1
for /f "tokens=2" %%x in ('schtasks /query /xml ^| findstr Brave') do schtasks /Delete /TN %%x /f >nul 2>&1
sc config "Brave" start=disabled >nul 2>&1
sc config "BraveM" start=disabled >nul 2>&1
c:\CUSTOM\pttb.exe "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" >nul 2>&1
del /s c:\CUSTOM\pttb.exe >nul 2>&1
c:\CUSTOM\SetUserFTA.exe HKLM "Brave"
taskkill /F /T /IM SetUserFTAexe >nul 2>&1
del /s c:\CUSTOM\SetUserFTA.exe >nul 2>&1
cls

REM title Remove Edge Cleanly
REM powershell -file "C:\Die_Edge_Die.ps1"
REM del C:\Users\Administrator\Desktop\Die_Edge_Die.ps1
REM powershell -command "Get-ScheduledTask 'MicrosoftEdgeUpdate*' | Unregister-ScheduledTask -Confirm:$false" >nul 2>&1
del /s "c:\Users\Public\Desktop\Microsoft Edge.lnk" >nul 2>&1
del /s "c:\Users\Administrator\Desktop\Microsoft Edge.lnk" >nul 2>&1
REM echo Displaying remaining installed AppX
REM powershell -command "Get-AppxProvisionedPackage -Online | Format-Table DisplayName, PackageName"

title Installing Driver Store Explorer and Driver Booster
move "c:\CUSTOM\Driver Booster" "c:\Program Files\" >nul 2>&1
move c:\CUSTOM\DriverBooster.lnk c:\Users\Administrator\Desktop\ >nul 2>&1 
winget install -e -h --id lostindark.DriverStoreExplorer
cls

title Installing Redist Files
winget install -e -h --id Microsoft.VCRedist.2015+.x64
cls

title Installing 7Zip
winget install -e -h --id 7zip.7zip
cls

title Installing Notepad++
winget install -e -h --id Notepad++.Notepad++
cls

title Installing OnlyOffice
winget install -e -h --id ONLYOFFICE.DesktopEditors
del /s "c:\Users\Public\Desktop\ONLYOFFICE.lnk" >nul 2>&1
cls

title Installing Putty
winget install -e -h --id PuTTY.PuTTY
move c:\CUSTOM\Putty.lnk c:\Users\Administrator\Desktop\ >nul 2>&1 
cls

title Installing SumatraPDF
winget install -e -h --id SumatraPDF.SumatraPDF
del /s "c:\Users\Administrator\Desktop\SumatraPDF.lnk" >nul 2>&1
cls

title Installing ImgBurn
winget install -e -h --id LIGHTNINGUK.ImgBurn
del /s "c:\Users\Administrator\Desktop\ImgBurn.lnk" >nul 2>&1 & del /s "c:\Users\Public\Desktop\ImgBurn.lnk" >nul 2>&1
cls

title Installing KLite Codecs
winget install -e -h --id CodecGuide.K-LiteCodecPack.Standard
del /s "c:\Users\Administrator\Desktop\MPC-HC x64.lnk" >nul 2>&1
del /s "c:\Users\Public\Desktop\mpc-be.lnk" >nul 2>&1
schtasks /delete /tn klcp_update /f >nul 2>&1
cls

title Installing Minecraft Launcher
winget install -e -h --id PrismLauncher.PrismLauncher
cls

title Installing LockHunter
winget install -e -h --id CrystalRich.LockHunter
taskkill /F /T /IM brave.exe >nul 2>&1
cls

title Installing Hashtab
winget install -e -h --id namazso.OpenHashTab
cls

title Installing Surfshark VPN
winget install -e -h --id Surfshark.Surfshark
del /s "c:\Users\Public\Desktop\Surfshark.lnk" >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" /v "AssumeUDPEncapsulationContextOnSendRule" /t REG_DWORD /d "2" /f >nul 2>&1      
taskkill /F /T /IM surfshark.exe >nul 2>&1
cls

title Installing Bleachbit
winget install -e -h --id BleachBit.BleachBit
del /s "c:\Users\Administrator\Desktop\BleachBit.lnk" >nul 2>&1
move c:\CUSTOM\bleachbit.ini C:\Users\Administrator\AppData\Local\BleachBit\ >nul 2>&1
mkdir "C:\Users\Administrator\AppData\Local\BleachBit\cleaners" >nul 2>&1
copy c:\CUSTOM\winapp2.ini C:\Users\Administrator\AppData\Local\BleachBit\cleaners\ >nul 2>&1
cls

title Installing CCleaner
winget install -e -h --id Piriform.CCleaner.Slim
del /s "c:\Users\Public\Desktop\CCleaner.lnk" >nul 2>&1
move c:\CUSTOM\ccleaner.ini "C:\Program Files\CCleaner\" >nul 2>&1
move c:\CUSTOM\winapp2.ini "C:\Program Files\CCleaner\" >nul 2>&1
move c:\CUSTOM\CCEnhancer.exe "C:\Program Files\CCleaner\" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "CCleaner Smart Cleaning" /f >nul 2>&1
schtasks /delete /TN "CCleanerCrashReporting" /F >nul 2>&1
powershell -command "Get-ScheduledTask 'CCleaner*' | Unregister-ScheduledTask -Confirm:$false" >nul 2>&1
cls

title Installing Wise Disk Cleaner
winget install -e -h --id WiseCleaner.WiseDiskCleaner
move c:\CUSTOM\config.ini "C:\Program Files (x86)\Wise\Wise Disk Cleaner\" >nul 2>&1
del /s "c:\Users\Public\Desktop\Wise Disk Cleaner.lnk" >nul 2>&1
cls

title Installing Wise Registry Cleaner
winget install -e -h --id WiseCleaner.WiseRegistryCleaner
del /s "c:\Users\Public\Desktop\Wise Registry Cleaner.lnk" >nul 2>&1
cls

title Installing Shutup10++
winget install -e -h --id OO-Software.ShutUp10
move c:\CUSTOM\ooshutup10.cfg "C:\Users\Administrator\AppData\Local\OO Software\OO ShutUp10\"  >nul 2>&1
cls

title Installing Plasma Screensaver
C:\CUSTOM\PSS.exe /S  
del /s C:\CUSTOM\PSS.exe >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "c:\Windows\system32\plasma.scr" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "600" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "0" /f >nul 2>&1
cls

title Installing MKVtoolnix
winget install -e -h --id MoritzBunkus.MKVToolNix
cls

title Installing CBX Shell
C:\CUSTOM\CBX.exe /SP /VERYSILENT
del /s C:\CUSTOM\CBX.exe >nul 2>&1
cls

title Installing Samsung Printer Driver
C:\CUSTOM\SamsungUPD3.exe /s
del /s c:\CUSTOM\SamsungUPD3.exe >nul 2>&1
cls

title Installing VideoReDo.TVSuite.6.63.7.836
"C:\CUSTOM\VideoReDo.TVSuite.6.63.7.836 - Patched SFX.exe" /s
del /s "c:\Users\Public\Desktop\VideoReDo TVSuite V6.lnk" >nul 2>&1
del /s "C:\CUSTOM\VideoReDo.TVSuite.6.63.7.836 - Patched SFX.exe" >nul 2>&1
cls

REM title DotNet Framework 3.5
REM Dism /online /Enable-Feature /FeatureName:NetFx3
REM c:\d3dx43\DXsetup.exe /silent
REM del c:\d3dx43 /s  >nul 2>&1
cls

:: ==CLEANUPS========================================================================================================================

@echo off
cls
title More File Cleaning
:: Run applications (needs manual intervention)
"C:\Users\Administrator\AppData\Roaming\BleachBit\bleachbit_console.exe" -c --preset >nul 2>&1
"C:\Program Files\CCleaner\CCleaner64.exe" /REGISTRY             :: Opens CCleaner on Registry Screen
"C:\Program Files (x86)\Wise\Wise Disk Cleaner\WiseDiskCleaner.exe"
del /f /q c:\inetpub >nul 2>&1
reg import c:\CUSTOM\Restore_Photo_Viewer.reg >nul 2>&1
del /f /q c:\CUSTOM\Restore_Photo_Viewer.reg >nul 2>&1
reg import c:\CUSTOM\BlockKeylogger.reg >nul 2>&1
del /f /q c:\CUSTOM\BlockKeylogger.reg >nul 2>&1
cls

:: Windows10/11 Differences

for /f "tokens=3 delims=." %%i in ('ver') do set build=%%i
if %build% geq 22000 (
  echo Detected Windows 11
  title Installing W11 Updates
  rem
  
) else (
  echo Changing to W10 LTSC IOT
  title Installing W10 Updates
  rem WUSA /QUIET /NORESTART c:\CUSTOM\windows10.0-kb5071546-x64.MSU
  del /f /q c:\CUSTOM\*.MSU >nul 2>&1
  cls
)

title Silence Any Telemetry
move c:\CUSTOM\ooshutup10.cfg C:\Users\Administrator\AppData\Local\Microsoft\WinGet\Packages\OO-Software.ShutUp10_Microsoft.Winget.Source_8wekyb3d8bbwe\ >nul 2>&1 
shutup10 ooshutup10.cfg /quiet
cls

title Services Tweaks
echo Service tweaks running
:: Services lifted from CTT
sc config "Audiosrv" start=automatic >nul 2>&1
sc config "BFE" start=automatic >nul 2>&1
sc config "BrokerInfrastructure" start=automatic >nul 2>&1
sc config "BthHFSrv" start=automatic >nul 2>&1
sc config "CDPUserSvc_*" start=automatic >nul 2>&1
sc config "CoreMessagingRegistrar" start=automatic >nul 2>&1
sc config "CryptSvc" start=automatic >nul 2>&1
sc config "DcomLaunch" start=automatic >nul 2>&1
sc config "Dhcp" start=automatic >nul 2>&1
sc config "DispBrokerDesktopSvc" start=automatic >nul 2>&1
sc config "Dnscache" start=automatic >nul 2>&1
sc config "DPS" start=automatic >nul 2>&1
sc config "DusmSvc" start=automatic >nul 2>&1
sc config "EventLog" start=automatic >nul 2>&1
sc config "EventSystem" start=automatic >nul 2>&1
sc config "FontCache" start=automatic >nul 2>&1
sc config "gpsvc" start=automatic >nul 2>&1
sc config "iphlpsvc" start=automatic >nul 2>&1
sc config "LanmanServer" start=automatic >nul 2>&1
sc config "LSM" start=automatic >nul 2>&1
sc config "MpsSvc" start=automatic >nul 2>&1
sc config "mpssvc" start=automatic >nul 2>&1
sc config "nsi" start=automatic >nul 2>&1
sc config "OneSyncSvc_*" start=automatic >nul 2>&1
sc config "Power" start=automatic >nul 2>&1
sc config "ProfSvc" start=automatic >nul 2>&1
sc config "RpcEptMapper" start=automatic >nul 2>&1
sc config "RpcSs" start=automatic >nul 2>&1
sc config "SamSs" start=automatic >nul 2>&1
sc config "Schedule" start=automatic >nul 2>&1
sc config "SENS" start=automatic >nul 2>&1
sc config "SgrmBroker" start=automatic >nul 2>&1
sc config "ShellHWDetection" start=automatic >nul 2>&1
sc config "Spooler" start=automatic >nul 2>&1
sc config "SysMain" start=automatic >nul 2>&1
sc config "SystemEventsBroker" start=automatic >nul 2>&1
sc config "Themes" start=automatic >nul 2>&1
sc config "tiledatamodelsvc" start=automatic >nul 2>&1
sc config "TrkWks" start=automatic >nul 2>&1
sc config "UserManager" start=automatic >nul 2>&1
sc config "VGAuthService" start=automatic >nul 2>&1
sc config "VMTools" start=automatic >nul 2>&1
sc config "Wcmsvc" start=automatic >nul 2>&1
sc config "webthreatdefUsersvc_*" start=automatic >nul 2>&1
sc config "WinDefend" start=automatic >nul 2>&1
sc config "Winmgmt" start=automatic >nul 2>&1
sc config "WpnUserService_*" start=automatic >nul 2>&1
sc config "DoSvc" start=delayed-auto >nul 2>&1
sc config "MapsBroker" start=delayed-auto >nul 2>&1
sc config "sppsvc" start=delayed-auto >nul 2>&1
sc config "wscsvc" start=delayed-auto >nul 2>&1
sc config "WSearch" start=delayed-auto >nul 2>&1
sc config "ALG" start=demand >nul 2>&1
sc config "AppIDSvc" start=demand >nul 2>&1
sc config "Appinfo" start=demand >nul 2>&1
sc config "AppMgmt" start=demand >nul 2>&1
sc config "AppReadiness" start=demand >nul 2>&1
sc config "AppXSvc" start=demand >nul 2>&1
sc config "autotimesvc" start=demand >nul 2>&1
sc config "AxInstSV" start=demand >nul 2>&1
sc config "BcastDVRUserService_*" start=demand >nul 2>&1
sc config "BDESVC" start=demand >nul 2>&1
sc config "BluetoothUserService_*" start=demand >nul 2>&1
sc config "Browser" start=demand >nul 2>&1
sc config "BTAGService" start=demand >nul 2>&1
sc config "bthserv" start=demand >nul 2>&1
sc config "camsvc" start=demand >nul 2>&1
sc config "CaptureService_*" start=demand >nul 2>&1
sc config "CDPSvc" start=demand >nul 2>&1
sc config "CertPropSvc" start=demand >nul 2>&1
sc config "ClipSVC" start=demand >nul 2>&1
sc config "cloudidsvc" start=demand >nul 2>&1
sc config "COMSysApp" start=demand >nul 2>&1
sc config "ConsentUxUserSvc_*" start=demand >nul 2>&1
sc config "CredentialEnrollmentManagerUserSvc_*" start=demand >nul 2>&1
sc config "CscService" start=demand >nul 2>&1
sc config "DcpSvc" start=demand >nul 2>&1
sc config "dcsvc" start=demand >nul 2>&1
sc config "defragsvc" start=demand >nul 2>&1
sc config "DeviceAssociationBrokerSvc_*" start=demand >nul 2>&1
sc config "DeviceInstall" start=demand >nul 2>&1
sc config "DevicePickerUserSvc_*" start=demand >nul 2>&1
sc config "DevicesFlowUserSvc_*" start=demand >nul 2>&1
sc config "DevQueryBroker" start=demand >nul 2>&1
sc config "diagnosticshub.standardcollector.service" start=demand >nul 2>&1
sc config "diagsvc" start=demand >nul 2>&1
sc config "DisplayEnhancementService" start=demand >nul 2>&1
sc config "DmEnrollmentSvc" start=demand >nul 2>&1
sc config "dmwappushservice" start=demand >nul 2>&1
sc config "dot3svc" start=demand >nul 2>&1
sc config "DsmSvc" start=demand >nul 2>&1
sc config "DsSvc" start=demand >nul 2>&1
sc config "EapHost" start=demand >nul 2>&1
sc config "edgeupdate" start=disabled >nul 2>&1
sc config "edgeupdatem" start=disabled >nul 2>&1
sc config "EFS" start=demand >nul 2>&1
sc config "embeddedmode" start=demand >nul 2>&1
sc config "EntAppSvc" start=demand >nul 2>&1
sc config "Fax" start=demand >nul 2>&1
sc config "fdPHost" start=demand >nul 2>&1
sc config "FDResPub" start=demand >nul 2>&1
sc config "fhsvc" start=demand >nul 2>&1
sc config "FrameServer" start=demand >nul 2>&1
sc config "FrameServerMonitor" start=demand >nul 2>&1
sc config "GraphicsPerfSvc" start=demand >nul 2>&1
sc config "hidserv" start=demand >nul 2>&1
sc config "HomeGroupListener" start=demand >nul 2>&1
sc config "HomeGroupProvider" start=demand >nul 2>&1
sc config "HvHost" start=demand >nul 2>&1
sc config "icssvc" start=demand >nul 2>&1
sc config "IEEtwCollectorService" start=demand >nul 2>&1
sc config "InstallService" start=demand >nul 2>&1
sc config "InventorySvc" start=demand >nul 2>&1
sc config "IpxlatCfgSvc" start=demand >nul 2>&1
sc config "KtmRm" start=demand >nul 2>&1
sc config "lfsvc" start=demand >nul 2>&1
sc config "LicenseManager" start=demand >nul 2>&1
sc config "lltdsvc" start=demand >nul 2>&1
sc config "lmhosts" start=demand >nul 2>&1
sc config "LxpSvc" start=demand >nul 2>&1
sc config "McpManagementService" start=demand >nul 2>&1
sc config "MessagingService_*" start=demand >nul 2>&1
sc config "MicrosoftEdgeElevationService" start=demand >nul 2>&1
sc config "MixedRealityOpenXRSvc" start=demand >nul 2>&1
sc config "MSDTC" start=demand >nul 2>&1
sc config "MSiSCSI" start=demand >nul 2>&1
sc config "msiserver" start=demand >nul 2>&1
sc config "MsKeyboardFilter" start=demand >nul 2>&1
sc config "NaturalAuthentication" start=demand >nul 2>&1
sc config "NcaSvc" start=demand >nul 2>&1
sc config "NcbService" start=demand >nul 2>&1
sc config "NcdAutoSetup" start=demand >nul 2>&1
sc config "Netman" start=demand >nul 2>&1
sc config "netprofm" start=demand >nul 2>&1
sc config "NetSetupSvc" start=demand >nul 2>&1
sc config "NgcCtnrSvc" start=demand >nul 2>&1
sc config "NgcSvc" start=demand >nul 2>&1
sc config "NPSMSvc_*" start=demand >nul 2>&1
sc config "p2pimsvc" start=demand >nul 2>&1
sc config "p2psvc" start=demand >nul 2>&1
sc config "P9RdrService_*" start=demand >nul 2>&1
sc config "PeerDistSvc" start=demand >nul 2>&1
sc config "PenService_*" start=demand >nul 2>&1
sc config "perceptionsimulation" start=demand >nul 2>&1
sc config "PerfHost" start=demand >nul 2>&1
sc config "PhoneSvc" start=demand >nul 2>&1
sc config "PimIndexMaintenanceSvc_*" start=demand >nul 2>&1
sc config "pla" start=demand >nul 2>&1
sc config "PlugPlay" start=demand >nul 2>&1
sc config "PNRPAutoReg" start=demand >nul 2>&1
sc config "PNRPsvc" start=demand >nul 2>&1
sc config "PolicyAgent" start=demand >nul 2>&1
sc config "PrintNotify" start=demand >nul 2>&1
sc config "PrintWorkflowUserSvc_*" start=demand >nul 2>&1
sc config "PushToInstall" start=demand >nul 2>&1
sc config "QWAVE" start=demand >nul 2>&1
sc config "RasAuto" start=demand >nul 2>&1
sc config "RetailDemo" start=demand >nul 2>&1
sc config "RmSvc" start=demand >nul 2>&1
sc config "RpcLocator" start=demand >nul 2>&1
sc config "SCardSvr" start=demand >nul 2>&1
sc config "ScDeviceEnum" start=demand >nul 2>&1
sc config "SCPolicySvc" start=demand >nul 2>&1
sc config "SDRSVC" start=demand >nul 2>&1
sc config "seclogon" start=demand >nul 2>&1
sc config "SecurityHealthService" start=demand >nul 2>&1
sc config "SEMgrSvc" start=demand >nul 2>&1
sc config "Sense" start=demand >nul 2>&1
sc config "SensorDataService" start=demand >nul 2>&1
sc config "SensorService" start=demand >nul 2>&1
sc config "SensrSvc" start=demand >nul 2>&1
sc config "SessionEnv" start=demand >nul 2>&1
sc config "SharedAccess" start=demand >nul 2>&1
sc config "SharedRealitySvc" start=demand >nul 2>&1
sc config "smphost" start=demand >nul 2>&1
sc config "SmsRouter" start=demand >nul 2>&1
sc config "SNMPTRAP" start=demand >nul 2>&1
sc config "SNMPTrap" start=demand >nul 2>&1
sc config "spectrum" start=demand >nul 2>&1
sc config "SSDPSRV" start=demand >nul 2>&1
sc config "StiSvc" start=demand >nul 2>&1
sc config "StorSvc" start=demand >nul 2>&1
sc config "svsvc" start=demand >nul 2>&1
sc config "swprv" start=demand >nul 2>&1
sc config "TabletInputService" start=demand >nul 2>&1
sc config "TapiSrv" start=demand >nul 2>&1
sc config "TextInputManagementService" start=demand >nul 2>&1
sc config "TieringEngineService" start=demand >nul 2>&1
sc config "TimeBroker" start=demand >nul 2>&1
sc config "TimeBrokerSvc" start=demand >nul 2>&1
sc config "TokenBroker" start=demand >nul 2>&1
sc config "TroubleshootingSvc" start=demand >nul 2>&1
sc config "TrustedInstaller" start=demand >nul 2>&1
sc config "UdkUserSvc_*" start=demand >nul 2>&1
sc config "UI0Detect" start=demand >nul 2>&1
sc config "UmRdpService" start=demand >nul 2>&1
sc config "UnistoreSvc_*" start=demand >nul 2>&1
sc config "upnphost" start=demand >nul 2>&1
sc config "UserDataSvc_*" start=demand >nul 2>&1
sc config "UsoSvc" start=demand >nul 2>&1
sc config "VacSvc" start=demand >nul 2>&1
sc config "vds" start=demand >nul 2>&1
sc config "vm3dservice" start=demand >nul 2>&1
sc config "vmicguestinterface" start=demand >nul 2>&1
sc config "vmicheartbeat" start=demand >nul 2>&1
sc config "vmickvpexchange" start=demand >nul 2>&1
sc config "vmicrdv" start=demand >nul 2>&1
sc config "vmicshutdown" start=demand >nul 2>&1
sc config "vmictimesync" start=demand >nul 2>&1
sc config "vmicvmsession" start=demand >nul 2>&1
sc config "vmicvss" start=demand >nul 2>&1
sc config "vmvss" start=demand >nul 2>&1
sc config "VSS" start=demand >nul 2>&1
sc config "W32Time" start=demand >nul 2>&1
sc config "WaaSMedicSvc" start=demand >nul 2>&1
sc config "WalletService" start=demand >nul 2>&1
sc config "WarpJITSvc" start=demand >nul 2>&1
sc config "wbengine" start=demand >nul 2>&1
sc config "WbioSrvc" start=demand >nul 2>&1
sc config "wcncsvc" start=demand >nul 2>&1
sc config "WcsPlugInService" start=demand >nul 2>&1
sc config "WdiServiceHost" start=demand >nul 2>&1
sc config "WdiSystemHost" start=demand >nul 2>&1
sc config "WdNisSvc" start=demand >nul 2>&1
sc config "WebClient" start=demand >nul 2>&1
sc config "webthreatdefsvc" start=demand >nul 2>&1
sc config "Wecsvc" start=demand >nul 2>&1
sc config "WEPHOSTSVC" start=demand >nul 2>&1
sc config "wercplsupport" start=demand >nul 2>&1
sc config "WerSvc" start=demand >nul 2>&1
sc config "WFDSConMgrSvc" start=demand >nul 2>&1
sc config "WiaRpc" start=demand >nul 2>&1
sc config "WinHttpAutoProxySvc" start=demand >nul 2>&1
sc config "WinRM" start=demand >nul 2>&1
sc config "wisvc" start=demand >nul 2>&1
sc config "wlidsvc" start=demand >nul 2>&1
sc config "wlpasvc" start=demand >nul 2>&1
sc config "WManSvc" start=demand >nul 2>&1
sc config "wmiApSrv" start=demand >nul 2>&1
sc config "WMPNetworkSvc" start=demand >nul 2>&1
sc config "workfolderssvc" start=demand >nul 2>&1
sc config "WpcMonSvc" start=demand >nul 2>&1
sc config "WPDBusEnum" start=demand >nul 2>&1
sc config "WpnService" start=demand >nul 2>&1
sc config "WSService" start=demand >nul 2>&1
sc config "wuauserv" start=demand >nul 2>&1
sc config "wudfsvc" start=demand >nul 2>&1
sc config "XblAuthManager" start=demand >nul 2>&1
sc config "XblGameSave" start=demand >nul 2>&1
sc config "XboxGipSvc" start=demand >nul 2>&1
sc config "XboxNetApiSvc" start=demand >nul 2>&1
sc config "AJRouter" start=disabled >nul 2>&1
sc config "AppVClient" start=disabled >nul 2>&1
sc config "AssignedAccessManagerSvc" start=disabled >nul 2>&1
sc config "DiagTrack" start=disabled >nul 2>&1
sc config "DialogBlockingService" start=disabled >nul 2>&1
sc config "NetTcpPortSharing" start=disabled >nul 2>&1
sc config "RemoteAccess" start=disabled >nul 2>&1
sc config "RemoteRegistry" start=disabled >nul 2>&1
sc config "shpamsvc" start=disabled >nul 2>&1
sc config "ssh-agent" start=disabled >nul 2>&1
sc config "tzautoupdate" start=disabled >nul 2>&1
sc config "UevAgentService" start=disabled >nul 2>&1
sc config "uhssvc" start=disabled >nul 2>&1

:: Related to installed Stuff

sc config "CCleaner*" start=disabled >nul 2>&1
sc config "CxAudioSvc" start=disabled >nul 2>&1
sc config "CxUIUSvc64" start=disabled >nul 2>&1
sc config "IntelCpHDCPSvc" start=disabled >nul 2>&1
sc config "IntelCpHeciSvc" start=disabled >nul 2>&1
sc config "jhi_service" start=disabled >nul 2>&1
sc config "OneApp.IGCC.WinService" start=disabled >nul 2>&1
sc config "igfxCUIService" start=disabled >nul 2>&1
sc config "WMIRegistrationService" start=disabled >nul 2>&1
sc config "RstMwService" start=disabled >nul 2>&1
sc config "XtuService" start=disabled >nul 2>&1
sc config "SECOMN64" start=disabled >nul 2>&1
sc config "igfxCUIService2.0.0.0" start=disabled >nul 2>&1
sc config "igccservice" start=disabled >nul 2>&1
sc config "cplspcon" start=disabled >nul 2>&1
sc config "XTUOCDriverService" start=disabled >nul 2>&1
sc config "SECOMNService" start=disabled >nul 2>&1

powershell -command "Get-ScheduledTask 'MoveActiveHours*' | Unregister-ScheduledTask -Confirm:$false" >nul 2>&1
powershell -command "Get-AppxPackage -Name 'Microsoft.MicrosoftEdge*' | Remove-AppxPackage" >nul 2>&1
powershell -command "Get-AppxPackage -Name 'Microsoft.Windows.DevHome*' | Remove-AppxPackage" >nul 2>&1
cls

echo "Hide MeetNow Icon"     REM Here cos it comes after a Windows update
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f >nul 2>&1
cls


:: ==FINAL BITS========================================================================================================================

@echo off
title Windows Activation
powershell -command "& ([ScriptBlock]::Create((irm https://get.activated.win))) /hwid"
cls

title Name PC
cls & set /p NUNAME=What name do you want this PC to be called? :
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v "ComputerName" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /v "ComputerName" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname" /t REG_SZ /d %NUNAME% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t REG_SZ /d %NUNAME% /f >nul
cls

title Power Planning
:choice
cls & set /P c=Is this machine a (D)esktop, (L)aptop or (V)irtual Machine? [D/L/V]?
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
cls

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
cls

powercfg -h off
del c:\CUSTOM /s >nul 2>&1
cls

title DISM Cleanup
dism /online /cleanup-image /startcomponentcleanup
dism /online /cleanup-image /startcomponentcleanup /resetbase

cls & echo All Done! REBOOT TIME!
pause
shutdown -r -t 0
