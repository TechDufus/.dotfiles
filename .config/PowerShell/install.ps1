. (Join-Path $PSScriptRoot 'Install-MyGitRepos.ps1')
#Region Install all fonts
If (Test-Administrator) {
    . (Join-Path $PSScriptRoot 'Install-MyFonts.ps1')
} else {
    Write-Warning "You must run as admin to install fonts at system level."
}
#EndRegion Install all fonts

If (Test-Path $Profile.CurrentUserAllHosts) {
    $IsAlreadyReferenced = $profile.CurrentUserAllHosts | Select-String -SimpleMatch '. `"$([System.IO.Path]::Combine($Home, ''.config'', ''PowerShell'', ''))"''profile.ps1''))`"'
    If (-Not($IsAlreadyReferenced)) {
        Write-Host "Adding path to .config profile to '$($Profile.CurrentUserAllHosts)'"
        ". $([System.IO.Path]::Combine($Home, '.config', 'PowerShell', 'profile.ps1'))" | Out-File -FilePath $Profile.CurrentUserAllHosts -Append -Force
    }
} else {
    Write-Host "Creating profile: CurrentUserAllHosts: '$($Profile.CurrentUserAllHosts)'"
    New-Item -Path $Profile.CurrentUserAllHosts -ItemType File -Force
    ". $([System.IO.Path]::Combine($Home, '.config', 'PowerShell', 'profile.ps1'))" | Out-File -FilePath $Profile.CurrentUserAllHosts -Force
}