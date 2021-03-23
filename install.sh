#!/bin/bash

scriptroot=`dirname "$BASH_SOURCE"`

. /etc/os-release
powershellfilename=powershell_7.1.3-1.$ID.$VERSION_ID\_amd64.deb

sudo wget -c https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/$powershellfilename -P /opt

sudo dpkg -i /opt/$powershellfilename
sudo apt install -f -y

sudo rm /opt/$powershellfilename

sudo $scriptroot/install.ps1
