#Requires -Version 7.0

<#
.SYNOPSIS
🚀 N8N Production Startup Script - PowerShell 7 Edition

.DESCRIPTION
Script moderne pour démarrer votre stack n8n avec Docker Compose.
Optimisé pour PowerShell 7 avec gestion d'erreurs avancée et interface fun.

.NOTES
Auteur: Yanis Harrat
Version: 2.0
Requires: PowerShell 7+ et Docker Desktop
#>

# ============================================================================
# 🎨 CONFIGURATION DES COULEURS ET STYLES
# ============================================================================

$Colors = @{
    Success = [System.ConsoleColor]::Green
    Warning = [System.ConsoleColor]::Yellow
    Error   = [System.ConsoleColor]::Red
    Info    = [System.ConsoleColor]::Cyan
    Header  = [System.ConsoleColor]::Magenta
    Accent  = [System.ConsoleColor]::Blue
}

function Write-ColoredText {
    param(
        [string]$Text,
        [System.ConsoleColor]$Color = [System.ConsoleColor]::White,
        [switch]$NoNewLine
    )
    $currentColor = [Console]::ForegroundColor
    [Console]::ForegroundColor = $Color
    if ($NoNewLine) {
        Write-Host $Text -NoNewline
    } else {
        Write-Host $Text
    }
    [Console]::ForegroundColor = $currentColor
}

function Show-Banner {
    Clear-Host
    Write-ColoredText "═══════════════════════════════════════════════════" $Colors.Header
    Write-ColoredText "🚀 N8N PRODUCTION STARTUP SCRIPT v2.0" $Colors.Header
    Write-ColoredText "   PowerShell 7 Edition - Now with 100% more fun! 🎉" $Colors.Accent
    Write-ColoredText "═══════════════════════════════════════════════════" $Colors.Header
    Write-Host ""
}

function Show-Step {
    param(
        [string]$StepName,
        [string]$Description = "",
        [string]$Emoji = "⏳"
    )
    Write-ColoredText "$Emoji " $Colors.Info -NoNewLine
    Write-ColoredText "$StepName" $Colors.Info -NoNewLine
    if ($Description) {
        Write-ColoredText " - $Description" $Colors.Accent
    } else {
        Write-Host ""
    }
}

function Show-Success {
    param([string]$Message)
    Write-ColoredText "✅ $Message" $Colors.Success
}

function Show-Warning {
    param([string]$Message)
    Write-ColoredText "⚠️  $Message" $Colors.Warning
}

function Show-Error {
    param([string]$Message)
    Write-ColoredText "❌ $Message" $Colors.Error
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Wait-WithAnimation {
    param(
        [int]$Seconds,
        [string]$Message = "En attente"
    )
    $spinner = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    $counter = 0
    
    for ($i = 0; $i -lt ($Seconds * 4); $i++) {
        Write-ColoredText "`r$($spinner[$counter % $spinner.Length]) $Message..." $Colors.Info -NoNewLine
        Start-Sleep -Milliseconds 250
        $counter++
    }
    Write-Host "`r" -NoNewline
}

# ============================================================================
# 🔍 VÉRIFICATIONS PRÉLIMINAIRES
# ============================================================================

function Test-Prerequisites {
    Show-Step "Vérification des prérequis" "Docker, Docker Compose, fichiers..." "🔍"
    
    # Vérifier PowerShell 7
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Show-Warning "PowerShell 7+ recommandé pour une expérience optimale"
        Show-Warning "Version actuelle: $($PSVersionTable.PSVersion)"
    } else {
        Show-Success "PowerShell $($PSVersionTable.PSVersion) détecté"
    }
    
    # Vérifier Docker
    if (-not (Test-CommandExists "docker")) {
        Show-Error "Docker n'est pas installé ou pas dans le PATH"
        Show-Error "Installez Docker Desktop: https://www.docker.com/products/docker-desktop"
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }
    Show-Success "Docker détecté"
    
    # Vérifier Docker Compose
    if (-not (Test-CommandExists "docker-compose")) {
        Show-Error "Docker Compose n'est pas disponible"
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }
    Show-Success "Docker Compose détecté"
    
    # Vérifier que Docker fonctionne
    try {
        $dockerVersion = docker --version 2>$null
        Show-Success "Docker fonctionne: $($dockerVersion -replace 'Docker version ', '')"
    } catch {
        Show-Error "Docker ne répond pas. Est-il démarré?"
        Show-Warning "Démarrez Docker Desktop et relancez ce script"
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }
    
    # Vérifier le fichier .env
    if (-not (Test-Path ".env")) {
        Show-Error "Fichier .env manquant!"
        Show-Warning "Copiez .env.example vers .env et configurez vos paramètres:"
        Write-ColoredText "   Copy-Item '.env.example' '.env'" $Colors.Accent
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }
    Show-Success "Fichier .env trouvé"
    
    # Vérifier docker-compose.yml
    if (-not (Test-Path "docker-compose.yml")) {
        Show-Error "Fichier docker-compose.yml manquant!"
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }
    Show-Success "Configuration Docker Compose trouvée"
    
    Write-Host ""
}

# ============================================================================
# 🚀 DÉMARRAGE DES SERVICES
# ============================================================================

function Start-Service {
    param(
        [string]$ServiceName,
        [string]$Description,
        [int]$WaitTime = 5,
        [string]$Emoji = "🚀"
    )
    
    Show-Step $Description $ServiceName $Emoji
    
    try {
        $result = docker-compose up -d $ServiceName 2>&1
        if ($LASTEXITCODE -eq 0) {
            Wait-WithAnimation -Seconds $WaitTime -Message "Démarrage de $ServiceName"
            Show-Success "$ServiceName démarré avec succès"
        } else {
            Show-Error "Erreur lors du démarrage de $ServiceName"
            Write-ColoredText $result $Colors.Error
            return $false
        }
    } catch {
        Show-Error "Exception lors du démarrage de $ServiceName : $_"
        return $false
    }
    return $true
}

function Start-AllServices {
    Write-Host ""
    Write-ColoredText "🏗️  Démarrage de la stack n8n..." $Colors.Header
    Write-Host ""
    
    # Démarrer dans l'ordre optimal
    $services = @(
        @{ Name = "postgres"; Description = "Démarrage de PostgreSQL"; Wait = 15; Emoji = "🗄️" }
        @{ Name = "redis"; Description = "Démarrage de Redis"; Wait = 8; Emoji = "🚀" }
        @{ Name = "n8n"; Description = "Démarrage de n8n Principal"; Wait = 20; Emoji = "🎯" }
        @{ Name = "n8n-worker"; Description = "Démarrage du Worker n8n"; Wait = 12; Emoji = "⚡" }
        @{ Name = "cloudflared"; Description = "Démarrage de Cloudflare Tunnel"; Wait = 10; Emoji = "🌐" }
    )
    
    foreach ($service in $services) {
        if (-not (Start-Service -ServiceName $service.Name -Description $service.Description -WaitTime $service.Wait -Emoji $service.Emoji)) {
            Show-Error "Échec du démarrage. Arrêt du processus."
            return $false
        }
        Write-Host ""
    }
    return $true
}

# ============================================================================
# 📊 VÉRIFICATION DE L'ÉTAT
# ============================================================================

function Show-ServiceStatus {
    Write-Host ""
    Write-ColoredText "📊 État des services:" $Colors.Header
    Write-Host ""
    
    try {
        $status = docker-compose ps --format table
        Write-ColoredText $status $Colors.Info
    } catch {
        Show-Warning "Impossible d'obtenir l'état des services"
    }
}

function Show-AccessInfo {
    Write-Host ""
    Write-ColoredText "🌐 Informations d'accès:" $Colors.Header
    Write-Host ""
    
    # Lire le domaine depuis .env si possible
    $domain = "votre-domaine.com"
    if (Test-Path ".env") {
        try {
            $envContent = Get-Content ".env" | Where-Object { $_ -match "^CLOUDFLARE_DOMAIN=" }
            if ($envContent) {
                $domain = ($envContent -split "=")[1]
            }
        } catch {
            # Ignore si on ne peut pas lire
        }
    }
    
    Write-ColoredText "   💻 Local:    " $Colors.Info -NoNewLine
    Write-ColoredText "http://localhost:5678" $Colors.Success
    
    Write-ColoredText "   🌍 Internet: " $Colors.Info -NoNewLine
    Write-ColoredText "https://$domain" $Colors.Success
    
    Write-ColoredText "   👤 Login:    " $Colors.Info -NoNewLine
    Write-ColoredText "admin / (votre mot de passe .env)" $Colors.Accent
    Write-Host ""
}

function Show-UsefulCommands {
    Write-ColoredText "📚 Commandes utiles:" $Colors.Header
    Write-Host ""
    
    $commands = @(
        @{ Cmd = "docker-compose ps"; Desc = "Voir l'état des services" }
        @{ Cmd = "docker-compose logs -f"; Desc = "Voir les logs en temps réel" }
        @{ Cmd = "docker-compose down"; Desc = "Arrêter tous les services" }
        @{ Cmd = "docker-compose restart n8n"; Desc = "Redémarrer n8n uniquement" }
        @{ Cmd = "docker stats"; Desc = "Voir l'utilisation des ressources" }
    )
    
    foreach ($cmd in $commands) {
        Write-ColoredText "   • " $Colors.Accent -NoNewLine
        Write-ColoredText $cmd.Cmd $Colors.Info -NoNewLine
        Write-ColoredText " - $($cmd.Desc)" $Colors.Accent
    }
    Write-Host ""
}

function Show-FinalMessage {
    Write-Host ""
    Write-ColoredText "═══════════════════════════════════════════════════" $Colors.Success
    Write-ColoredText "🎉 N8N EST PRÊT À L'ACTION!" $Colors.Success
    Write-ColoredText "   Votre stack fonctionne avec 6 services connectés" $Colors.Accent
    Write-ColoredText "═══════════════════════════════════════════════════" $Colors.Success
    Write-Host ""
}

# ============================================================================
# 🚀 SCRIPT PRINCIPAL
# ============================================================================

function Main {
    Show-Banner
    
    # Vérifications
    Test-Prerequisites
    
    # Demander confirmation
    Write-ColoredText "🚀 Prêt à démarrer votre stack n8n?" $Colors.Header
    Write-ColoredText "   (6 services: PostgreSQL, Redis, n8n, Worker, Cloudflare Tunnel)" $Colors.Accent
    Write-Host ""
    
    $response = Read-Host "Continuer? [Y/n]"
    if ($response -match '^n|N|non|Non') {
        Write-ColoredText "👋 À bientôt!" $Colors.Info
        exit 0
    }
    
    # Démarrer les services
    if (Start-AllServices) {
        Show-ServiceStatus
        Show-AccessInfo
        Show-UsefulCommands
        Show-FinalMessage
        
        # Offrir d'ouvrir le navigateur
        $openBrowser = Read-Host "Ouvrir n8n dans le navigateur? [Y/n]"
        if ($openBrowser -notmatch '^n|N|non|Non') {
            try {
                Start-Process "http://localhost:5678"
                Show-Success "Navigateur ouvert sur http://localhost:5678"
            } catch {
                Show-Warning "Impossible d'ouvrir le navigateur automatiquement"
            }
        }
    } else {
        Show-Error "Échec du démarrage de certains services"
        Write-Host ""
        Write-ColoredText "🔍 Pour diagnostiquer:" $Colors.Info
        Write-ColoredText "   docker-compose logs" $Colors.Accent
        Write-Host ""
    }
    
    Read-Host "Appuyez sur Entrée pour quitter"
}

# Gestion des erreurs globales
trap {
    Write-Host ""
    Show-Error "Une erreur inattendue s'est produite: $_"
    Show-Warning "Pour obtenir de l'aide, consultez le README.md"
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

# Lancement du script principal
Main