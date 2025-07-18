# ===========================================
# SCRIPT DE CONFIGURATION N8N OPTIMISÉ
# Windows 11 - Documentation officielle
# ===========================================

$ErrorActionPreference = "Stop"

Write-Host "🚀 Configuration n8n + PostgreSQL optimisée" -ForegroundColor Green
Write-Host "Basée sur la documentation officielle n8n" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Vérification Docker
try {
    docker --version | Out-Null
    Write-Host "✅ Docker détecté" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker non trouvé. Installez Docker Desktop." -ForegroundColor Red
    exit 1
}

# Vérification Docker Compose
try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose détecté" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose non trouvé." -ForegroundColor Red
    exit 1
}

# Création des dossiers
Write-Host "`n📁 Création de la structure..." -ForegroundColor Yellow
$folders = @("local_files", "backups", "postgres-init", "scripts")
foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "  ✅ Créé: $folder" -ForegroundColor Green
    }
}

# Fonction pour générer des mots de passe sécurisés
function Generate-SecurePassword {
    param($Length = 32)
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
    $password = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $password += $chars[(Get-Random -Maximum $chars.Length)]
    }
    return $password
}

# Vérification du fichier .env
if (!(Test-Path ".env")) {
    Write-Host "`n🔐 Génération du fichier .env sécurisé..." -ForegroundColor Yellow
    
    $encryptionKey = Generate-SecurePassword -Length 32
    $postgresPassword = Generate-SecurePassword -Length 24
    
    $envContent = @"
# Configuration n8n + PostgreSQL optimisée
# Générée automatiquement le $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# === VARIABLES OBLIGATOIRES ===
N8N_EDITOR_BASE_URL=https://peaceful-buck-separately.ngrok-free.app
WEBHOOK_URL=https://peaceful-buck-separately.ngrok-free.app
N8N_PORT=2445
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=445012
TIMEZONE=Europe/Paris

# === SÉCURITÉ (générée automatiquement) ===
N8N_ENCRYPTION_KEY=$encryptionKey

# === BASE DE DONNÉES ===
POSTGRES_DB=n8n
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=$postgresPassword

# === BACKUP ===
BACKUP_SCHEDULE=0 2 * * *
BACKUP_RETENTION_DAYS=7

# ⚠️ IMPORTANT: Modifiez les URLs ngrok si nécessaire !
"@
    
    $envContent | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "  ✅ Fichier .env créé avec mots de passe sécurisés" -ForegroundColor Green
} else {
    Write-Host "`n✅ Fichier .env existant détecté" -ForegroundColor Green
}

# Création du script d'initialisation PostgreSQL
Write-Host "`n🐘 Configuration PostgreSQL..." -ForegroundColor Yellow
$initScript = @"
-- Script d'initialisation PostgreSQL pour n8n
-- Optimisé selon la documentation officielle

-- Extensions recommandées pour n8n
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Configuration des permissions
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n_user;
GRANT ALL ON SCHEMA public TO n8n_user;

-- Configuration pour de meilleures performances
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
ALTER SYSTEM SET track_activity_query_size = 2048;
ALTER SYSTEM SET pg_stat_statements.track = 'all';

-- Redémarrage requis pour ces paramètres
"@

$initScript | Out-File -FilePath "postgres-init/01-init.sql" -Encoding UTF8
Write-Host "  ✅ Script d'initialisation PostgreSQL créé" -ForegroundColor Green


$backupScript | Out-File -FilePath "scripts/backup.sh" -Encoding UTF8
Write-Host "  ✅ Script de backup créé" -ForegroundColor Green

# Création du script de monitoring
$monitorScript = @'
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
'@

$monitorScript | Out-File -FilePath "monitor.ps1" -Encoding UTF8
Write-Host "  ✅ Script de monitoring créé" -ForegroundColor Green

# Résumé final
Write-Host "`n" + "="*50 -ForegroundColor Green
Write-Host "✅ CONFIGURATION TERMINÉE !" -ForegroundColor Green -BackgroundColor Black
Write-Host "="*50 -ForegroundColor Green

Write-Host "`n📋 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Vérifiez le fichier .env (URLs ngrok)" -ForegroundColor White
Write-Host "2. Lancez: docker-compose up -d" -ForegroundColor White
Write-Host "3. Attendez 1-2 minutes le démarrage" -ForegroundColor White
Write-Host "4. Accédez à http://localhost:2445" -ForegroundColor White

Write-Host "`n🔧 Scripts disponibles:" -ForegroundColor Cyan
Write-Host "  .\monitor.ps1        - Surveillance des services" -ForegroundColor White
Write-Host "  docker-compose logs  - Voir tous les logs" -ForegroundColor White
Write-Host "  docker-compose down  - Arrêter les services" -ForegroundColor White

Write-Host "`n🔐 Identifiants par défaut:" -ForegroundColor Yellow
Write-Host "  Utilisateur: admin" -ForegroundColor White
Write-Host "  Mot de passe: 445012" -ForegroundColor White

Write-Host "`n⚡ Configuration optimisée selon:" -ForegroundColor Blue
Write-Host "  - Documentation officielle n8n" -ForegroundColor White
Write-Host "  - Bonnes pratiques PostgreSQL" -ForegroundColor White
Write-Host "  - Sécurité pour environnement Windows" -ForegroundColor White

Write-Host "`n🚀 Prêt pour le déploiement !" -ForegroundColor Green