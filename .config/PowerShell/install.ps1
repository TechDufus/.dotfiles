. (Join-Path $PSScriptRoot 'Install-MyGitRepos.ps1')
#Region Install all fonts
If (Test-Administrator) {
    . (Join-Path $PSScriptRoot 'Install-MyFonts.ps1')
} else {
    Write-Warning "You must run as admin to install fonts at system level."
}
#EndRegion Install all fonts


$PowerShellProfile = "C:\Users\$env:USERNAME\Documents\PowerShell\profile.ps1"

If (Test-Path $PowerShellProfile) {
    $ConfigProfilePath = [System.IO.Path]::Combine("$Home", '.config', 'PowerShell', 'profile.ps1')
    $Pattern = ". `"$ConfigProfilePath`""
    $IsAlreadyReferenced = Get-Content $PowerShellProfile | Select-String -SimpleMatch $Pattern
    If (-Not($IsAlreadyReferenced)) {
        Write-Host "Adding path to .config profile to '$($PowerShellProfile)'"
        $Pattern | Out-File -FilePath $PowerShellProfile -Append -force -Encoding ascii
    }
} else {
    Write-Host "Creating profile: CurrentUserAllHosts: '$($PowerShellProfile)'"
    New-Item -Path $PowerShellProfile -ItemType File -Force
    $ConfigProfilePath = [System.IO.Path]::Combine($Home, '.config', 'PowerShell', 'profile.ps1')
    $Pattern = ". `"$ConfigProfilePath`""
    $Pattern | Out-File -FilePath $PowerShellProfile -Force -Encoding ascii
}