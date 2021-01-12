#Region Variables
$Repos = @(
    'matthewjdegarmo/Stream',
    'matthewjdegarmo/MyTop8',
    'matthewjdegarmo/HelpDesk',
    'matthewjdegarmo/AdminToolkit',
    'matthewjdegarmo/matthewjdegarmo',
    'matthewjdegarmo/matthewjdegarmo.github.io',
    'matthewjdegarmo/PSTeams',
    'powerline/fonts'
)
$GitHubPath = 'C:\Projects\GitHub'
#EndRegion Variables

#Region Git Environment Setup
If (-Not(Test-Path $GitHubPath)) {
    New-Item -Name $GitHubPath -ItemType Directory
}
Set-Location $GitHubPath
#EndRegion Git Environment Setup

#Region Clone Git Repos
$Repos | Foreach-Object -ThrottleLimit $Repos.Count -Parallel {
    git clone https://github.com/$_`.git
}
#EndRegion Clone Git Repos

#Region Install all fonts
If (Test-Administrator) {
    Set-Location (Join-Path $GitHubPath 'fonts')
    .\install.ps1
    Remove-Item (Join-Path $GitHubPath 'fonts') -Recurse -Force
} else {
    Write-Warning "You must run as admin to install fonts at system level."
}
#EndRegion Install all fonts
