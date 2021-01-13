#Region Install-Fonts

<#
.SYNOPSIS
    Install fonts on a remote computer.
.DESCRIPTION
    Using a compressed archive of fonts to install (.zip file), this function decompress the archive, and install these fonts on the specified remote servers.
.PARAMETER ComputerName
    Specify remote computers to install fonts on. You must be an admin on the remote computer.
.PARAMETER FontZipFile
    Specify the path to the zipped fonts file.
.PARAMETER FontFile
    Specify the path to a single font file to install.
.PARAMETER Force
    If a fonts folder is already extracted locally with the same name, this will overwrite those files and re-extract.
    Since this script must use a .zip file, using this switch might be common if deploying to different computers with seperate commands.
.EXAMPLE
    PS> Install-Fonts -FontZipFile .\Ferrari-Fonts.zip

    Description
    -----------
    This will install the zipped fonts on these four remote servers.
.EXAMPLE
    PS> Install-Fonts -FontZipFile .\Ferrari-Fonts.zip

    Description
    -----------
    This will install the zipped fonts on the RenderEngine servers stored in the $AnsiraDevOpsToolsProperties.Servers.RenderEngineServers Module variable.
.EXAMPLE
    PS> Install-Fonts -FontFile C:\Temp\Everett-Regular.otf

    Description
    -----------
    This will install this single .OTF font file on the RE Servers.
.NOTES
    Author: Matthew DeGarmo
    Handle: @matthewjdegarmo
#>
Function Install-MyFonts() {
    [CmdletBinding(
        DefaultParameterSetName='FromZip_ParamSet'
    )]
    param(
        [Parameter(Mandatory,ParameterSetName='FromZip_ParamSet')]
        [ValidateNotNullOrEmpty()]
        [System.String] $FontZipFile,

        [Parameter(Mandatory,ParameterSetName='FromFile_ParamSet')]
        [ValidateNotNullOrEmpty()]
        [System.String] $FontFile,

        [Switch] $Force
    )

    Begin {
        if (-Not(Test-Path 'C:\Temp\Fonts')) { $null = New-Item 'C:\Temp\Fonts' -ItemType Directory }
        $fontFolder = 'C:\Temp\Fonts'
        $padVal = 20
        $pcLabel = "Connecting To".PadRight($padVal," ")
        $installLabel = "Installing Font".PadRight($padVal," ")
        $errorLabel = "Computer Unavailable".PadRight($padVal," ")

        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    }

    Process {
        switch($PSCmdlet.ParameterSetName) {
            'FromZip_ParamSet'  {
                if (-Not(Test-Path $FontZipFile)) {
                    Write-Warning "$FontZipFile - Not Found"
                } else {
                    $SnapshotFiles = Get-ChildItem -Path $FontFolder -Recurse
                    $null=Expand-Archive -Path $FontZipFile -DestinationPath $fontFolder -Force:$Force
                    If ($null -eq $SnapshotFiles) {
                        $UnzippedFiles = Get-ChildItem $FontFolder -Recurse
                    } else {
                        $PostExpandFiles = Get-ChildItem -Path $FontFolder -Recurse
                        $UnzippedFiles = Compare-Object $SnapshotFiles $PostExpandFiles -PassThru | Where-Object {$_.SideIndicator -eq '=>'} | Select-Object -ExcludeProperty SideIndicator
                    }
                }
            }
            'FromFile_ParamSet' {
                $UnzippedFiles = Get-ChildItem $FontFile
            }
            DEFAULT {}
        }
        Try {
            $destination = [System.IO.Path]::Combine("$env:SystemDrive\",'Windows','Fonts')
            $UnzippedFiles | Foreach-Object {
                $file = $_
                if (($file.Extension -eq '.otf') -or ($file.Extension -eq '.ttf')<# -or ($file.Extension -eq '.woff')#>) {
                    switch ($File.Extension) {
                        '.otf' { $Type = "(OpenType)"}
                        '.ttf' { $Type = "(TrueType)"}
                    }
                    $fontName = $file.BaseName
                    $regKeyName = $fontName,$Type -join " "
                    $regKeyValue = $file.Name
                    Write-Output "$env:COMPUTERNAME : $installLabel : $regKeyValue"
                    Copy-Item $file.Fullname $destination
                    $null = New-ItemProperty -Path $regPath -Name $regKeyname -Value $regKeyValue -PropertyType String -Force
                }
            }
        } catch {
            Write-Warning "$pcName : $using:errorLabel : $pcName"
        }
    }
}
#EndRegion Install-Fonts


$repo = 'ryanoasis/nerd-fonts'

$release = "https://github.com/$repo/releases/latest"
$destinationFile = [System.IO.Path]::Combine("$env:SystemDrive\", 'Temp', 'Hack.zip')
$tag = (Invoke-WebRequest -Uri $release -UseBasicParsing)
$download = ($tag.Links -match "/$repo/releases/download/.*/Hack.zip").href
$download = "https://github.com$download"
Invoke-WebRequest "$download" -OutFile $destinationFile
Install-MyFonts -FontZipFile $destinationFile -Force
Remove-Item $DestinationFile -Force

