#Region Variables
$Repos = @(
    'matthewjdegarmo/Stream',
    'matthewjdegarmo/MyTop8',
    'matthewjdegarmo/AdventOfCode2020',
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
Set-Location Join-Path $GitHubPath fonts
.\install.ps1
#EndRegion Install all fonts
