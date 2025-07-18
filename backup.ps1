# Script de backup manuel n8n - PowerShell

# Charger les variables d'environnement
Get-Content .env | ForEach-Object {
    if ($_ -match "^([^#][^=]*?)=(.*)$") {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}

$backupDir = ".\backups"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "n8n_backup_$timestamp.sql"

Write-Host "🔄 Création du backup..." -ForegroundColor Yellow

# Backup de la base de données
docker exec n8n_postgres pg_dump -U $env:POSTGRES_USER -d $env:POSTGRES_DB | Out-File -FilePath "$backupDir\$backupFile" -Encoding UTF8

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backup créé: $backupFile" -ForegroundColor Green
    
    # Compresser le backup (optionnel sur Windows)
    Compress-Archive -Path "$backupDir\$backupFile" -DestinationPath "$backupDir\$backupFile.zip"
    Remove-Item "$backupDir\$backupFile"
    Write-Host "✅ Backup compressé: $backupFile.zip" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de la création du backup" -ForegroundColor Red
    exit 1
}
