:: == WINDOWS CUSTOMIZER SCRIPT for WINDOWS 10 & 11 LTSC =============================================================================

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

echo Changing custom Wallpaper and Lockscreen
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/WallpaperLock.PS1 -OutFile C:\Users\Administrator\Desktop\WallpaperLock.PS1"
powershell -file "C:\Users\Administrator\Desktop\WallpaperLock.PS1"
del C:\Users\Administrator\Desktop\WallpaperLock.PS1

echo Switch to Dark mode system-wide
powershell -command "Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force;"
powershell -command "Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force;"
taskkill /im explorer.exe /f & start explorer.exe & rd /s /q "c:\Perflogs" >nul 2>&1

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

:: ==INSTALLS========================================================================================================================

@echo off
cls
title Installs

:check
ping www.google.com -n 1 -w 1000>nul && cls
if errorlevel 1 (echo "This script needs you to connect to internet" & wait 5 & goto check) else (echo Starting)

title Installing Winget
REM Use wsreset -i and then install unigetui from msstore as an ALT
powershell -command "irm https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1 | iex"

title Installing UniGetUI
winget install -e -h --id XPFFTQ032PTPHF --accept-source-agreements --accept-package-agreements
del "c:\Users\Public\Desktop\UniGetUI.lnk"

:: Windows10/11 Differences
for /f "tokens=3 delims=." %%i in ('ver') do set build=%%i
if %build% geq 22000 {
  echo Detected Windows 11
  title Installing ExplorerPatcher
  winget install -e -h --id valinet.ExplorerPatcher
  powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/ExplorerPatcher.reg -OutFile C:\ExplorerPatcher.reg"
  reg import c:\ExplorerPatcher.reg
  del /s c:\ExplorerPatcher.reg >nul 2>&1
  taskkill /im explorer.exe /f & start explorer.exe
  label c: Win11 }
 else {
  echo Detected Windows 10
  label c: Win10
}

title Uninstall CPU-Z
"c:\Program Files\CPUID\CPU-Z\unins000.exe" /SILENT

title Installing Brave
winget install -e -h --id Brave.Brave
del /s "c:\Users\Administrator\Desktop\Brave.lnk" >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v "BraveSoftware Update" /f
for /f "tokens=1 delims=," %%x in ('schtasks /query /fo csv ^| find "Brave"') do schtasks /Delete /TN %%x /F
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/pttb.exe -OutFile C:\pttb.exe"
c:\pttb.exe C:\Users\Administrator\AppData\Local\BraveSoftware\Brave-Browser\Application\brave.exe
del c:\pttb.exe

title Installing 7Zip
winget install -e -h --id 7zip.7zip

title Installing Notepad++
winget install -e -h --id Notepad++.Notepad++

title Installing Redist Files
winget install -e -h --id Microsoft.VCRedist.2015+.x64

title Installing OnlyOffice
winget install -e -h --id ONLYOFFICE.DesktopEditors
del "c:\Users\Public\Desktop\ONLYOFFICE.lnk"

title Installing Putty
winget install -e -h --id PuTTY.PuTTY
REM powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/Putty.lnk -OutFile C:\Users\Administrator\Desktop\Putty.lnk"

title Installing SumatraPDF
winget install -e -h --id SumatraPDF.SumatraPDF
del /s "c:\Users\Administrator\Desktop\SumatraPDF.lnk" >nul 2>&1

title Installing ImgBurn
winget install -e -h --id LIGHTNINGUK.ImgBurn
del /s "c:\Users\Administrator\Desktop\ImgBurn.lnk" & del /s "c:\Users\Public\Desktop\ImgBurn.lnk" & cls

title Installing KLite Codecs
winget install -e -h --id CodecGuide.K-LiteCodecPack.Standard
del /s "c:\Users\Administrator\Desktop\MPC-HC x64.lnk" & del /s "c:\Users\Public\Desktop\mpc-be.lnk" & schtasks /delete /tn klcp_update /f & cls

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
del "c:\Users\Administrator\Desktop\BleachBit.lnk"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/bleachbit.ini -OutFile C:\Users\Administrator\AppData\Local\BleachBit\bleachbit.ini"
mkdir "C:\Users\Administrator\AppData\Local\BleachBit\cleaners"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/winapp2.ini -OutFile C:\Users\Administrator\AppData\Local\BleachBit\cleaners\winapp2.ini"

title Installing CCleaner
winget install -e -h --id Piriform.CCleaner
del "c:\Users\Public\Desktop\CCleaner.lnk"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/ccleaner.ini -OutFile 'C:\Program Files\CCleaner\ccleaner.ini'"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/winapp2.ini -OutFile 'C:\Program Files\CCleaner\winapp2.ini'"
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/CCEnhancer.exe -OutFile 'C:\Program Files\CCleaner\CCEnhancer.exe'"
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "CCleaner Smart Cleaning" /f >nul
for /f "tokens=1 delims=," %%x in ('schtasks /query /fo csv ^| find "CCleaner"') do schtasks /Delete /TN %%x /F

title Installing Wise Disk Cleaner
winget install -e -h --id WiseCleaner.WiseDiskCleaner
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/config.ini -OutFile 'C:\Program Files (x86)\Wise\Wise Disk Cleaner\config.ini'"
del "c:\Users\Public\Desktop\Wise Disk Cleaner.lnk"

title Installing Wise Force Deleter
winget install -e -h --id WiseCleaner.WiseForceDeleter
del "c:\Users\Public\Desktop\Wise Force Deleter.lnk"

title Installing Wise Registry Cleaner
winget install -e -h --id WiseCleaner.WiseRegistryCleaner
del "c:\Users\Public\Desktop\Wise Registry Cleaner.lnk"

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
del "c:\Users\Public\Desktop\VideoReDo TVSuite V6.lnk"
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

REM title Remove Edge Cleanly
REM powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/methanoid/setup/main/WINFILES/Die_Edge_Die.ps1 -OutFile C:\Users\Administrator\Desktop\Die_Edge_Die.ps1"
REM powershell -file "C:\Users\Administrator\Desktop\Die_Edge_Die.ps1"
REM del C:\Users\Administrator\Desktop\Die_Edge_Die.ps1
echo Displaying remaining installed AppX
powershell -command "Get-AppxProvisionedPackage -Online | Format-Table DisplayName, PackageName"

:: ==CLEANUPS========================================================================================================================

@echo off
cls
title Windows Cleanups - Be patient

:check
ping www.google.com -n 1 -w 1000>nul && cls
if errorlevel 1 (echo This script needs you to connect to internet & wait 5 & goto check) else (echo Starting)

title Some File Cleaning
"C:\Users\Administrator\AppData\Roaming\BleachBit\bleachbit_console.exe" -c --preset >nul 2>&1
"C:\Program Files\CCleaner\CCleaner64.exe" /AUTO                 :: Runs Ccleaner

:: Run applications (needs manual intervention)
"C:\Program Files\CCleaner\CCleaner64.exe" /REGISTRY             :: Opens CCleaner on Registry Screen
"C:\Program Files (x86)\Wise\Wise Disk Cleaner\WiseDiskCleaner.exe"

:: Services lifted from CTT
sc config "AudioSrv" start=automatic
sc config "Audiosrv" start=automatic
sc config "BFE" start=automatic
sc config "BrokerInfrastructure" start=automatic
sc config "BthHFSrv" start=automatic
sc config "CDPUserSvc_*" start=automatic
sc config "CoreMessagingRegistrar" start=automatic
sc config "CryptSvc" start=automatic
sc config "DcomLaunch" start=automatic
sc config "Dhcp" start=automatic
sc config "DispBrokerDesktopSvc" start=automatic
sc config "Dnscache" start=automatic
sc config "DPS" start=automatic
sc config "DusmSvc" start=automatic
sc config "EventLog" start=automatic
sc config "EventSystem" start=automatic
sc config "FontCache" start=automatic
sc config "gpsvc" start=automatic
sc config "iphlpsvc" start=automatic
sc config "LanmanServer" start=automatic
sc config "LanmanWorkstation" start=automatic
sc config "LSM" start=automatic
sc config "MpsSvc" start=automatic
sc config "mpssvc" start=automatic
sc config "nsi" start=automatic
sc config "OneSyncSvc_*" start=automatic
sc config "Power" start=automatic
sc config "ProfSvc" start=automatic
sc config "RpcEptMapper" start=automatic
sc config "RpcSs" start=automatic
sc config "SamSs" start=automatic
sc config "Schedule" start=automatic
sc config "SENS" start=automatic
sc config "SgrmBroker" start=automatic
sc config "ShellHWDetection" start=automatic
sc config "Spooler" start=automatic
sc config "SysMain" start=automatic
sc config "SystemEventsBroker" start=automatic
sc config "Themes" start=automatic
sc config "tiledatamodelsvc" start=automatic
sc config "TrkWks" start=automatic
sc config "UserManager" start=automatic
sc config "VGAuthService" start=automatic
sc config "VMTools" start=automatic
sc config "Wcmsvc" start=automatic
sc config "webthreatdefUsersvc_*" start=automatic
sc config "WinDefend" start=automatic
sc config "Winmgmt" start=automatic
sc config "WpnUserService_*" start=automatic
sc config "DoSvc" start=delayed-auto
sc config "MapsBroker" start=delayed-auto
sc config "sppsvc" start=delayed-auto
sc config "wscsvc" start=delayed-auto
sc config "WSearch" start=delayed-auto
sc config "ALG" start=demand
sc config "AppIDSvc" start=demand
sc config "Appinfo" start=demand
sc config "AppMgmt" start=demand
sc config "AppReadiness" start=demand
sc config "AppXSvc" start=demand
sc config "autotimesvc" start=demand
sc config "AxInstSV" start=demand
sc config "BcastDVRUserService_*" start=demand
sc config "BDESVC" start=demand
sc config "BluetoothUserService_*" start=demand
sc config "Browser" start=demand
sc config "BTAGService" start=demand
sc config "bthserv" start=demand
sc config "camsvc" start=demand
sc config "CaptureService_*" start=demand
sc config "CDPSvc" start=demand
sc config "CertPropSvc" start=demand
sc config "ClipSVC" start=demand
sc config "cloudidsvc" start=demand
sc config "COMSysApp" start=demand
sc config "ConsentUxUserSvc_*" start=demand
sc config "CredentialEnrollmentManagerUserSvc_*" start=demand
sc config "CscService" start=demand
sc config "DcpSvc" start=demand
sc config "dcsvc" start=demand
sc config "defragsvc" start=demand
sc config "DeviceAssociationBrokerSvc_*" start=demand
sc config "DeviceInstall" start=demand
sc config "DevicePickerUserSvc_*" start=demand
sc config "DevicesFlowUserSvc_*" start=demand
sc config "DevQueryBroker" start=demand
sc config "diagnosticshub.standardcollector.service" start=demand
sc config "diagsvc" start=demand
sc config "DisplayEnhancementService" start=demand
sc config "DmEnrollmentSvc" start=demand
sc config "dmwappushservice" start=demand
sc config "dot3svc" start=demand
sc config "DsmSvc" start=demand
sc config "DsSvc" start=demand
sc config "EapHost" start=demand
sc config "edgeupdate" start=demand
sc config "edgeupdatem" start=demand
sc config "EFS" start=demand
sc config "embeddedmode" start=demand
sc config "EntAppSvc" start=demand
sc config "Fax" start=demand
sc config "fdPHost" start=demand
sc config "FDResPub" start=demand
sc config "fhsvc" start=demand
sc config "FrameServer" start=demand
sc config "FrameServerMonitor" start=demand
sc config "GraphicsPerfSvc" start=demand
sc config "hidserv" start=demand
sc config "HomeGroupListener" start=demand
sc config "HomeGroupProvider" start=demand
sc config "HvHost" start=demand
sc config "icssvc" start=demand
sc config "IEEtwCollectorService" start=demand
sc config "InstallService" start=demand
sc config "InventorySvc" start=demand
sc config "IpxlatCfgSvc" start=demand
sc config "KtmRm" start=demand
sc config "lfsvc" start=demand
sc config "LicenseManager" start=demand
sc config "lltdsvc" start=demand
sc config "lmhosts" start=demand
sc config "LxpSvc" start=demand
sc config "McpManagementService" start=demand
sc config "MessagingService_*" start=demand
sc config "MicrosoftEdgeElevationService" start=demand
sc config "MixedRealityOpenXRSvc" start=demand
sc config "MSDTC" start=demand
sc config "MSiSCSI" start=demand
sc config "msiserver" start=demand
sc config "MsKeyboardFilter" start=demand
sc config "NaturalAuthentication" start=demand
sc config "NcaSvc" start=demand
sc config "NcbService" start=demand
sc config "NcdAutoSetup" start=demand
sc config "Netman" start=demand
sc config "netprofm" start=demand
sc config "NetSetupSvc" start=demand
sc config "NgcCtnrSvc" start=demand
sc config "NgcSvc" start=demand
sc config "NPSMSvc_*" start=demand
sc config "p2pimsvc" start=demand
sc config "p2psvc" start=demand
sc config "P9RdrService_*" start=demand
sc config "PeerDistSvc" start=demand
sc config "PenService_*" start=demand
sc config "perceptionsimulation" start=demand
sc config "PerfHost" start=demand
sc config "PhoneSvc" start=demand
sc config "PimIndexMaintenanceSvc_*" start=demand
sc config "pla" start=demand
sc config "PlugPlay" start=demand
sc config "PNRPAutoReg" start=demand
sc config "PNRPsvc" start=demand
sc config "PolicyAgent" start=demand
sc config "PrintNotify" start=demand
sc config "PrintWorkflowUserSvc_*" start=demand
sc config "PushToInstall" start=demand
sc config "QWAVE" start=demand
sc config "RasAuto" start=demand
sc config "RetailDemo" start=demand
sc config "RmSvc" start=demand
sc config "RpcLocator" start=demand
sc config "SCardSvr" start=demand
sc config "ScDeviceEnum" start=demand
sc config "SCPolicySvc" start=demand
sc config "SDRSVC" start=demand
sc config "seclogon" start=demand
sc config "SecurityHealthService" start=demand
sc config "SEMgrSvc" start=demand
sc config "Sense" start=demand
sc config "SensorDataService" start=demand
sc config "SensorService" start=demand
sc config "SensrSvc" start=demand
sc config "SessionEnv" start=demand
sc config "SharedAccess" start=demand
sc config "SharedRealitySvc" start=demand
sc config "smphost" start=demand
sc config "SmsRouter" start=demand
sc config "SNMPTRAP" start=demand
sc config "SNMPTrap" start=demand
sc config "spectrum" start=demand
sc config "SSDPSRV" start=demand
sc config "StiSvc" start=demand
sc config "StorSvc" start=demand
sc config "svsvc" start=demand
sc config "swprv" start=demand
sc config "TabletInputService" start=demand
sc config "TapiSrv" start=demand
sc config "TextInputManagementService" start=demand
sc config "TieringEngineService" start=demand
sc config "TimeBroker" start=demand
sc config "TimeBrokerSvc" start=demand
sc config "TokenBroker" start=demand
sc config "TroubleshootingSvc" start=demand
sc config "TrustedInstaller" start=demand
sc config "UdkUserSvc_*" start=demand
sc config "UI0Detect" start=demand
sc config "UmRdpService" start=demand
sc config "UnistoreSvc_*" start=demand
sc config "upnphost" start=demand
sc config "UserDataSvc_*" start=demand
sc config "UsoSvc" start=demand
sc config "VacSvc" start=demand
sc config "vds" start=demand
sc config "vm3dservice" start=demand
sc config "vmicguestinterface" start=demand
sc config "vmicheartbeat" start=demand
sc config "vmickvpexchange" start=demand
sc config "vmicrdv" start=demand
sc config "vmicshutdown" start=demand
sc config "vmictimesync" start=demand
sc config "vmicvmsession" start=demand
sc config "vmicvss" start=demand
sc config "vmvss" start=demand
sc config "VSS" start=demand
sc config "W32Time" start=demand
sc config "WaaSMedicSvc" start=demand
sc config "WalletService" start=demand
sc config "WarpJITSvc" start=demand
sc config "wbengine" start=demand
sc config "WbioSrvc" start=demand
sc config "wcncsvc" start=demand
sc config "WcsPlugInService" start=demand
sc config "WdiServiceHost" start=demand
sc config "WdiSystemHost" start=demand
sc config "WdNisSvc" start=demand
sc config "WebClient" start=demand
sc config "webthreatdefsvc" start=demand
sc config "Wecsvc" start=demand
sc config "WEPHOSTSVC" start=demand
sc config "wercplsupport" start=demand
sc config "WerSvc" start=demand
sc config "WFDSConMgrSvc" start=demand
sc config "WiaRpc" start=demand
sc config "WinHttpAutoProxySvc" start=demand
sc config "WinRM" start=demand
sc config "wisvc" start=demand
sc config "wlidsvc" start=demand
sc config "wlpasvc" start=demand
sc config "WManSvc" start=demand
sc config "wmiApSrv" start=demand
sc config "WMPNetworkSvc" start=demand
sc config "workfolderssvc" start=demand
sc config "WpcMonSvc" start=demand
sc config "WPDBusEnum" start=demand
sc config "WpnService" start=demand
sc config "WSService" start=demand
sc config "wuauserv" start=demand
sc config "wudfsvc" start=demand
sc config "XblAuthManager" start=demand
sc config "XblGameSave" start=demand
sc config "XboxGipSvc" start=demand
sc config "XboxNetApiSvc" start=demand
sc config "AJRouter" start=disabled
sc config "AppVClient" start=disabled
sc config "AssignedAccessManagerSvc" start=disabled
sc config "DiagTrack" start=disabled
sc config "DialogBlockingService" start=disabled
sc config "NetTcpPortSharing" start=disabled
sc config "RemoteAccess" start=disabled
sc config "RemoteRegistry" start=disabled
sc config "shpamsvc" start=disabled
sc config "ssh-agent" start=disabled
sc config "tzautoupdate" start=disabled
sc config "UevAgentService" start=disabled
sc config "uhssvc" start=disabled

:: Related to installed Stuff

sc config "CCleaner*" start=disabled
sc config "CxAudioSvc" start=disabled
sc config "CxUIUSvc64" start=disabled
sc config "IntelCpHDCPSvc" start=disabled
sc config "IntelCpHeciSvc" start=disabled
sc config "jhi_service" start=disabled
sc config "OneApp.IGCC.WinService" start=disabled
sc config "igfxCUIService" start=disabled
sc config "WMIRegistrationService" start=disabled
sc config "RstMwService" start=disabled
sc config "XtuService" start=disabled
sc config "SECOMN64" start=disabled
sc config "igfxCUIService2.0.0.0" start=disabled
sc config "igccservice" start=disabled
sc config "cplspcon" start=disabled
sc config "XTUOCDriverService" start=disabled
sc config "SECOMNService" start=disabled

:: ==FINAL BITS========================================================================================================================

@echo off
cls
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


:: ==REBOOT==========================================================================================================================

echo "Rebooting now - enjoy!"
shutdown -r -t 30
