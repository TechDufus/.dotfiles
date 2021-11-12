#Install winfetch script on windows
if ($IsWindows -or $PSVersionTable.PSVersion.Major -eq 5) {
    $IsInstalled = Get-InstalledScript 'pwshfetch-test-1'
    If (-Not($IsInstalled)) {
        Install-Script -Name 'pwshfetch-test-1' -Repository 'PSGallery'
    }
}
