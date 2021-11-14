#Install winfetch script on windows
if ($IsWindows -or $PSVersionTable.PSVersion.Major -eq 5) {
    $IsInstalled = Get-InstalledScript 'pwshfetch-test-1' -ErrorAction SilentlyContinue
    If (-Not($IsInstalled)) {
        Install-Script -Name 'pwshfetch-test-1' -Repository 'PSGallery' -Force
    }
}


#Pending PSGalleryScript support within PSDepend : See [PR #134](https://github.com/RamblingCookieMonster/PSDepend/pull/134)
# $IsPSDependInstalled = Get-Module PSDepend -ListAvailable
# If (-Not($IsPSDependInstalled)) {
#     Write-Host 'Installing PSDepend Module.'
#     Install-Module PSDepend -Force
# }
# Invoke-PSDepend -Force (Join-Path $PSScriptRoot 'requirements.psd1')
