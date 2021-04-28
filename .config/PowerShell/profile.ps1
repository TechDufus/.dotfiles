#Region UX Config
$DetectedOS = switch($true) {
    $IsWindows {'Windows'}
    $IsLinux   {'Linux'}
    $IsMacOS   {'MacOS'}
    DEFAULT    {'Windows'}
}
If ($PSVersionTable.PSVersion.Major -gt 5) {
    $hasOhMyPosh = Import-Module oh-my-posh -MinimumVersion 3.0 -PassThru -ErrorAction SilentlyContinue
    if ($hasOhMyPosh) {
        Set-PoshPrompt avit
        # $themePath = Join-Path $PSScriptRoot 'posh-theme.json'
        # if (Test-Path $themePath) {
        #     Set-PoshPrompt -Theme $themePath
        # } else {
        #     Set-PoshPrompt -Theme powerlevel10k_classic
        # }
    }
}
Import-Module posh-git

if (Get-Module PSReadLine) {
    Set-PSReadLineKeyHandler -Chord Alt+Enter -Function AddLine
    Set-PSReadLineOption -ContinuationPrompt "  " -PredictionSource History -Colors @{
        Operator         = [System.ConsoleColor]::DarkRed
        Parameter        = [System.ConsoleColor]::Red
        InlinePrediction = [System.ConsoleColor]::Cyan
    }
    
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    # Commenting out the following because using ListView needs to use UpArrow and DownArrow for results.
    # Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    # Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadlineOption -BellStyle None
}
#EndRegion UX Config

Import-Module Terminal-Icons

Function Get-GitLog() {
    git log --oneline --graph --decorate
}
Set-Alias -Name GGL -Value Get-GitLog

<#
.SYNOPSIS
    Perform a benchtest of your PowerShell profile.
.DESCRIPTION
    Load Powershell (or Preview) X number of times with NO profile, and with profile, and compare the average loading times.
.PARAMETER Count
    Specify the number of consoles to load for testing.
.PARAMETER Preview
    Specify whether to test again pwsh-preview or not.
    With this present, the tests will use pwsh-preview.
.EXAMPLE
    Test-PowerShellProfilePerformance -Count 50

    Description
    -----------
    Loop through testing your powershell profile 50 times.
    This is 50 times PER console. With profile and without.
.NOTES
    Author: matthewjdegarmo
    Github: https://github.com/matthewjdegarmo
#>
Function Test-PowerShellProfilePerformance() {
    [CmdletBinding()]
    Param(
        [Parameter()]
        $Count = 100,

        [Parameter()]
        [Switch] $Preview
    )

    Begin {
        If ($Preview.IsPresent) {
            $Pwsh = 'pwsh-preview'
        } Else {
            $Pwsh = 'pwsh'
        }
        If (-Not(Get-Command $Pwsh -ErrorAction SilentlyContinue)) {
            Throw "The command '$Pwsh' does not exist on this system."
        }
    }

    Process {
        $Result = @{}

        $NoProfile = 0
        1..$Count | ForEach-Object {
            $Percent = $($_ / $Count) * 100
            Write-Progress -Id 1 -Activity "$($Pwsh.ToUpper()) - No Profile" -PercentComplete $Percent
            $NoProfile += (Measure-Command {
                &$Pwsh -noprofile -command 1
            }).TotalMilliseconds 
        }
        Write-Progress -id 1 -Activity "$($Pwsh.ToUpper()) - No Profile" -Completed
        $Result['NoProfile_Average'] = "$($NoProfile/$Count)`ms"

        $WithProfile = 0
        1..$Count | ForEach-Object {
            $Percent = $($_ / $Count) * 100
            Write-Progress -Id 1 -Activity "$($Pwsh.ToUpper()) - With Profile" -PercentComplete $Percent
            $WithProfile += (Measure-Command {
                &$Pwsh -command 1
            }).TotalMilliseconds
        }
        Write-Progress -id 1 -activity "$($Pwsh.ToUpper()) - With Profile" -Completed
        $Result['Profile_Average'] = "$($WithProfile/$Count)`ms"

        Return $Result
    }
}

Function New-GitAddCommitPush() {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0)]
        $CommitMessage = "Updating..."
    )

    $writeColor = @{
        ForegroundColor = 'Green'
        BackgroundColor = 'Black'
    }

    Write-Host "Adding all changed files..." @writeColor
    git add .
    Write-Host "Commiting files: $CommitMessage" @writeColor
    git commit -m $CommitMessage
    Write-Host "Pushing changes to remote.." @writeColor
    git push
}
Set-Alias -Name GACP -Value New-GitAddCommitPush

function Git-Whoami {
    $author = git config user.name
    $email = git config user.email

    [pscustomobject]@{
        Author = $author
        Email  = $email
    }
}

Function Update-GitRepos() {
    [CmdletBinding()]
    Param(
        # Specifies a path to one or more locations.
        [Parameter( Position=0,
                    ParameterSetName="Path",
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage="Path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Path = (Get-Location).Path
    )

    Begin {
        #Region Variables
        $OriginalLocation = (Get-Location).Path
        $ErrorColors = @{
            ForegroundColor = 'Red'
            BackGroundColor = 'Black'
        }
        $SuccessColors = @{
            ForegroundColor = 'Green'
            BackGroundColor = 'Black'
        }
        #EndRegion Variables

        #Region Test-GitRepo
        
        Function Test-GitRepo() {
            [CmdletBinding()]
            Param(
                # Specifies a path to one or more locations.
                [Parameter(Position=0,
                           ParameterSetName="Path",
                           ValueFromPipeline=$true,
                           ValueFromPipelineByPropertyName=$true,
                           HelpMessage="Path to one or more locations.")]
                [Alias("PSPath")]
                [ValidateNotNullOrEmpty()]
                [System.String] $Path = (Get-Location).Path
            )

            Process {
                $Path | Foreach-Object {
                    $OriginalLocation = (Get-Location).Path
                    Set-Location $Path
                    Try {
                        If (Test-Path '.git') {
                            git status 1> $null
                        } Else {
                            git status 2> $null
                        }
                        [PSCustomObject] @{
                            Path = $_
                            GitRepo = $?
                        }
                    } Finally {
                        Set-Location $OriginalLocation
                    }
                }
            }
        }
        #EndRegion Test-GitRepo
    }

    Process {
        #TODO: Use this command to recursively search for git repos without running git pull 5000 times
        #! git rev-parse --show-toplevel

        $AllNestedGitRepos = $Path | Foreach-Object {
            Get-ChildItem $_ -Directory -Recurse | Foreach-Object {
                If (Test-Path (Join-Path $_.FullName '.git')) {
                    Set-Location $_.FullName
                    git rev-parse --show-toplevel
                }
            }
        }

        $AllNestedGitRepos | Foreach-Object {
            Try {
                If ((Test-GitRepo $_).GitRepo) {
                    Write-Host "Updating Repo: $($_)" @SuccessColors
                    Set-Location $_
                    git pull
                } Else {
                    Write-Host "Directory $($_) is not a git repo." @ErrorColors
                }
            } Finally {
                Set-Location $OriginalLocation
            }
        }
    }
}

Function Remove-NoteProperty() {
    [CmdletBInding()]
    Param(
        [Parameter(Mandatory)]
        [System.Object] $InputObject,

        [Parameter(Mandatory)]
        [System.String] $NoteProperty
    )

    $Fields = ($InputObject | Get-Member -MemberType NoteProperty | Where-Object {$_.Name -ne $NoteProperty}).Name

    $NewObject = @{}
    Foreach ($Field in $Fields) {
        $NewObject[$Field] = $InputObject.$Field
    }

    $NewObject
}

If (-Not($IsLinux)) {
    #Used to check if running elevated on windows
    $wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $IsAdmin = $prp.IsInRole($adm)
}


<#
.SYNOPSIS
    Used to quickly publish modules to a repository, handling the version control automatically.
.DESCRIPTION
    This function signs the new module to be published, calculates the new version automatically, or based on which switch parameter is provided.
.PARAMETER Module
    Specify the name of the module to publish. If this is an initial publishing, you will need to be case-sensitive with the module name. Once it is already published, you can include all lowercase and it will correct to the case-sensitive name of the module that is already published.
    Additionally, this parameter can take in a file path to a specific module. By default, if you specify just the module name, it will publish the newest available module from `Get-Module $Module -ListAvailable`, but if you want to manually specify a different module path that may have the same name, please use the full/reletive file path to the module folder.
.PARAMETER Repository
    Specify the PSRepository name to publish to. This is set to a default.
.EXAMPLE
    PS>Publish .\HelpDesk.psd1
    Description
    -----------
    This will get the latest data for that module, incriment the revision version value, code-sign the module .psm1 file, and Publish-Module against the PSRepository.
.NOTES
    Author: Matthew J. DeGarmo
    Handle: @matthewjdegarmo
#>
Function Publish() {
    [CmdletBinding(DefaultParameterSetName = "Revision")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.String[]] $Module,

        [System.String] $Repository,

        [Parameter(ParameterSetName = "Major")]
        [Switch] $Major,

        [Parameter(ParameterSetName = "Minor")]
        [Switch] $Minor,

        [Parameter(ParameterSetName = "Build")]
        [Switch] $Build,

        [Parameter(ParameterSetName = "Revision")]
        [Switch] $Revision
    )

    $Module | Foreach-Object {
        $ModuleName = $_
        Try {
            if (-Not(`
                    ($PSBoundParameters.ContainsKey('Major')) -or `
                    ($PSBoundParameters.ContainsKey('Minor')) -or `
                    ($PSBoundParameters.ContainsKey('Build')) -or `
                    ($PSBoundParameters.ContainsKey('Revision'))
                )
            ) {
                $Revision = $true
            }

            Write-Output "[-] Locating module $ModuleName..."
            $ModuleManifestFile = Get-ChildItem $ModuleName -ErrorAction Stop
            $ModuleInfo = Test-ModuleManifest $ModuleManifestFile.FullName
            Write-Output "[+] Success! Module path: $($ModuleInfo.Path)"
            # Write-Output "[-] Signing module..."
            # #?Can signing be removed if the .psm1 file is now static, and the functions themselves are dot sourced?
            # Set-AllScriptSignaturesInPlace $ModuleInfo.Path.Replace('.psd1','.psm1')

            [Version]$CurrentVersion = $ModuleInfo.Version
            $NewMajor = $CurrentVersion.Major
            $NewMinor = $CurrentVersion.Minor
            $NewBuild = $CurrentVersion.Build
            $NewRevision = $CurrentVersion.Revision
            #If $NewRevision is blank it defaults to a -1 value, but -1 is basically a value of 0, so setting this value manually.
            Switch ($NewRevision) {
                '-1' { $NewRevision = 0 }
            }
            #This declares which version catagory to incriment.
            if ($Major.IsPresent) {
                $MajorInt = 1
                $NewMinor = 0
                $NewBuild = 0
                $NewRevision = 0
            }
            if ($Minor.IsPresent) {
                $MinorInt = 1
                $NewBuild = 0
                $NewRevision = 0
            }
            if ($Build.IsPresent) {
                $BuildInt = 1
                $NewRevision = 0
            }
            if ($Revision.IsPresent) {
                $RevisionInt = 1
            }
            #This does math to increment the correct version category.
            $NewMajor = $NewMajor + $MajorInt
            $NewMinor = $NewMinor + $MinorInt
            $NewBuild = $NewBuild + $BuildInt
            $NewRevision = $NewRevision + $RevisionInt
            #If $NewRevision is 0, it will create a version where the revision is blank. Example: 1.0.2.0 -> 1.0.2
            Switch ($NewRevision) {
                0 { [version]$NewVersion = "{0}.{1}.{2}" -f $NewMajor, $NewMinor, $NewBuild }
                { 0 -lt $_ } { [version]$NewVersion = "{0}.{1}.{2}.{3}" -f $NewMajor, $NewMinor, $NewBuild, $_ }
                DEFAULT { Write-Error "What the FLUFF is up with `$NewRevision?"; exit }
            }
            Write-Output "[-] Incrimenting Manifest version from $($CurrentVersion.ToString()) to $($NewVersion.ToString())..."
            Update-ModuleManifest $ModuleInfo.Path.Replace('.psm1', '.psd1') -ModuleVersion $NewVersion
            Write-Output "[-] Publishing module $($ModuleInfo.Name) to $Repository..."
            #This command does the actual publishing. This function is basically a fancy version wrapper for the Publish-Module command.
            Publish-Module -Path $(Split-Path ($ModuleInfo.Path) -Parent) -Repository $Repository
            Write-Output "[+] Successfully published!"
            Write-Output ""
        } Catch {
            Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
}

function Get-AsciiReaction {
    <#
    .SYNOPSIS
    Displays Ascii for different reactions and copies it to clipboard.
    .DESCRIPTION
    Displays Ascii for different reactions and copies it to clipboard.
    .EXAMPLE
    Get-AsciiReaction -Name Shrug
    Displays a shurg and copies it to clipboard.
    .NOTES
    Based on Reddit Thread https://www.reddit.com/r/PowerShell/comments/4aipw5/%E3%83%84/
    and Matt Hodge function: https://github.com/MattHodge/MattHodgePowerShell/blob/master/Fun/Get-Ascii.ps1
    .LINK
        https://github.com/lazywinadmin/PowerShell
#>
    [cmdletbinding()]
    Param
    (
        # Name of the Ascii
        [Parameter()]
        [ValidateSet(
            'Shrug',
            'Disapproval',
            'TableFlip',
            'TableBack',
            'TableFlip2',
            'TableBack2',
            'TableFlip3',
            'Denko',
            'BlowKiss',
            'Lenny',
            'Angry',
            'DontKnow')]
        [System.String]$Name
    )

    $OutputEncoding = [System.Text.Encoding]::unicode

    # Function to write ascii to screen as well as clipboard it
    function Write-Ascii {
        [CmdletBinding()]
        Param
        (
            # Ascii Data
            [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
            [string]$Ascii
        )

        # Clips it without the newline
        Add-Type -Assembly PresentationCore
        $clipText = ($Ascii).ToString() | Out-String -Stream
        [Windows.Clipboard]::SetText($clipText)

        Write-Output $clipText
    }

    Switch ($Name) {
        'Shrug' { [char[]]@(175, 92, 95, 40, 12484, 41, 95, 47, 175) -join '' | Write-Ascii }
        'Disapproval' { [char[]]@(3232, 95, 3232) -join '' | Write-Ascii }
        'TableFlip' { [char[]]@(40, 9583, 176, 9633, 176, 65289, 9583, 65077, 32, 9531, 9473, 9531, 41) -join '' | Write-Ascii }
        'TableBack' { [char[]]@(9516, 9472, 9472, 9516, 32, 175, 92, 95, 40, 12484, 41) -join '' | Write-Ascii }
        'TableFlip2' { [char[]]@(9531, 9473, 9531, 32, 65077, 12541, 40, 96, 1044, 180, 41, 65417, 65077, 32, 9531, 9473, 9531) -join '' | Write-Ascii }
        'TableBack2' { [char[]]@(9516, 9472, 9516, 12494, 40, 32, 186, 32, 95, 32, 186, 12494, 41) -join '' | Write-Ascii }
        'TableFlip3' { [char[]]@(40, 12494, 3232, 30410, 3232, 41, 12494, 24417, 9531, 9473, 9531) -join '' | Write-Ascii }
        'Denko' { [char[]]@(40, 180, 65381, 969, 65381, 96, 41) -join '' | Write-Ascii }
        'BlowKiss' { [char[]]@(40, 42, 94, 51, 94, 41, 47, 126, 9734) -join '' | Write-Ascii }
        'Lenny' { [char[]]@(40, 32, 865, 176, 32, 860, 662, 32, 865, 176, 41) -join '' | Write-Ascii }
        'Angry' { [char[]]@(40, 65283, 65439, 1044, 65439, 41) -join '' | Write-Ascii }
        'DontKnow' { [char[]]@(9488, 40, 39, 65374, 39, 65307, 41, 9484) -join '' | Write-Ascii }
        default {
            [PSCustomObject][ordered]@{
                'Shrug'       = [char[]]@(175, 92, 95, 40, 12484, 41, 95, 47, 175) -join '' | Write-Ascii
                'Disapproval' = [char[]]@(3232, 95, 3232) -join '' | Write-Ascii
                'TableFlip'   = [char[]]@(40, 9583, 176, 9633, 176, 65289, 9583, 65077, 32, 9531, 9473, 9531, 41) -join '' | Write-Ascii
                'TableBack'   = [char[]]@(9516, 9472, 9472, 9516, 32, 175, 92, 95, 40, 12484, 41) -join '' | Write-Ascii
                'TableFlip2'  = [char[]]@(9531, 9473, 9531, 32, 65077, 12541, 40, 96, 1044, 180, 41, 65417, 65077, 32, 9531, 9473, 9531) -join '' | Write-Ascii
                'TableBack2'  = [char[]]@(9516, 9472, 9516, 12494, 40, 32, 186, 32, 95, 32, 186, 12494, 41) -join '' | Write-Ascii
                'TableFlip3'  = [char[]]@(40, 12494, 3232, 30410, 3232, 41, 12494, 24417, 9531, 9473, 9531) -join '' | Write-Ascii
                'Denko'       = [char[]]@(40, 180, 65381, 969, 65381, 96, 41) -join '' | Write-Ascii
                'BlowKiss'    = [char[]]@(40, 42, 94, 51, 94, 41, 47, 126, 9734) -join '' | Write-Ascii
                'Lenny'       = [char[]]@(40, 32, 865, 176, 32, 860, 662, 32, 865, 176, 41) -join '' | Write-Ascii
                'Angry'       = [char[]]@(40, 65283, 65439, 1044, 65439, 41) -join '' | Write-Ascii
                'DontKnow'    = [char[]]@(9488, 40, 39, 65374, 39, 65307, 41, 9484) -join '' | Write-Ascii
            }
        }
    }
}

function Get-Accelerators {
    [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::get
}

Function Get-ErrorTypes() {
    [CmdletBinding()]
    Param()
    [appdomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
        Try {
            $_.GetExportedTypes() | Where-Object { $_.Fullname -match 'Exception' }
        } Catch {}
    } | Select-Object FullName
}

Function Get-ConsoleColors {

    <#
    .SYNOPSIS
        Displays all color options on the screen at one time

    .DESCRIPTION
        Displays all color options on the screen at one time

    .EXAMPLE
        Get-ConsoleColors

    .NOTES
        Name       : Get-ConsoleColors.ps1
        Author     : Mike Kanakos
        Version    : 1.0.3
        DateCreated: 2019-07-23
        DateUpdated: 2019-07-23

        LASTEDIT:
        - Add loops for foreground and background colors
        - output foreground and background colors for easy selection
        
    .LINK
        https://github.com/compwiz32/PowerShell


#>

[CmdletBinding()]
    Param()
    
    $List = [enum]::GetValues([System.ConsoleColor]) 
    
    ForEach ($Color in $List){
        Write-Host "      $Color" -ForegroundColor $Color -NonewLine
        Write-Host "" 
        
    } #end foreground color ForEach loop

    ForEach ($Color in $List){
        Write-Host "                   " -backgroundColor $Color -noNewLine
        Write-Host "   $Color"
                
    } #end background color ForEach loop
    
} #end function
