$ErrorActionPreference = "Stop"

function Resolve-GodotCommand {
    $commands = @("godot", "godot4")
    foreach ($command in $commands) {
        if (Get-Command $command -ErrorAction SilentlyContinue) {
            return $command
        }
    }
    throw "Godot command not found. Add Godot 4.7 to PATH."
}

function Invoke-GodotChecked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GodotCommand,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$StepName
    )

    Write-Host "`n== $StepName =="
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $output = & $GodotCommand @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
    $output | ForEach-Object { Write-Host $_ }
    $text = ($output | Out-String)

    if ($exitCode -ne 0) {
        throw "$StepName failed with exit code $exitCode."
    }

    # Godot can return exit code 0 even when a project script has parse/load errors.
    # Treat engine/script errors as a failed check instead of printing a false pass.
    $fatalPatterns = @(
        "SCRIPT ERROR:",
        "Parse Error:",
        "Failed to load script",
        "Cannot infer the type",
        "ERROR: Failed to load"
    )
    foreach ($pattern in $fatalPatterns) {
        if ($text -match [regex]::Escape($pattern)) {
            throw "$StepName reported a Godot script/load error: $pattern"
        }
    }
}

python tools/validate_catalog.py
if ($LASTEXITCODE -ne 0) { throw "Catalog validation failed." }

$Godot = Resolve-GodotCommand
Write-Host "Using: $Godot"
& $Godot --version
if ($LASTEXITCODE -ne 0) { throw "Could not read Godot version." }

Invoke-GodotChecked -GodotCommand $Godot -Arguments @("--headless", "--path", ".", "--import") -StepName "Godot import and script parse"
Invoke-GodotChecked -GodotCommand $Godot -Arguments @("--headless", "--path", ".", "--quit-after", "2") -StepName "Main scene startup smoke check"
Invoke-GodotChecked -GodotCommand $Godot -Arguments @("--headless", "--path", ".", "--script", "res://tests/smoke_test.gd") -StepName "Logic smoke tests"

Write-Host "`nProject checks passed."
