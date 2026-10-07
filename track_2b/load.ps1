# Restore a PoesIA bundle made by bundle.sh, with no network. Then: .\run.ps1 -Offline
#   .\load.ps1 [folder]    default: the folder this script is in, else poesia-bundle\
param([string]$Bundle = "")
$ErrorActionPreference = "Stop"
if (-not $Bundle) {
    $Bundle = if (Test-Path (Join-Path $PSScriptRoot "images.tar.gz")) { $PSScriptRoot } else {
        Join-Path $PSScriptRoot "poesia-bundle" }
}
Set-Location $Bundle
Write-Host "Checking the files..."
foreach ($line in Get-Content SHA256SUMS) {
    $want, $name = $line -split "\s+\*?", 2
    $got = (Get-FileHash -Algorithm SHA256 $name).Hash
    if ($got -ne $want) { throw "$name is damaged (checksum differs); copy it again." }
    Write-Host "${name}: OK"
}
Write-Host "Loading the images..."
docker load -i images.tar.gz
if ($LASTEXITCODE) { exit $LASTEXITCODE }
Write-Host "Restoring the models..."
# The volume carries compose's labels so compose adopts it as its own; no container is made
# here (one left behind would be reused by the next start with stale network settings).
docker volume create --label com.docker.compose.project=poesia-apertus `
    --label com.docker.compose.volume=ollama poesia-apertus_ollama | Out-Null
$image = (Select-String -Path docker-compose.yml -Pattern "image:\s*(ollama/ollama:\S+)").Matches[0].Groups[1].Value
# A bind mount, not a pipe: Windows PowerShell 5.1 would alter binary data sent through a pipe.
docker run --rm -v "poesia-apertus_ollama:/root/.ollama" -v "${PWD}:/bundle:ro" `
    --entrypoint tar $image -C /root/.ollama -xf /bundle/models.tar
if ($LASTEXITCODE) { exit $LASTEXITCODE }
Write-Host "Done. Start it with .\run.ps1 -Offline"
