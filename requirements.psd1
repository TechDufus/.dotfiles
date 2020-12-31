@{
    PSDependOptions = @{
        Target     = 'CurrentUser'
        Parameters = @{
            Repository      = 'PSGallery'
            AllowPrerelease = $True
        }
    }

    'oh-my-posh'    = 'latest'
    'AdminToolkit'  = 'latest'
    'HelpDesk'      = 'latest'
}