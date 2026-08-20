$ErrorActionPreference = 'Stop'

$Repo  = 'AspectPlayedX/mug'
$Asset = 'mug-loader.exe'

# Older Windows 10 defaults to TLS 1.0, which GitHub rejects.
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }

Write-Host ''
Write-Host '  MUG' -ForegroundColor Cyan -NoNewline
Write-Host ' // utility toolkit'
Write-Host ''

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
