# ===========================================
# SCRIPT DE DÉPLOIEMENT N8N OPTIMISÉ - WINDOWS
# ===========================================

# Activer l'arrêt sur erreur
$ErrorActionPreference = "Stop"

Write-Host "🚀 Déploiement de n8n optimisé pour Windows" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Fonctions pour les messages colorés
function Write-Info {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn {
    param($Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Vérifier si Docker est installé
try {
    docker --version | Out-Null
    Write-Info "Docker trouvé"
} catch {
    Write-Error "Docker n'est pas installé ou n'est pas dans le PATH"
    Write-Host "Téléchargez Docker Desktop depuis: https://www.docker.com/products/docker-desktop/"
    exit 1
}

# Vérifier si Docker Compose est installé
try {
    docker-compose --version | Out-Null
    Write-Info "Docker Compose trouvé"
} catch {
    Write-Error "Docker Compose n'est pas installé"
    Write-Host "Installez Docker Desktop qui inclut Docker Compose"
    exit 1
}

# Créer les répertoires nécessaires
Write-Info "Création des répertoires..."
$directories = @(
    "volumes\n8n_data",
    "volumes\postgres_data", 
    "local_files",
    "backups",
    "postgres\init"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Info "Créé: $dir"
    }
}

# Créer le fichier .gitignore
Write-Info "Création du fichier .gitignore..."
$gitignoreContent = @"
# Fichiers sensibles
.env
.env.local
.env.production

# Données
volumes/
backups/
local_files/

# Logs
*.log
logs/

# Certificats
*.pem
*.key
*.crt

# Temporaires
.DS_Store
Thumbs.db
desktop.ini
"@

$gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8

# Fonction pour générer un mot de passe aléatoire
function Generate-Password {
    param($Length = 32)
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    $password = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $password += $chars[(Get-Random -Maximum $chars.Length)]
    }
    return $password
}

# Vérifier le fichier .env
if (!(Test-Path ".env")) {
    Write-Warn "Fichier .env non trouvé. Création d'un fichier d'exemple..."
    
    # Générer des mots de passe sécurisés
    $postgresPassword = Generate-Password
    $n8nPassword = Generate-Password
    $encryptionKey = Generate-Password
    
    $envContent = @"
# Configuration générée automatiquement - MODIFIEZ LES VALEURS !

N8N_PORT=2445
N8N_EDITOR_BASE_URL=http://localhost:2445
WEBHOOK_URL=http://localhost:2445

POSTGRES_DB=n8n
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=$postgresPassword

N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$n8nPassword

N8N_ENCRYPTION_KEY=$encryptionKey

TIMEZONE=Europe/Paris
NODE_ENV=production
N8N_LOG_LEVEL=info
"@
    
    $envContent | Out-File -FilePath ".env" -Encoding UTF8
    Write-Warn "Fichier .env créé avec des valeurs générées. MODIFIEZ-LE avant le déploiement !"
}

# Créer un script d'initialisation PostgreSQL
Write-Info "Création du script d'initialisation PostgreSQL..."
$initSqlContent = @"
-- Configuration optimisée pour n8n
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Index pour optimiser les performances
-- Ces index seront créés automatiquement par n8n au premier démarrage
"@

$initSqlContent | Out-File -FilePath "postgres\init\init.sql" -Encoding UTF8

# Créer un script de backup PowerShell
Write-Info "Création du script de backup..."
$backupScript = @'
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
'@

$backupScript | Out-File -FilePath "backup.ps1" -Encoding UTF8

# Créer un script de monitoring PowerShell
Write-Info "Création du script de monitoring..."
$monitorScript = @'
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
'@

$monitorScript | Out-File -FilePath "monitor.ps1" -Encoding UTF8

# Instructions finales
Write-Info "Configuration terminée !"
Write-Host ""
Write-Host "📋 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Modifiez le fichier .env avec vos vraies valeurs"
Write-Host "2. Configurez vos URLs ngrok ou domaine"
Write-Host "3. Lancez avec: docker-compose up -d"
Write-Host ""
Write-Host "🔧 Scripts PowerShell disponibles:" -ForegroundColor Cyan
Write-Host "  .\backup.ps1     - Créer un backup"
Write-Host "  .\monitor.ps1    - Voir l'état des services"
Write-Host ""
Write-Host "🌐 Une fois lancé, n8n sera accessible sur: http://localhost:2445" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  Note Windows: Assurez-vous que Docker Desktop est démarré" -ForegroundColor Yellow