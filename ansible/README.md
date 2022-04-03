TODO:

+ Store file for bash profile to add to both ubuntu and wsl..
    + Should there be a common_ubuntu (or just common) role? Until there are ubuntu / wsl specific setup items needed?
    (YES)
Profile should be stored as a local file that ansible will copy. ~/.bash_profile is a good one, but needs to be sourced in ~/.bashrc

SECURITY THOUGHTS:
    instead of using kali, could use ansible to provision a security-focused ubuntu machine to install all the sec tools needed.
    