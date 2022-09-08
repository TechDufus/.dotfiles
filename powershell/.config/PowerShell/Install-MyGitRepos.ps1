#Region Variables
$Repos = @(
    'matthewjdegarmo/Stream',
    'matthewjdegarmo/MyTop8',
    'matthewjdegarmo/HelpDesk',
    'matthewjdegarmo/AdminToolkit',
    'matthewjdegarmo/matthewjdegarmo',
    'matthewjdegarmo/matthewjdegarmo.github.io',
    'matthewjdegarmo/PSTeams'
)
#EndRegion Variables


Push-Location $script:RootPath
#EndRegion Git Environment Setup

#Region Clone Git Repos
$Repos | Foreach-Object -ThrottleLimit $Repos.Count -Parallel {
    git clone https://github.com/$_`.git
}

Pop-Location
#EndRegion Clone Git Repos