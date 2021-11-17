# Matthew DeGarmo's PowerShell Profile
This is where store my PowerShell profile.
Ideally you would need to be an admin to run this..

Simply Clone this directory and run the `install.ps1`.

The installation will:

PowerShell:
1. Install and/or Invoke [PSDepend](https://github.com/RamblingCookieMonster/PSDepend)
   1. PSDepend will install the dependencies listed in the [requirements.psd1](https://github.com/matthewjdegarmo/dotfiles/blob/main/.config/PowerShell/requirements.psd1)
2. Clone Git Repos listed in [Invoke-MyGitRepos](./Install-MyGitRepos.ps1) formatted username/reponame
3. Test for `$Profile.CurrentUserAllHosts` file and add the dotsource code to the [profile.ps1](./PowerShell/profile.ps1) profile.

WinFetch:
1. On Windows, will install the winfetch (currently named 'pwshfetch-test-1') script from the PSGallery.
