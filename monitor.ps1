# Script de monitoring n8n - PowerShell
# Surveillance des services et performances

Write-Host "📊 Monitoring n8n + PostgreSQL" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# État des conteneurs
Write-Host "`n🐳 État des conteneurs:" -ForegroundColor Yellow
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Utilisation des ressources
Write-Host "`n💻 Utilisation des ressources:" -ForegroundColor Yellow
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

# Santé des services
Write-Host "`n🏥 Santé des services:" -ForegroundColor Yellow
Write-Host "n8n:" -NoNewline
$n8nHealth = docker-compose exec -T n8n wget --spider -q http://localhost:5678/healthz 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅ OK" -ForegroundColor Green
} else {
    Write-Host " ❌ ERROR" -ForegroundColor Red
}

Write-Host "PostgreSQL:" -NoNewline
$pgHealth = docker-compose exec -T postgres pg_isready -q 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅ OK" -ForegroundColor Green
} else {
    Write-Host " ❌ ERROR" -ForegroundColor Red
}

# Logs récents
Write-Host "`n📋 Logs récents (5 dernières lignes):" -ForegroundColor Yellow
Write-Host "--- n8n ---" -ForegroundColor White
docker-compose logs --tail=5 n8n

Write-Host "`n--- PostgreSQL ---" -ForegroundColor White
docker-compose logs --tail=5 postgres

# Informations d'accès
Write-Host "`n🌐 Accès aux services:" -ForegroundColor Green
Get-Content .env | Where-Object { $_ -match "^N8N_PORT=" } | ForEach-Object {
    $port = ($_ -split "=")[1]
    Write-Host "Interface n8n: http://localhost:$port" -ForegroundColor Green
}

Get-Content .env | Where-Object { $_ -match "^N8N_EDITOR_BASE_URL=" } | ForEach-Object {
    $url = ($_ -split "=")[1]
    Write-Host "URL externe: $url" -ForegroundColor Green
}
