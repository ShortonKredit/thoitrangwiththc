$ErrorActionPreference = "Stop"
$Remote = "https://github.com/ShortonKredit/thoitrangwiththc.git"

if (-not (Test-Path ".git")) { git init }
git add .
git commit -m "Initial Godot fashion game foundation"
git branch -M main
$existing = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
    git remote add origin $Remote
} elseif ($existing -ne $Remote) {
    git remote set-url origin $Remote
}
git push -u origin main
