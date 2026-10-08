# Start PoesIA on Windows without Docker: needs only the Ollama app (https://ollama.com/download)
# and uv (https://docs.astral.sh/uv/; it fetches Python itself).
#   .\run-native.ps1     then the browser opens http://localhost:8000
# First run: installs the page (~230 MB), fetches the read-back voices (~290 MB) and, on the
# page with progress, the models into Ollama (~6 GB). After that no network is needed.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
# The engine at the commit this entry was tested with (same as src/Dockerfile).
$ref = "723a209f2c78ba34a2705e6eaa991a08e144178c"
if (-not (Get-Command uvx -ErrorAction SilentlyContinue)) {
    Write-Host "uv is missing. Install it with:"
    Write-Host '  powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"'
    exit 1
}
uvx --python 3.13 `
    --from "poesia[web,spanish,english-scan,recitation] @ https://github.com/OomAngel/poesia/archive/$ref.zip" `
    poesia-web --with-ollama --link-index data/linking --open @args
exit $LASTEXITCODE
