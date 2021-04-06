@{
    PSDependOptions = @{
        Target     = 'CurrentUser'
        Parameters = @{
            Repository      = 'PSGallery'
            AllowPrerelease = $True
        }
    }

    'Terminal-Icons'    = 'latest'
    'oh-my-posh'        = 'latest'
    'AdminToolkit'      = 'latest'
    'HelpDesk'          = 'latest'
    'PSReadLine'        = 'latest'
    'posh-git'          = 'latest'
    'ImportExcel'       = 'latest'
    'PowerShellGet'     = 'latest'
    'PackageManagement' = 'latest'
    'PSake'             = 'latest'
    'EditorServicesCommandSuite'  = 'latest'
    'Microsoft.PowerShell.ConsoleGuiTools' = 'latest'
}