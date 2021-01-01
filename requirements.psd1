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
    'PSReadLine'    = 'latest'
    'posh-git'      = 'latest'
    'ImportExcel'   = 'latest'
    'PowerShellGet' = 'latest'
    'PSake'         = 'latest'
}