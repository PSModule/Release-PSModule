#REQUIRES -Modules Utilities

[CmdletBinding()]
param()

Start-LogGroup 'Loading helper scripts'
Get-ChildItem -Path (Join-Path -Path $env:GITHUB_ACTION_PATH -ChildPath 'scripts' 'helpers') -Filter '*.ps1' -Recurse |
    ForEach-Object { Write-Verbose "[$($_.FullName)]"; . $_.FullName }
Stop-LogGroup

Start-LogGroup 'Loading inputs'
Write-Verbose "Name:              [$env:GITHUB_ACTION_INPUT_Name]"
Write-Verbose "GITHUB_REPOSITORY: [$env:GITHUB_REPOSITORY]"
Write-Verbose "GITHUB_WORKSPACE:  [$env:GITHUB_WORKSPACE]"

$name = ($env:GITHUB_ACTION_INPUT_Name | IsNullOrEmpty) ? $env:GITHUB_REPOSITORY_NAME : $env:GITHUB_ACTION_INPUT_Name
Write-Verbose "Module name:       [$name]"
Write-Verbose "Module path:       [$env:GITHUB_ACTION_INPUT_ModulePath]"
Write-Verbose "Doc path:          [$env:GITHUB_ACTION_INPUT_DocsPath]"

$modulePath = Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath $env:GITHUB_ACTION_INPUT_ModulePath $name
Write-Verbose "Module path:       [$modulePath]"
if (-not (Test-Path -Path $modulePath)) {
    throw "Module path [$modulePath] does not exist."
}
$docsPath = Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath $env:GITHUB_ACTION_INPUT_DocsPath $name
Write-Verbose "Docs path:         [$docsPath]"
if (-not (Test-Path -Path $docsPath)) {
    throw "Documentation path [$docsPath] does not exist."
}
Stop-LogGroup

$params = @{
    Name       = $name
    ModulePath = $modulePath
    DocsPath   = $docsPath
    APIKey     = $env:GITHUB_ACTION_INPUT_APIKey
}
Publish-PSModule @params -Verbose
