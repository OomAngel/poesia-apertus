# Start PoesIA on Windows: the model and the page, on the GPU when Docker has the NVIDIA runtime.
#   .\run.ps1            then open http://localhost:8000 (first run downloads ~6 GB)
#   .\run.ps1 -Detach    same, in the background (stop with: docker compose down)
# With your own Apertus endpoint (OpenAI-compatible) instead of the local model:
#   $env:LLM_BASE_URL="https://.../v1"; $env:LLM_NAME="<model>"; $env:LLM_API_KEY="..."; .\run.ps1
param([switch]$Detach)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$files = @("-f", "docker-compose.yml")
$runtimes = docker info --format "{{json .Runtimes}}" 2>$null
if ($runtimes -match "nvidia") {
    $files += @("-f", "docker-compose.gpu.yml")
    Write-Host "NVIDIA GPU runtime found: the model runs on the GPU."
} else {
    Write-Host "No NVIDIA GPU runtime: the model runs on the CPU (a suggestion takes ~15 s)."
}
$up = @("compose") + $files + @("up", "--build")
if ($Detach) { $up += "-d" }
if ($env:LLM_BASE_URL) {
    Write-Host "Using the endpoint in LLM_BASE_URL; the local model is not started."
    $up += @("--no-deps", "web")
}
& docker @up
exit $LASTEXITCODE
