# Script de monitoring n8n - PowerShell

Write-Host "📊 État des services n8n" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

# État des conteneurs
Write-Host "🐳 État des conteneurs:" -ForegroundColor Yellow
docker-compose ps

Write-Host ""
Write-Host "💾 Utilisation des volumes:" -ForegroundColor Yellow
if (Test-Path "volumes\n8n_data") {
    $n8nSize = (Get-ChildItem "volumes\n8n_data" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "n8n_data: $([math]::Round($n8nSize, 2)) MB"
}
if (Test-Path "volumes\postgres_data") {
    $pgSize = (Get-ChildItem "volumes\postgres_data" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "postgres_data: $([math]::Round($pgSize, 2)) MB"
}
if (Test-Path "backups") {
    $backupSize = (Get-ChildItem "backups" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "backups: $([math]::Round($backupSize, 2)) MB"
}

Write-Host ""
Write-Host "🔍 Logs récents (dernières 5 lignes):" -ForegroundColor Yellow
Write-Host "--- n8n ---" -ForegroundColor White
docker-compose logs --tail=5 n8n

Write-Host ""
Write-Host "--- PostgreSQL ---" -ForegroundColor White
docker-compose logs --tail=5 postgres

Write-Host ""
Write-Host "🌐 Services accessibles:" -ForegroundColor Yellow
# Charger le port depuis .env
$port = "2445"
if (Test-Path ".env") {
    $envContent = Get-Content ".env"
    $portLine = $envContent | Where-Object { $_ -match "^N8N_PORT=(.*)$" }
    if ($portLine) {
        $port = $matches[1]
    }
}
Write-Host "n8n Interface: http://localhost:$port" -ForegroundColor Green
