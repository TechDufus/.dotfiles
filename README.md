# Matthew DeGarmo's PowerShell Profile
This is where store my PowerShell profile.
Ideally you would need to be an admin to run this..

Simply Clone this directory and run the `install.ps1`.

The installation will:
1. Create symbolic links.
2. Install and Invoke [PSDepend](https://github.com/RamblingCookieMonster/PSDepend)
   1. PSDepend will install the dependencies listed in the [requirements.psd1](./requirements.psd1)
3. Clone Git Repos listed in [Invoke-MyGitRepos](./Install-MyGitRepos.ps1) formatted username/reponame
4. Test for `$Profile.CurrentUserAllHosts` file and add the dotsource code to the [profile.ps1](./PowerShell/profile.ps1) profile.
