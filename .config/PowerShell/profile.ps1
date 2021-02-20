#Region UX Config
$hasOhMyPosh = Import-Module oh-my-posh -MinimumVersion 3.0 -PassThru -ErrorAction SilentlyContinue
if ($hasOhMyPosh) {
    $themePath = Join-Path $PSScriptRoot 'posh-theme.json'
    if (Test-Path $themePath) {
        Set-PoshPrompt -Theme $themePath
    } else {
        Set-PoshPrompt -Theme powerlevel10k_classic
    }
}

if (Get-Module PSReadLine) {
    Set-PSReadLineKeyHandler -Chord Alt+Enter -Function AddLine
    Set-PSReadLineOption -ContinuationPrompt "  " -PredictionSource History -Colors @{
        Operator         = "`e[95m"
        Parameter        = "`e[95m"
        InlinePrediction = "`e[36;7;238m"
    }
    
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadlineOption -BellStyle None
}
#EndRegion UX Config

Function Get-GitLog() {
    git log --oneline --graph --decorate
}
Set-Alias -Name GGL -Value Get-GitLog

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
        [System.String] $Path = (Get-Location).Path
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
        Get-ChildItem $Path -Directory | Foreach-Object {
            Try {
                If ((Test-GitRepo $_.FullName).GitRepo) {
                    Write-Host "Updating Repo: $($_.FullName)" @SuccessColors
                    Set-Location $_.FullName
                    git pull
                } Else {
                    Write-Host "Directory $($_.FullName) is not a git repo." @ErrorColors
                }
            } Finally {
                Set-Location $OriginalLocation
            }
        }
    }
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

<#
.SYNOPSIS
    Used to allow PowerShell to speak to you or sends data to a WAV file for later listening.
.DESCRIPTION
    Used to allow PowerShell to speak to you or sends data to a WAV file for later listening.
.PARAMETER InputObject
    Data that will be spoken or sent to a WAV file.
.PARAMETER Rate
    Sets the speaking rate
.PARAMETER Volume
    Sets the output volume
.PARAMETER ToWavFile
    Append output to a Waveform audio format file in a specified format
.NOTES
    Name: Out-Voice
    Author: Boe Prox
    DateCreated: 12/4/2013
    To Do:
        -Support for other installed voices
.EXAMPLE
    "This is a test" | Out-Voice

    Description
    -----------
    Speaks the string that was given to the function in the pipeline.
.EXAMPLE
    "Today's date is $((get-date).toshortdatestring())" | Out-Voice

    Description
    -----------
    Says todays date
 .EXAMPLE
    "Today's date is $((get-date).toshortdatestring())" | Out-Voice -ToWavFile "C:\temp\test.wav"

    Description
    -----------
    Says todays date
#>
Function Out-Voice {
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = 'True')]
        [string[]]$InputObject,
        [parameter()]
        [ValidateRange(-10, 10)]
        [Int]$Rate,
        [parameter()]
        [ValidateRange(1, 100)]
        $Volume,
        [parameter()]
        [string]$ToWavFile
    )
    Begin {
        $Script:parameter = $PSBoundParameters
        Write-Verbose "Listing parameters being used"
        $PSBoundParameters.GetEnumerator() | Foreach-Object {
            Write-Verbose "$($_)"
        }
        Write-Verbose "Loading assemblies"
        Add-Type -AssemblyName System.speech
        Write-Verbose "Creating Speech object"
        $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
        Write-Verbose "Setting volume"
        If ($PSBoundParameters['Volume']) {
            $speak.Volume = $PSBoundParameters['Volume']
        } Else {
            Write-Verbose "No volume given, using default: 100"
            $speak.Volume = 100
        }
        Write-Verbose "Setting speech rate"
        If ($PSBoundParameters['Rate']) {
            $speak.Rate = $PSBoundParameters['Rate']
        } Else {
            Write-Verbose "No rate given, using default: -2"
            $speak.rate = -2
        }
        If ($PSBoundParameters['WavFile']) {
            Write-Verbose "Saving speech to wavfile: $wavfile"
            $speak.SetOutputToWaveFile($wavfile)
        }
    }
    Process {
        ForEach ($line in $inputobject) {
            Write-Verbose "Speaking: $line"
            $Speak.SpeakAsync(($line | Out-String)) | Out-Null
        }
    }
    End {
        If ($PSBoundParameters['ToWavFile']) {
            Write-Verbose "Performing cleanup"
            $speak.dispose()
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
