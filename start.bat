@echo off
REM =============================================================================
REM 🚀 SCRIPT DE DÉMARRAGE RAPIDE N8N PRODUCTION
REM =============================================================================
echo.
echo ================================
echo 🚀 N8N PRODUCTION STARTUP
echo ================================
echo.

REM Vérifier que Docker fonctionne
echo ⏳ Vérification de Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERREUR: Docker n'est pas installé ou ne fonctionne pas
    echo    Installez Docker Desktop puis relancez ce script
    pause
    exit /b 1
)
echo ✅ Docker OK

REM Vérifier que docker-compose fonctionne
echo ⏳ Vérification de Docker Compose...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERREUR: Docker Compose n'est pas disponible
    pause
    exit /b 1
)
echo ✅ Docker Compose OK

REM Vérifier l'existence du fichier .env
if not exist .env (
    echo.
    echo ⚠️  ATTENTION: Fichier .env manquant !
    echo    Copiez .env.example vers .env et configurez vos paramètres
    echo.
    pause
    exit /b 1
)
echo ✅ Fichier .env trouvé

echo.
echo 🏗️  Démarrage des services...
echo.

REM Démarrer PostgreSQL en premier
echo ⏳ Démarrage de PostgreSQL...
docker-compose up -d postgres
timeout /t 10 /nobreak >nul

REM Démarrer Redis
echo ⏳ Démarrage de Redis...
docker-compose up -d redis
timeout /t 5 /nobreak >nul

REM Démarrer n8n principal
echo ⏳ Démarrage de n8n...
docker-compose up -d n8n
timeout /t 15 /nobreak >nul

REM Démarrer le worker
echo ⏳ Démarrage du Worker n8n...
docker-compose up -d n8n-worker
timeout /t 10 /nobreak >nul

REM Démarrer Cloudflare Tunnel
echo ⏳ Démarrage de Cloudflare Tunnel...
docker-compose up -d cloudflared

echo.
echo ✅ Tous les services sont démarrés !
echo.
echo 🌐 Accès à n8n:
echo    - Local:    http://localhost:5678
echo    - Internet: https://votre-domaine.com
echo.
echo 📊 Commandes utiles:
echo    docker-compose ps           (voir l'état)
echo    docker-compose logs -f      (voir les logs)
echo    docker-compose down         (arrêter tout)
echo.

REM Afficher l'état des services
echo 📋 État des services:
docker-compose ps

echo.
echo 🎉 N8N Production est prêt !
pause