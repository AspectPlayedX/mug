# MUG bootstrap.
#
# Downloads the newest release and runs it, so nobody needs a copy of the
# exe beforehand:
#
#   irm https://raw.githubusercontent.com/AspectPlayedX/mug/main/run.ps1 | iex
#
# Set $Repo below to the repository holding the releases. That repo has to
# be PUBLIC -- GitHub requires a token to download assets from a private
# one, and shipping a token in a script anyone can read defeats the point.
# The source doesn't have to be public though: a repo containing nothing
# but releases works fine and keeps the code private.

$ErrorActionPreference = 'Stop'

$Repo  = 'AspectPlayedX/mug'
$Asset = 'mug-loader.exe'      # release asset filename

# TLS 1.2 for older Windows 10 builds, where PowerShell still defaults to
# TLS 1.0 and every GitHub request fails with a confusing handshake error.
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }

Write-Host ''
Write-Host '  MUG' -ForegroundColor Cyan -NoNewline
Write-Host ' // utility toolkit'
Write-Host ''

if ($Repo -eq 'OWNER/REPO') {
    Write-Host '  run.ps1 has not been configured yet -- set $Repo first.' -ForegroundColor Red
    return
}

Write-Host '  [..] finding latest release' -NoNewline
try {
    $rel = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest" `
        -Headers @{ 'User-Agent' = 'mug-bootstrap' }
} catch {
    Write-Host "`r  [!!] could not reach GitHub: $($_.Exception.Message)" -ForegroundColor Red
    return
}

$dl = ($rel.assets | Where-Object { $_.name -eq $Asset } | Select-Object -First 1).browser_download_url
if (-not $dl) {
    Write-Host "`r  [!!] release $($rel.tag_name) has no asset named $Asset" -ForegroundColor Red
    Write-Host ('       assets: ' + (($rel.assets | ForEach-Object { $_.name }) -join ', '))
    return
}
Write-Host "`r  [ok] latest is $($rel.tag_name)                    "

# Versioned filename so an old copy is never reused after an update.
$dir = Join-Path $env:LOCALAPPDATA 'MUG'
New-Item -ItemType Directory -Force $dir | Out-Null
$exe = Join-Path $dir ("mug-" + $rel.tag_name + ".exe")

if (Test-Path $exe) {
    Write-Host '  [ok] already downloaded'
} else {
    Write-Host '  [..] downloading' -NoNewline
    try {
        Invoke-WebRequest $dl -OutFile $exe -UseBasicParsing
        Write-Host "`r  [ok] downloaded to $exe"
    } catch {
        Write-Host "`r  [!!] download failed: $($_.Exception.Message)" -ForegroundColor Red
        return
    }
}

Write-Host '  [..] launching'
Write-Host ''
Start-Process $exe
