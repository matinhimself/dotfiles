

Import-Module posh-git
Import-Module git-aliases -DisableNameChecking
Import-Module -Name Terminal-Icons
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -Colors @{ "InlinePrediction"="#8F8F8F" }
Set-PSReadLineOption -Colors @{ "Parameter"="#7A618A" }
Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function ForwardWord

$pswindow=(Get-Host).UI.RawUI


oh-my-posh --init --shell pwsh --config ~\AppData\Local\Programs\oh-my-posh\themes\.\bubblesextra.omp.json | Invoke-Expression

# For zoxide v0.8.0+
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell | Out-String)
})

# Sudo
function sudo() {
    if ($args.Length -eq 1) {
        start-process $args[0] -verb "runAs"
    }
    if ($args.Length -gt 1) {
        start-process $args[0] -ArgumentList $args[1..$args.Length] -verb "runAs"
    }
}

# utils
function Get-Random-Name([String]$prefix) {
    $timestamp = (Get-Date).Ticks.ToString().Substring(4,7)
    return "$prefix$timestamp"
}


# rezip files into a already zipped zip file
# from current directory
function zch()
{
    Param($ZipFile)
    $NewZipPath = "./$(Get-Random-Name $ZipFile)zip"
    echo $NewZipPath
    [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') > $null
    [IO.Compression.ZipFile]::OpenRead((Get-Item $ZipFile).FullName).Entries.FullName |
        Compress-Archive -DestinationPath $NewZipPath
}

function lsdd()
{
    dir | Format-Wide  -Column (($pswindow.windowsize.Width) / 35);
}


# Aliases
Set-Alias -Name ls -Value lsdd  -Option  AllScope

Set-Alias -Name dockerstart -Value "C:\Program Files\Docker\Docker\Docker Desktop.exe" 


# there is a whereis equivalent in windows 
# located in C:\Windows\System32\where.exe
# but also there is a default where allias
# where -> Where-Object.
Set-Alias -Name whereis -Value 'C:\Windows\System32\where.exe' -Option  AllScope



function wts(){wt -w 0 sp -d $PWD;}

function wsu(){wt -w 0 sp -d $PWD -p "u";Start-Sleep -s 1; cls}

function wnt(){wt -w 0 nt -d $PWD;}

function la(){lsd -A}

function lt(){lsd --tree}

function laa(){lsd -lA}


# https://github.com/codeskyblue/gohttpserver
function gserv {
    Invoke-Expression "gohttpserver -r $pwd --port 8765 --upload"
}

function gget {
    Param($url)
    try {
        $ENV:http_proxy='127.0.0.1:10810'; go get $url

    } catch {""}}


# get ports procces?
function Get-Port-Procces {
    Param($Port)
    try {
        Get-Process -Id (Get-NetTCPConnection -LocalPort $Port -ErrorAction Stop).OwningProcess
    } catch {
        "Port is free."
    }
}


# uploads a file or directory in transfer.sh
function transfer([String] $path) {
    if (!(Test-Path -Path $path -PathType Leaf)) {
        $zpath = "./$(Get-Random-Name (get-item $path).Name).zip"
        Compress-Archive -Path $path -DestinationPath $zpath
    } else {
        $zpath = $path
    }
    $url = (Invoke-WebRequest -uri https://transfer.sh/$zpath -Method Put -InFile $zpath).Content    
    Set-Clipboard -Value $url
    echo $url
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

function setenv([String] $variable, [String] $value) {
    Set-ItemProperty "HKCU:\Environment" $variable $value
    Invoke-Expression "`$env:${variable} = `"$value`""
}