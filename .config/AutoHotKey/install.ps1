#TODO: Create a shortcut for each file in this directory in the startup folder

Get-ChildItem $PSScriptRoot -Filter '*.ahk' | Foreach-Object {
    Write-Host "Creating shortcut for $($_.Name)"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\$($_.Basename).lnk")
    $shortcut.TargetPath = $_.FullName
    $shortcut.Save()
}

