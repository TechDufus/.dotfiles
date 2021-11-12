#!/bin/pwsh

[CmdletBinding()]
Param(
    [Switch] $IncludePowerShellGitRepos
)

$IsPSDependInstalled = Get-Module PSDepend -ListAvailable
If (-Not($IsPSDependInstalled)) {
    Write-Host 'Installing PSDepend Module.'
    Install-Module PSDepend -Force
}
Invoke-PSDepend -Force (Join-Path $PSScriptRoot 'requirements.psd1')


If ($IncludePowerShellGitRepos.IsPresent) {
    . (Join-Path $PSScriptRoot 'Install-MyGitRepos.ps1')
}
#Region Install all fonts
If ($IsLinux -eq $false -or $null -eq $IsLinux) {
    If (Test-Administrator) {
        . (Join-Path $PSScriptRoot 'Install-MyFonts.ps1')
    } else {
        Write-Warning "You must run as admin to install fonts at system level."
    }
}
#EndRegion Install all fonts


$PowerShellProfile = $Profile.CurrentUserAllHosts

If (Test-Path $PowerShellProfile) {
    $ConfigProfilePath = Join-Path $PSScriptRoot 'profile.ps1'
    $Pattern = ". `"$ConfigProfilePath`""
    $IsAlreadyReferenced = Get-Content $PowerShellProfile | Select-String -SimpleMatch $Pattern
    If (-Not($IsAlreadyReferenced)) {
        Write-Host "Adding path to .config profile to '$($PowerShellProfile)'"
        $Pattern | Out-File -FilePath $PowerShellProfile -Append -force -Encoding ascii
    }
} else {
    Write-Host "Creating profile: CurrentUserAllHosts: '$($PowerShellProfile)'"
    New-Item -Path $PowerShellProfile -ItemType File -Force
    $ConfigProfilePath = Join-Path $PSScriptRoot 'profile.ps1'
    $Pattern = ". `"$ConfigProfilePath`""
    $Pattern | Out-File -FilePath $PowerShellProfile -Force -Encoding ascii
}