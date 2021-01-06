$configPath = $PSScriptRoot

# Set up symlinks
Get-ChildItem -Path $configPath -Directory | ForEach-Object {
    #! Must be admin
    New-Item -Path ([System.IO.Path]::Combine($HOME, '.config', $_.Name)) -ItemType SymbolicLink -Value $_.FullName
}


$IsPSDependInstalled = Get-Module PSDepend -ListAvailable
If (-Not($IsPSDependInstalled)) {
    Write-Host 'Installing PSDepend Module.'
    Install-Module PSDepend -Force
}
Invoke-PSDepend -Force (Join-Path $PSScriptRoot 'requirements.psd1')
. $PSScriptRoot\Install-MyGitRepos.ps1

If (Test-Path $Profile.CurrentUserAllHosts) {
    $IsAlreadyReferenced = $profile.CurrentUserAllHosts | Select-String -SimpleMatch '. "$([System.IO.Path]::Combine($Home, ''.config'', ''PowerShell'', ''))"''profile.ps1''))"'
    If (-Not($IsAlreadyReferenced)) {
        Write-Host "Adding path to .config profile to '$($Profile.CurrentUserAllHosts)'"
        ". $([System.IO.Path]::Combine($Home, '.config', 'PowerShell', 'profile.ps1'))" | Out-File -FilePath $Profile.CurrentUserAllHosts -Append -Force
    }
} else {
    Write-Host "Creating profile: CurrentUserAllHosts: '$($Profile.CurrentUserAllHosts)'"
    New-Item -Path $Profile.CurrentUserAllHosts -ItemType File -Force
    ". $([System.IO.Path]::Combine($Home, '.config', 'PowerShell', 'profile.ps1'))" | Out-File -FilePath $Profile.CurrentUserAllHosts -Force
}
