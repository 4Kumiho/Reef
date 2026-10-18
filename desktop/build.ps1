# Ricrea «Reef Staff.exe» nella radice della repo.
# Serve solo a chi modifica il codice: chi usa l'app apre direttamente l'eseguibile.
#
# Uso (PowerShell, dalla radice della repo):   .\desktop\build.ps1
# La prima volta crea l'ambiente Python in .venv (fuori dalla repo, una cartella sopra).
# PyInstaller scrive i suoi messaggi su stderr: non vanno trattati come errori
$ErrorActionPreference = "Continue"
$Radice = Split-Path -Parent $PSScriptRoot
$Venv = Join-Path (Split-Path -Parent $Radice) ".venv"
$Py = Join-Path $Venv "Scripts\python.exe"

if (-not (Test-Path $Py)) {
    Write-Host "Creo l'ambiente Python in $Venv ..."
    python -m venv $Venv
    if ($LASTEXITCODE -ne 0) { throw "Python non trovato: installalo da python.org" }
    & $Py -m pip install --disable-pip-version-check -r (Join-Path $PSScriptRoot "requirements.txt")
}

$Lavoro = Join-Path $env:TEMP "reef-build"
& $Py -m PyInstaller (Join-Path $PSScriptRoot "reef.spec") --noconfirm --clean --distpath $Radice --workpath $Lavoro
if ($LASTEXITCODE -ne 0) { throw "Build non riuscita" }
Write-Host ""
Write-Host "Fatto: $(Join-Path $Radice 'Reef Staff.exe')"
