$ErrorActionPreference = "Stop"

function Resolve-GodotCommand {
    foreach ($command in @("godot", "godot4")) {
        if (Get-Command $command -ErrorAction SilentlyContinue) { return $command }
    }
    throw "Không tìm thấy Godot 4.7 trong PATH."
}

python tools/validate_catalog.py
if ($LASTEXITCODE -ne 0) { throw "Catalog validation failed." }

$Godot = Resolve-GodotCommand
New-Item -ItemType Directory -Force "build/web" | Out-Null
& $Godot --headless --path . --import
if ($LASTEXITCODE -ne 0) { throw "Import failed." }
& $Godot --headless --path . --script res://tests/smoke_test.gd
if ($LASTEXITCODE -ne 0) { throw "Smoke test failed." }
& $Godot --headless --path . --export-release "Web" "build/web/index.html"
if ($LASTEXITCODE -ne 0) { throw "Web export failed. Kiểm tra export templates Godot 4.7." }
Write-Host "Web build ready at build/web/index.html"
