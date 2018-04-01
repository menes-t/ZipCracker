###############################################################################
# NAME:      zipPasswordCracker.ps1
# AUTHOR:    M Enes TURGUT
# DATE:      1/4/2018
#
# This script cracks a zip file that is password protected with given passwords from a dictionary file.
#
# VERSION HISTORY:
# 1.0    1/4/2018    Initial Version
###############################################################################

Param(
  [string]$mode,
  [string]$dictionaryPath,
  [string]$zipPath,
  [string]$dictionaryFile,
  [string]$zipFile,
  [string]$help
)

#this function is copied from https://stackoverflow.com/questions/2688547/multiple-foreground-colors-in-powershell-in-one-command and modified
function Write-Color([String[]]$Text, [ConsoleColor[]]$BackColor = "DarkBlue", [ConsoleColor[]]$Color = "White", [int]$StartTab = 0, [int] $LinesBefore = 0,[int] $LinesAfter = 0, [string] $LogFile = "", $TimeFormat = "yyyy-MM-dd HH:mm:ss") {
    # version 0.2
    # - added logging to file
    # version 0.1
    # - first draft
    # 
    # Notes:
    # - TimeFormat https://msdn.microsoft.com/en-us/library/8kb3ddd4.aspx

    $DefaultColor = $Color[0]
	$BackDefaultColor = $BackColor[0]
    if ($LinesBefore -ne 0) {  for ($i = 0; $i -lt $LinesBefore; $i++) { Write-Host "`n" -NoNewline } } # Add empty line before
    if ($StartTab -ne 0) {  for ($i = 0; $i -lt $StartTab; $i++) { Write-Host "`t" -NoNewLine } }  # Add TABS before text
    if ($Color.Count -ge $Text.Count) {
        for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackColor[$i] -NoNewLine } 
    } else {
        for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackColor[$i] -NoNewLine }
        for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $DefaultColor -BackgroundColor $BackDefaultColor -NoNewLine }
    }
    Write-Host
    if ($LinesAfter -ne 0) {  for ($i = 0; $i -lt $LinesAfter; $i++) { Write-Host "`n" } }  # Add empty line after
    if ($LogFile -ne "") {
        $TextToFile = ""
        for ($i = 0; $i -lt $Text.Length; $i++) {
            $TextToFile += $Text[$i]
        }
        Write-Output "[$([datetime]::Now.ToString($TimeFormat))]$TextToFile" | Out-File $LogFile -Encoding utf8 -Append
    }
}


If($help -eq "h"){
	Write-Color -Text "" -Color Yellow -LogFile "Log"
    Write-Color -Text "--------------------------------------------------------------------------------------------------------" -Color Yellow -LogFile "Log"
    Write-Color -Text "" -Color Yellow -LogFile "Log"
	Write-Color -Text "If you want to extract the zip file set mode parameter to e if not set to c:." -Color Yellow -LogFile "Log"
    Write-Color -Text "" -Color Yellow -LogFile "Log"
    Write-Color -Text "[-mode]: Whether you want to extract the zip file or not" -Color Yellow -LogFile "Log"
	Write-Color -Text "[-dictionaryPath]: The path of the dictionary file" -Color Yellow -LogFile "Log"
    Write-Color -Text "[-dictionaryFile]: The name of the dictionary file" -Color Yellow -LogFile "Log"
    Write-Color -Text "[-zipPath]: The path of the zip file you want to crack" -Color Yellow -LogFile "Log"
	Write-Color -Text "[-zipFile]: The name of the zip file you want to crack" -Color Yellow -LogFile "Log"
	Write-Color -Text "Either -dictionaryPath or -dictionaryFile should be given." -Color Red -LogFile "Log"
	Write-Color -Text "Either -zipPath or -zipFile should be given." -Color Red -LogFile "Log"
    Write-Color -Text "" -Color Yellow -LogFile "Log"
    Write-Color -Text "Example usage ---->"," .\zipPasswordCracker.ps1"," -dictionaryFile"," dictionary.txt"," -zipFile"," example.7z"," -mode"," c" -Color White,Green,Magenta,Cyan,Magenta,Cyan,Magenta,Cyan -LogFile "Log" -BackColor DarkBlue,DarkBlue,DarkBlue,DarkBlue,DarkBlue,DarkBlue,DarkBlue,DarkBlue
    Write-Color -Text "" -Color Yellow -LogFile "Log"
    Write-Color -Text "NOTE: If you are using file parameters and not path parameters please place the relating files with the same directory of script!!!" -Color Red -BackColor Black -LogFile "Log"
    Write-Color -Text "" -Color Yellow -LogFile "Log"
	Write-Color -Text "" -Color Yellow -LogFile "Log"
    Write-Color -Text "--------------------------------------------------------------------------------------------------------" -Color Yellow -LogFile "Log"
	exit
}

$workingdir = Split-Path $script:MyInvocation.MyCommand.Path

$startTime = (Get-Date)


$isInstalled = $false
$7zipFile = '"C:\Program Files\7-Zip\7z.exe"'
$count = 0


Write-Color -Text "" -LogFile "Log"
Write-Color -Text "********************************************************************************************************" -Color DarkCyan -LogFile "Log"
Write-Color -Text "" -LogFile "Log"
Write-Color "--------------------------------   Welcome to the Zip Cracker ! -----------------------------------" -Color Magenta -LogFile "Log"
 
Write-Color -Text "" -LogFile "Log"
Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
Write-Color -Text "Looking for 7z..." -Color Magenta -LogFile "Log"
Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"


Function FindInstalledApplicationInfo($ComputerName)
{
    $RegKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    
    $InstalledAppsInfos = Get-ItemProperty -Path $RegKey

    Foreach($InstalledAppsInfo in $InstalledAppsInfos)
    {
		If($InstalledAppsInfo.Publisher -eq "Igor Pavlov"){
			$isInstalled = $true
			$appName = $InstalledAppsInfo.DisplayName
			Write-Color -Text "$appName is found..." -Color Magenta -LogFile "Log"
			Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
			return $isInstalled;
		}
    }
	Write-Color -Text "7z could not be found." -Color Black -BackColor Red -LogFile "Log"
	Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
	$isInstalled = $false
}

$isInstalled = FindInstalledApplicationInfo

If(-Not $isInstalled){
	Write-Color -Text "Download is starting..." -Color Magenta -LogFile "Log"
	Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
	
	$workdir = "$workingdir\Installer"
	New-Item -Path $workdir -ItemType directory > $null
	$source = "https://www.7-zip.org/a/7z1801-x64.msi"
	$destination = "$workdir\7-Zip.msi"
	
	$WebClient = New-Object System.Net.WebClient
    $webclient.DownloadFile($source, $destination)
	
	Write-Color -Text "Download is finished..." -Color Magenta -LogFile "Log"
	Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
	Write-Color -Text "Installing 7z..." -Color Magenta -LogFile "Log"
	Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
	
	msiexec.exe /i "$workdir\7-Zip.msi" /qb
	
	Start-Sleep -s 35
	
	rm -Force $workdir\7*
	rm -Force $workdir
	
	Write-Color -Text "Installed successfully..." -Color Magenta -LogFile "Log"
	Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
	
	##install 7z
}
$DICTIONARY
$7zf
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"

If($dictionaryPath){
	$DICTIONARY = Get-Content -Path "$dictionaryPath"
}
ElseIf($dictionaryFile){
	$DICTIONARY = Get-Content -Path "$dictionaryFile"
}
Else{
	Write-Color -Text "Wrong parameter. Please give either dictionaryFile or dictionaryPath" -Color Red -BackColor Black -LogFile "Log"
}
If($zipPath){
	$7zf = "$zipPath"
}
ElseIf($zipFile){
	$7zf = "$zipFile"
}
Else{
	Write-Color -Text "Wrong parameter. Please give either zipFile or zipPath" -Color Red -BackColor Black -LogFile "Log"
}

$7zo = "-aoa"


Foreach($pass in $DICTIONARY){
	#https://sevenzip.osdn.jp/chm/cmdline/switches/bs.htm
	If($mode -eq "e"){
		sz e $7zf "-p$pass" $7zo -bso0 -bsp0 -bse0 #1> $null 2> $null
	}
	
	If($mode -eq "c"){
		sz t $7zf "-p$pass" $7zo -bso0 -bsp0 -bse0 #1> $null 2> $null
	}
	
	If($LASTEXITCODE -eq 2){
		$count += 1
	}
	
	If($LASTEXITCODE -eq 0){
		
		$elapsedTime = (Get-Date) - $startTime
		
		Write-Color -Text "" -LogFile "Log"
        Write-Color -Text "The zip password is cracked ", " -----> ", "$pass ","in $elapsedTime" -Color White,White,Red,Red -BackColor DarkBlue,Blue,Green,Yellow -LogFile "Log"
		Write-Color -Text "" -LogFile "Log"
		Write-Color -Text "--------------------------------------------------------------------------------------------------------" -Color DarkCyan -LogFile "Log"
		
        
		If(-Not $isInstalled){
			Write-Color -Text "Uninstalling 7z..." -Color Magenta -LogFile "Log"
			Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
			
			$app = Get-WmiObject -Class Win32_Product -Filter "Name = '7-Zip 18.01 (x64 edition)'"
			$identityNumber = $app.IdentifyingNumber
	
			msiexec.exe /x "$identityNumber" /qb
			
			Write-Color -Text "Uninstalled successfully..." -Color Magenta -LogFile "Log"
			Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
		}
		
		Write-Color "" -LogFile "Log"
        Write-Color "--------------------------------   Goodbye from the Zip Cracker ! ---------------------------------" -Color Magenta -LogFile "Log"
		Write-Color "--------------------------------------------------------------------------------------------------------" -Color DarkCyan -LogFile "Log"
		exit
	}
	If($count -eq 1){
		Write-Color -Text "$count st ", "password ", "$pass ", "has been tried" -Color Yellow,Green,Red,Green -BackColor Blue,Blue,Blue,Blue -LogFile "Log"
	}
	ElseIf($count -eq 2){
		Write-Color -Text "$count nd ", "password ", "$pass ", "has been tried" -Color Yellow,Green,Red,Green -BackColor Blue,Blue,Blue,Blue -LogFile "Log"
	}
	ElseIf($count -eq 3){
		Write-Color -Text "$count rd ", "password ", "$pass ", "has been tried" -Color Yellow,Green,Red,Green -BackColor Blue,Blue,Blue,Blue -LogFile "Log"
	}
	Else{
		Write-Color -Text "$count th ", "password ", "$pass ", "has been tried" -Color Yellow,Green,Red,Green -BackColor Blue,Blue,Blue,Blue -LogFile "Log"
	}
	#Write-Host $LASTEXITCODE
}

$elapsedTime = (Get-Date) - $startTime
		
Write-Color -Text "" -LogFile "Log"
Write-Color -Text "The zip password could not be cracked ", "in $elapsedTime" -Color White,Red -BackColor DarkBlue,Yellow -LogFile "Log"
Write-Color -Text "" -LogFile "Log"
Write-Color -Text "--------------------------------------------------------------------------------------------------------" -Color DarkCyan -LogFile "Log"
		
        
If(-Not $isInstalled){
	Write-Color -Text "Uninstalling 7z..." -Color Magenta -LogFile "Log"
	Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
			
	$app = Get-WmiObject -Class Win32_Product -Filter "Name = '7-Zip 18.01 (x64 edition)'"
	$identityNumber = $app.IdentifyingNumber
	
	msiexec.exe /x "$identityNumber" /qb
			
	Write-Color -Text "Uninstalled successfully..." -Color Magenta -LogFile "Log"
	Write-Color -Text " --------------------------------------------------------------------------------- " -Color DarkCyan -LogFile "Log"
}
		
Write-Color "" -LogFile "Log"
Write-Color "--------------------------------   Goodbye from the Zip Cracker ! ---------------------------------" -Color Magenta -LogFile "Log"
Write-Color "--------------------------------------------------------------------------------------------------------" -Color DarkCyan -LogFile "Log"
