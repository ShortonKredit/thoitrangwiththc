$ErrorActionPreference = "Stop"
foreach ($command in @("godot", "godot4")) {
    if (Get-Command $command -ErrorAction SilentlyContinue) {
        & $command --path .
        exit $LASTEXITCODE
    }
}
throw "Không tìm thấy Godot 4.7 trong PATH."
