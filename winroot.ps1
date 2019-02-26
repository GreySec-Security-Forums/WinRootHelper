#____   ____             __
#\   \ /   /____   _____/  |_  ___________
# \   Y   // __ \_/ ___\   __\/  _ \_  __ \
#  \     /\  ___/\  \___|  | (  <_> )  | \/
#   \___/  \___  >\___  >__|  \____/|__|
#              \/     \/
#--Licensed under GNU AGPL 3
#----Authored by Vector/NullArray for GS
#------For further Open Source Development
###############################################


# Allows user to skip straight to the download menu
Param (
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]$SupressNoise = $false)

$lines="------------------------------------------"

function WriteLogo($a) {
    Write-Host
    Write-Host -ForegroundColor White $lines
    Write-Host -ForegroundColor Green " "$a 
    Write-Host -ForegroundColor White $lines
}

function ExtraInfo($b) {
    Write-Host
    Write-Host -ForegroundColor Green " "$b 

}


if ($SupressNoise -eq $False) {
    WriteLogo "
        _ _ _ _     _____         _           
       | | | |_|___| __  |___ ___| |_         
       | | | | |   |    -| . | . |  _|        
       |_____|_|_|_|__|__|___|___|_|
           _____     _             
          |  |  |___| |___ ___ ___ 
          |     | -_| | . | -_|  _|
          |__|__|___|_|  _|___|_|  
                      |_|           "
}             

if ($SupressNoise -eq $False) {
    ExtraInfo "
Welcome to the main WinRoot Helper script.

As a (post)exploitation utility, WinRoot- 
Helper is designed to provide easy access 
to some tools and resources that 
may assist in UAC bypass and Privilege
Escalation. 

This script is designed to automate a number
of OffSec Operations aimed at Priv-Esc and
Post-Exploitation.

This is an Alpha release, more features
are planned to be developed in an 
open Source capacity.
"

}

function unzip {
    param (
        [string]$archiveFilePath,
        [string]$destinationPath
    )

    if ($archiveFilePath -notlike '?:\*') {
        $archiveFilePath = [System.IO.Path]::Combine($PWD, $archiveFilePath)
    }

    if ($destinationPath -notlike '?:\*') {
        $destinationPath = [System.IO.Path]::Combine($PWD, $destinationPath)
    }

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $archiveFile = [System.IO.File]::Open($archiveFilePath, [System.IO.FileMode]::Open)
    $archive = [System.IO.Compression.ZipArchive]::new($archiveFile)

    if (Test-Path $destinationPath) {
        foreach ($item in $archive.Entries) {
            $destinationItemPath = [System.IO.Path]::Combine($destinationPath, $item.FullName)

            if ($destinationItemPath -like '*/') {
                New-Item $destinationItemPath -Force -ItemType Directory > $null
            } else {
                New-Item $destinationItemPath -Force -ItemType File > $null

                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($item, $destinationItemPath, $true)
            }
        }
    } else {
        [System.IO.Compression.ZipFileExtensions]::ExtractToDirectory($archive, $destinationPath)
    }
}


Function Download {
	[cmdletbinding()]
    Param( 
       [Parameter(Mandatory = $true, ParameterSetName='-U')]
       # Source file param
       [ValidateNotNullOrEmpty()]
       [Alias('WSF')]   
       [string]$WebSourceFile, 
            
       [Parameter(Mandatory = $true, ParameterSetName='-P')] 
       # File path Param
       [ValidateNotNullOrEmpty()]
       [Alias('DFP')]   
       [IO.FileInfo]$DownloadFilePath)
    
    Begin {
        $DownloadLocation = Set-Location
        $WebClient = New-Object System.Net.WebClient
        If (Test-Path -Path $DownloadLocation){
            Write-Host "Output set to: $DownloadLocation"
            Write-Host
		}
		Else {
            Write-Host -ForegroundColor Red "[!]Invalid Path: $DownloadLocation"
			Write-Host
			Break
        }
    }

    Process {
        Try {
            Write-Host 'Downloading file...'
            Write-Host            
            $WebClient.DownloadFile($WebSourceFile, $DownloadFilePath)
        }
        Catch {
            Write-Host -ForegroundColor Red "[!]Warning, an error occurred: $_"            
            Write-Host
            Break
        }
    }

    End {}
}


Function Invoke-Menu {
    [cmdletbinding()]
    Param(
    [Parameter(Position=0,Mandatory=$True,HelpMessage="Please enter your choice")]
    [ValidateNotNullOrEmpty()]
    [string]$Menu,

    [Parameter(Position=1)]
    [ValidateNotNullOrEmpty()]
    [string]$Title = "WinRootHelper",

    [Alias("cls")]
    [switch]$ClearScreen)

    #clear the screen if requested
    if ($ClearScreen) { 
        Clear-Host 
    }
 
    #build the menu prompt
    $menuPrompt = $title
    #add a return
    $menuprompt+="`n"
    #add an underline
    $menuprompt+="-"*$title.Length
    #add another return
    $menuprompt+="`n"
    #add the menu
    $menuPrompt+=$menu
    
    Read-Host -Prompt $menuprompt
 
} #end function

do {
    #use a Switch construct to take action depending on what menu choice
    #is selected.
    Switch (Invoke-Menu -menu $menu -title "WinRootHelper" -clear) {
     "1" {Write-Host "SysEnum Shell Script."
         sleep -seconds 2
         Download -WebSourceFile https://raw.githubusercontent.com/thereisnotime/xxSysInfo/master/xxSysInfo.bat -DownloadFilePath
         sleep -milliseconds 1250
         Clear-Host
         Write-Host "Done"

         } 
     "2" {Write-Host "PowerShell Security Suite"
          sleep -seconds 2
          Download -WebSourceFile https://github.com/FuzzySecurity/PowerShell-Suite/archive/master.zip -DownloadFilePath
          # Call Unzip function to extract helper scripts
          unzip [[ -archiveFilePath "$DownloadFilePath/master.zip" ] [[-destinationPath] "$DownloadFilePath" ]]
          sleep -milliseconds 1250
          Clear-Host
          Write-Host "Done"
         
         }
     "3" {Write-Host "Windows Exploit Suggester" 
         sleep -seconds 2
         Download -WebSourceFile https://github.com/pentestmonkey/windows-privesc-check/raw/master/windows-privesc-check2.exe -DownloadFilePath
         sleep -milliseconds 1250
         Clear-Host
         Write-Host
         Write-Host "Done"
          
         }
         
     "4" {Write-Host "Launch Automated Probe/Attack"
          #
          # The current implementation reserves these lines for future additions
          # In the form of operations that launch automated security tools
          # In order to facilitate privilege escalation on the system in question
          #
        
          }
     "Q" {Write-Host "Exit" -ForegroundColor Blue
         Return
         }
     Default {Write-Warning "Invalid Choice. Try again."
              sleep -milliseconds 750}
    } #switch
} While ($True)

