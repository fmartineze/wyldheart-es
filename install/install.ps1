# Instalador de la traducción al español de Wyldheart Demo.
# Uso: Instalar.bat / Desinstalar.bat (o: powershell -File install.ps1 [-Uninstall] [-GamePath <ruta>])
param(
    [switch]$Uninstall,
    [string]$GamePath
)
$ErrorActionPreference = 'Stop'
$GameDir = 'steamapps\common\Wyldheart Demo'
$PakRel = 'Kauri\Content\Paks'
$Files = 'zz_Spanish_P.pak', 'zz_Spanish_P.utoc', 'zz_Spanish_P.ucas'

function Test-Game($dir) {
    $dir -and (Test-Path (Join-Path $dir "$PakRel\Kauri-Windows.pak"))
}

function Find-Game {
    $steamRoots = @()
    foreach ($key in 'HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
        $p = Get-ItemProperty $key -ErrorAction SilentlyContinue
        if ($p.SteamPath) { $steamRoots += $p.SteamPath }
        if ($p.InstallPath) { $steamRoots += $p.InstallPath }
    }
    $libraries = @()
    foreach ($root in $steamRoots | Select-Object -Unique) {
        $libraries += $root
        $vdf = Join-Path $root 'steamapps\libraryfolders.vdf'
        if (Test-Path $vdf) {
            foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) {
                $libraries += $m.Groups[1].Value -replace '\\\\', '\'
            }
        }
    }
    foreach ($lib in $libraries | Select-Object -Unique) {
        $dir = Join-Path ($lib -replace '/', '\') $GameDir
        if (Test-Game $dir) { return $dir }
    }
    return $null
}

function Select-GameFolder {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = 'No he encontrado el juego. Selecciona la carpeta "Wyldheart Demo".'
    if ($dlg.ShowDialog() -eq 'OK' -and (Test-Game $dlg.SelectedPath)) { return $dlg.SelectedPath }
    return $null
}

function Restart-Elevated($game) {
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -GamePath `"$game`""
    if ($Uninstall) { $argList += ' -Uninstall' }
    Start-Process powershell -Verb RunAs -ArgumentList $argList
    exit
}

try {
    Write-Host ''
    Write-Host '=== Wyldheart Demo - Traducción al español ===' -ForegroundColor Cyan
    Write-Host ''

    $game = if (Test-Game $GamePath) { $GamePath } else { Find-Game }
    if (-not $game) { $game = Select-GameFolder }
    if (-not $game) { throw 'No se ha encontrado la carpeta de Wyldheart Demo.' }
    Write-Host "Juego encontrado en: $game"

    $mods = Join-Path $game "$PakRel\~mods"
    try {
        if ($Uninstall) {
            foreach ($f in $Files) { Remove-Item (Join-Path $mods $f) -ErrorAction SilentlyContinue }
            if ((Test-Path $mods) -and -not (Get-ChildItem $mods)) { Remove-Item $mods }
            Write-Host ''
            Write-Host 'Traducción desinstalada.' -ForegroundColor Green
        }
        else {
            New-Item -ItemType Directory -Force $mods | Out-Null
            foreach ($f in $Files) { Copy-Item (Join-Path $PSScriptRoot "mod\$f") $mods -Force }
            Write-Host ''
            Write-Host 'Traducción instalada correctamente.' -ForegroundColor Green
            Write-Host ''
            Write-Host 'IMPORTANTE: en el juego ve a Options > GAMEPLAY > Language' -ForegroundColor Yellow
            Write-Host 'y elige "français". El español sustituye al francés.' -ForegroundColor Yellow
            Write-Host 'Reinicia el juego después de cambiar el idioma.' -ForegroundColor Yellow
        }
    }
    catch {
        $denied = $_.Exception -is [System.UnauthorizedAccessException] -or $_.CategoryInfo.Category -eq 'PermissionDenied'
        if (-not $denied) { throw }
        Write-Host 'Hacen falta permisos de administrador. Reintentando...'
        Restart-Elevated $game
    }
}
catch {
    Write-Host ''
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ''
Read-Host 'Pulsa Enter para salir'
