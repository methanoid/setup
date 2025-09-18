# Taken from https://gist.github.com/jamiechalmerzlp
# Parameters for source and destination for the Image file
# Current script is edited to put the same image on LockScreen and Wallpaper

$WallpaperURL = "https://getwallpapers.com/wallpaper/full/c/2/c/1363723-vertical-colorful-desktop-backgrounds-2560x1600-for-pc.jpg" # Change to your fitting
$LockscreenUrl = "https://getwallpapers.com/wallpaper/full/c/2/c/1363723-vertical-colorful-desktop-backgrounds-2560x1600-for-pc.jpg" # Change to your fitting

$ImageDestinationFolder = "C:\Users\Administrator\AppData\Local\Microsoft\Windows\Themes" # Change to your fitting - this is the folder for the wallpaper image
$WallpaperDestinationFile = "$ImageDestinationFolder\wallpaper.png" # Change to your fitting - this is the Wallpaper image
$LockScreenDestinationFile = "$ImageDestinationFolder\lockScreen.png" # Change to your fitting - this is the Lockscreen image

# Creates the destination folder on the target computer
mkdir $ImageDestinationFolder -erroraction silentlycontinue

# Downloads the image file from the source location
Start-BitsTransfer -Source $WallpaperURL -Destination "$WallpaperDestinationFile"
Start-BitsTransfer -Source $LockscreenUrl -Destination "$LockScreenDestinationFile"

# Assigns the wallpaper 
$RegKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'

$DesktopPath = "DesktopImagePath"
$DesktopStatus = "DesktopImageStatus"
$DesktopUrl = "DesktopImageUrl"
$LockScreenPath = "LockScreenImagePath"
$LockScreenStatus = "LockScreenImageStatus"
$LockScreenUrl = "LockScreenImageUrl"

$StatusValue = "1"
$DesktopImageValue = "$WallpaperDestinationFile"  
$LockScreenImageValue = "$LockScreenDestinationFile"

IF(!(Test-Path $RegKeyPath))

{

New-Item -Path $RegKeyPath -Force | Out-Null

New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null

}

ELSE {

New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $Statusvalue -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $value -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
}

# Clears the error log from powershell before exiting
    $error.clear()
