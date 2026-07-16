$ErrorActionPreference = "Stop"

function Resolve-GodotCommand {
    foreach ($command in @("godot", "godot4")) {
        if (Get-Command $command -ErrorAction SilentlyContinue) { return $command }
    }
    foreach ($path in @(
        "C:\Tools\Godot\Godot_v4.7-stable_win64_console.exe",
        "C:\Tools\Godot\Godot_v4.7-stable_win64.exe"
    )) {
        if (Test-Path -LiteralPath $path) { return $path }
    }
    throw "Godot 4.7 was not found in PATH or C:\Tools\Godot."
}

python tools/validate_catalog.py
if ($LASTEXITCODE -ne 0) { throw "Catalog validation failed." }

$Godot = Resolve-GodotCommand
New-Item -ItemType Directory -Force "docs" | Out-Null
& $Godot --headless --path . --import
if ($LASTEXITCODE -ne 0) { throw "Import failed." }
& $Godot --headless --path . --script res://tests/smoke_test.gd
if ($LASTEXITCODE -ne 0) { throw "Smoke test failed." }
& $Godot --headless --path . --export-release "Web" "docs/index.html"
if ($LASTEXITCODE -ne 0) { throw "Web export failed. Verify that the Godot 4.7 Web export templates are installed." }
Write-Host "Web build ready at docs/index.html"
