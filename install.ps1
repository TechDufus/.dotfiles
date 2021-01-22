$configPath = (Join-Path $PSScriptRoot '.config')

# Set up symlinks
Get-ChildItem -Path $configPath -Directory | ForEach-Object {
    #! Must be admin
    $ConfigScriptRoot = ([System.IO.Path]::Combine($HOME, '.config', $_.Name))
    New-Item -Path $ConfigScriptRoot -ItemType SymbolicLink -Value $_.FullName -ErrorAction SilentlyContinue
    . ([System.IO.Path]::Combine($ConfigScriptRoot, "$($_.FullName)", 'install.ps1'))
}


