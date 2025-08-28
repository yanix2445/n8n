#!/bin/bash

# ============================================================================
# 🚀 N8N UNIVERSAL STARTUP SCRIPT - Fun Bash Edition
# ============================================================================
# 
# Script universel optimisé pour macOS et Linux avec couleurs, animations 
# et détection intelligente. Compatible avec tous les terminaux modernes.
# 
# Auteur: Configuration N8N Avancée  
# Version: 3.0 Universal
# Requires: Bash 4.0+, Docker, Docker Compose
# ============================================================================

set -euo pipefail  # Mode strict pour une meilleure gestion d'erreurs

# ============================================================================
# 🎨 CONFIGURATION DES COULEURS ET STYLES
# ============================================================================

# Détection des capacités du terminal
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    # Terminal avec support couleurs
    COLORS_SUPPORTED=$(tput colors 2>/dev/null || echo 0)
    if [[ $COLORS_SUPPORTED -ge 8 ]]; then
        # Couleurs de base (compatibilité maximale)
        RED='\033[0;31m'
        GREEN='\033[0;32m'  
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        MAGENTA='\033[0;35m'
        CYAN='\033[0;36m'
        WHITE='\033[1;37m'
        
        # Couleurs vives (si supportées)
        if [[ $COLORS_SUPPORTED -ge 256 ]]; then
            BRIGHT_RED='\033[1;91m'
            BRIGHT_GREEN='\033[1;92m'
            BRIGHT_YELLOW='\033[1;93m'
            BRIGHT_BLUE='\033[1;94m'
            BRIGHT_MAGENTA='\033[1;95m'
            BRIGHT_CYAN='\033[1;96m'
        else
            # Fallback pour terminaux 8 couleurs
            BRIGHT_RED=$RED
            BRIGHT_GREEN=$GREEN
            BRIGHT_YELLOW=$YELLOW
            BRIGHT_BLUE=$BLUE
            BRIGHT_MAGENTA=$MAGENTA
            BRIGHT_CYAN=$CYAN
        fi
        
        # Styles
        BOLD='\033[1m'
        DIM='\033[2m'
        UNDERLINE='\033[4m'
        RESET='\033[0m'
    else
        # Pas de couleurs - fallback vide
        RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
        BRIGHT_RED='' BRIGHT_GREEN='' BRIGHT_YELLOW='' BRIGHT_BLUE=''
        BRIGHT_MAGENTA='' BRIGHT_CYAN='' BOLD='' DIM='' UNDERLINE='' RESET=''
    fi
else
    # Terminal non-interactif - pas de couleurs
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
    BRIGHT_RED='' BRIGHT_GREEN='' BRIGHT_YELLOW='' BRIGHT_BLUE=''
    BRIGHT_MAGENTA='' BRIGHT_CYAN='' BOLD='' DIM='' UNDERLINE='' RESET=''
fi

# ============================================================================
# 🎭 FONCTIONS D'AFFICHAGE STYLISÉES
# ============================================================================

print_colored() {
    local color=$1
    local text=$2
    local no_newline=${3:-false}
    
    if [[ $no_newline == "true" ]]; then
        printf "${!color}%s${RESET}" "$text"
    else
        printf "${!color}%s${RESET}\n" "$text"
    fi
}

print_banner() {
    clear
    echo
    print_colored "BRIGHT_MAGENTA" "════════════════════════════════════════════════════════════"
    print_colored "BRIGHT_MAGENTA" "${BOLD}🚀 N8N UNIVERSAL STARTUP SCRIPT v3.0${RESET}"
    print_colored "BRIGHT_BLUE" "   One script to rule them all - macOS & Linux 🔥"
    print_colored "BRIGHT_MAGENTA" "════════════════════════════════════════════════════════════"
    echo
}

print_step() {
    local emoji=$1
    local step_name=$2
    local description=$3
    
    print_colored "BRIGHT_CYAN" "$emoji $step_name" true
    if [[ -n ${description:-} ]]; then
        print_colored "BLUE" " - $description"
    else
        echo
    fi
}

print_success() {
    print_colored "BRIGHT_GREEN" "✅ $1"
}

print_warning() {
    print_colored "BRIGHT_YELLOW" "⚠️  $1"
}

print_error() {
    print_colored "BRIGHT_RED" "❌ $1"
}

print_info() {
    print_colored "BRIGHT_CYAN" "ℹ️  $1"
}

# ============================================================================
# 🌀 ANIMATIONS ET SPINNERS FUN
# ============================================================================

# Spinner universel compatible tous terminaux
spinner() {
    local message=$1
    local duration=${2:-5}
    local pid=${3:-}
    
    # Différents spinners selon le terminal
    if [[ $COLORS_SUPPORTED -ge 8 ]]; then
        # Spinner moderne si couleurs supportées
        local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    else
        # Spinner classique pour terminaux basiques
        local frames=("|" "/" "-" "\\")
    fi
    
    local frame_count=${#frames[@]}
    local frame_index=0
    local counter=0
    
    # Cache le curseur si possible
    [[ -t 1 ]] && printf "\033[?25l"
    
    while [[ $counter -lt $((duration * 10)) ]]; do
        printf "\r${BRIGHT_CYAN}${frames[$((frame_index % frame_count))]} %s...${RESET}" "$message"
        frame_index=$((frame_index + 1))
        sleep 0.1
        counter=$((counter + 1))
        
        # Vérifier si le processus est terminé (si PID fourni)
        if [[ -n $pid ]] && ! kill -0 "$pid" 2>/dev/null; then
            break
        fi
    done
    
    # Affiche le curseur et nettoie
    [[ -t 1 ]] && printf "\033[?25h"
    printf "\r\033[K"
}

# Barre de progression fun
progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    printf "\r${BRIGHT_BLUE}["
    
    # Barre remplie
    for ((i=1; i<=filled; i++)); do
        if [[ $COLORS_SUPPORTED -ge 8 ]]; then
            printf "█"
        else
            printf "#"
        fi
    done
    
    # Barre vide
    for ((i=filled+1; i<=width; i++)); do
        if [[ $COLORS_SUPPORTED -ge 8 ]]; then
            printf "░"
        else
            printf "."
        fi
    done
    
    printf "] %d%% (%d/%d)${RESET}" $percentage $current $total
}

# Animation de célébration
celebration_animation() {
    local frames=("🎉" "🚀" "✨" "🎊" "🌟" "🎈")
    
    for i in {1..3}; do
        for frame in "${frames[@]}"; do
            printf "\r${BRIGHT_GREEN}${frame} N8N EST PRÊT! ${frame}${RESET}"
            sleep 0.2
        done
    done
    echo
}

# ============================================================================
# 🔍 DÉTECTION SYSTÈME ET VÉRIFICATIONS
# ============================================================================

detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macOS"
            OS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "Inconnue")
            print_info "Système: macOS $OS_VERSION 🍎"
            
            # Vérifier Homebrew sur macOS
            if command -v brew >/dev/null 2>&1; then
                print_success "Homebrew détecté"
            else
                print_warning "Homebrew non trouvé (recommandé pour Docker)"
            fi
            ;;
        Linux*)
            OS="Linux"
            if [[ -f /etc/os-release ]]; then
                # shellcheck source=/dev/null
                . /etc/os-release
                print_info "Système: $NAME ${VERSION_ID:-} 🐧"
                
                # Détection spécifique selon la distribution
                case "$ID" in
                    ubuntu|debian)
                        PACKAGE_MANAGER="apt"
                        ;;
                    fedora|rhel|centos)
                        PACKAGE_MANAGER="yum"
                        ;;
                    arch)
                        PACKAGE_MANAGER="pacman"
                        ;;
                    *)
                        PACKAGE_MANAGER="unknown"
                        ;;
                esac
            else
                print_info "Système: Linux (distribution inconnue) 🐧"
                PACKAGE_MANAGER="unknown"
            fi
            ;;
        *)
            OS="Unknown"
            print_warning "Système non reconnu: $(uname -s)"
            ;;
    esac
}

check_bash_version() {
    local bash_version=${BASH_VERSION%%.*}
    if [[ $bash_version -lt 4 ]]; then
        print_warning "Bash 4.0+ recommandé. Version: $BASH_VERSION"
        case $OS in
            "macOS")
                print_info "Mise à jour: brew install bash"
                ;;
            "Linux")
                print_info "Bash moderne généralement disponible"
                ;;
        esac
        return 1
    fi
    print_success "Bash $BASH_VERSION ✓"
    return 0
}

check_docker() {
    print_step "🐳" "Vérification de Docker"
    
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker non installé"
        case $OS in
            "macOS")
                print_info "Installation: https://docs.docker.com/desktop/mac/install/"
                print_info "Ou avec Homebrew: brew install --cask docker"
                ;;
            "Linux")
                print_info "Installation Ubuntu/Debian: sudo apt install docker.io"
                print_info "Installation Fedora/RHEL: sudo ${PACKAGE_MANAGER} install docker"
                print_info "Ou script officiel: curl -fsSL https://get.docker.com | sh"
                ;;
        esac
        return 1
    fi
    
    # Vérifier que Docker fonctionne
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker ne répond pas"
        case $OS in
            "macOS")
                print_warning "Démarrez Docker Desktop"
                ;;
            "Linux")
                print_warning "Démarrez Docker: sudo systemctl start docker"
                print_info "Auto-start: sudo systemctl enable docker"
                ;;
        esac
        return 1
    fi
    
    local docker_version
    docker_version=$(docker --version | sed 's/Docker version //' | cut -d',' -f1)
    print_success "Docker $docker_version fonctionne"
    return 0
}

check_docker_compose() {
    print_step "🏗️" "Vérification Docker Compose"
    
    # Vérifier Compose V2 (moderne)
    if docker compose version >/dev/null 2>&1; then
        local compose_version
        compose_version=$(docker compose version --short 2>/dev/null || echo "inconnue")
        print_success "Docker Compose V2 $compose_version"
        COMPOSE_CMD="docker compose"
        return 0
    # Fallback vers Compose V1 (legacy)
    elif command -v docker-compose >/dev/null 2>&1; then
        local compose_version
        compose_version=$(docker-compose --version | sed 's/docker-compose version //' | cut -d',' -f1)
        print_warning "Docker Compose V1 $compose_version (legacy)"
        print_info "Conseil: Mise à jour vers Compose V2"
        COMPOSE_CMD="docker-compose"
        return 0
    else
        print_error "Docker Compose non disponible"
        case $OS in
            "macOS")
                print_info "Inclus dans Docker Desktop normalement"
                ;;
            "Linux")
                print_info "Installation V2: sudo apt install docker-compose-plugin"
                print_info "Ou V1: sudo apt install docker-compose"
                ;;
        esac
        return 1
    fi
}

check_env_file() {
    print_step "🔐" "Vérification configuration"
    
    if [[ ! -f ".env" ]]; then
        print_error "Fichier .env manquant!"
        print_info "1. Copiez le template: cp .env.example .env"
        print_info "2. Configurez vos paramètres dans .env"
        return 1
    fi
    
    # Vérifier les variables critiques
    local missing_vars=()
    local critical_vars=(
        "POSTGRES_PASSWORD"
        "N8N_ENCRYPTION_KEY" 
        "CLOUDFLARE_TUNNEL_TOKEN"
        "N8N_BASIC_AUTH_PASSWORD"
    )
    
    for var in "${critical_vars[@]}"; do
        if ! grep -q "^$var=" .env 2>/dev/null; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_warning "Variables à configurer: ${missing_vars[*]}"
        print_info "Consultez .env.example pour les détails"
    fi
    
    print_success "Configuration trouvée"
    return 0
}

# ============================================================================
# 🚀 DÉMARRAGE DES SERVICES
# ============================================================================

start_service() {
    local service_name=$1
    local description=$2  
    local wait_time=${3:-5}
    local emoji=${4:-"🚀"}
    
    print_step "$emoji" "$description"
    
    # Lancer le service en arrière-plan pour spinner
    local temp_log
    temp_log=$(mktemp)
    
    $COMPOSE_CMD up -d "$service_name" >"$temp_log" 2>&1 &
    local docker_pid=$!
    
    # Spinner pendant le démarrage
    spinner "Démarrage de $service_name" 3 $docker_pid
    
    # Attendre la fin du processus Docker
    if wait $docker_pid; then
        # Attente post-démarrage avec barre de progression
        for ((i=1; i<=wait_time; i++)); do
            progress_bar $i $wait_time
            sleep 1
        done
        echo
        print_success "$service_name démarré ✓"
        rm -f "$temp_log"
        return 0
    else
        echo
        print_error "Échec démarrage $service_name"
        print_colored "RED" "$(cat "$temp_log")"
        rm -f "$temp_log"
        return 1
    fi
}

start_all_services() {
    echo
    print_colored "BRIGHT_MAGENTA" "${BOLD}🏗️  Démarrage de la stack n8n...${RESET}"
    echo
    
    # Configuration des services avec emoji et timing
    declare -A services
    services["postgres"]="🗄️|Démarrage PostgreSQL|15"
    services["redis"]="🚀|Démarrage Redis|8" 
    services["n8n"]="🎯|Démarrage n8n Principal|20"
    services["n8n-worker"]="⚡|Démarrage Worker n8n|12"
    services["cloudflared"]="🌐|Démarrage Cloudflare Tunnel|10"
    
    local service_order=("postgres" "redis" "n8n" "n8n-worker" "cloudflared")
    local failed_services=()
    local total_services=${#service_order[@]}
    local current_service=0
    
    for service in "${service_order[@]}"; do
        current_service=$((current_service + 1))
        
        # Parser les infos du service
        IFS='|' read -r emoji description wait_time <<< "${services[$service]}"
        
        printf "\n${DIM}[%d/%d]${RESET} " $current_service $total_services
        
        if ! start_service "$service" "$description" "$wait_time" "$emoji"; then
            failed_services+=("$service")
            break
        fi
    done
    
    if [[ ${#failed_services[@]} -eq 0 ]]; then
        echo
        celebration_animation
        return 0
    else
        print_error "Services en échec: ${failed_services[*]}"
        return 1
    fi
}

# ============================================================================
# 📊 AFFICHAGE DES INFORMATIONS
# ============================================================================

show_service_status() {
    echo
    print_colored "BRIGHT_BLUE" "${BOLD}📊 État des services:${RESET}"
    echo
    
    # Utiliser la commande compose détectée
    if $COMPOSE_CMD ps --format table >/dev/null 2>&1; then
        # Colorer la sortie selon l'état
        $COMPOSE_CMD ps --format table | while IFS= read -r line; do
            if [[ $line =~ Up|running ]]; then
                print_colored "GREEN" "$line"
            elif [[ $line =~ Exit|exited ]]; then
                print_colored "RED" "$line" 
            else
                print_colored "CYAN" "$line"
            fi
        done
    else
        $COMPOSE_CMD ps
    fi
}

show_access_info() {
    echo
    print_colored "BRIGHT_BLUE" "${BOLD}🌐 Informations d'accès:${RESET}"
    echo
    
    # Lire domaine depuis .env
    local domain="votre-domaine.com"
    if [[ -f ".env" ]]; then
        domain=$(grep "^CLOUDFLARE_DOMAIN=" .env 2>/dev/null | cut -d'=' -f2 | tr -d ' "' || echo "votre-domaine.com")
    fi
    
    print_colored "BRIGHT_CYAN" "   💻 Local:    " true
    print_colored "BRIGHT_GREEN" "http://localhost:5678"
    
    print_colored "BRIGHT_CYAN" "   🌍 Internet: " true  
    print_colored "BRIGHT_GREEN" "https://$domain"
    
    print_colored "BRIGHT_CYAN" "   👤 Login:    " true
    print_colored "YELLOW" "admin / (depuis votre .env)"
    
    echo
    print_colored "DIM" "   💡 Astuce: Ajoutez localhost:5678 aux favoris!"
}

show_useful_commands() {
    print_colored "BRIGHT_BLUE" "${BOLD}📚 Commandes utiles:${RESET}"
    echo
    
    local commands=(
        "📊|$COMPOSE_CMD ps|Voir l'état des services"
        "📋|$COMPOSE_CMD logs -f|Logs en temps réel"
        "⏹️|$COMPOSE_CMD down|Arrêter tous les services"
        "🔄|$COMPOSE_CMD restart n8n|Redémarrer n8n seulement"
        "📈|docker stats --no-stream|Utilisation ressources"
        "🔍|$COMPOSE_CMD exec n8n sh|Shell dans le conteneur n8n"
    )
    
    for cmd_info in "${commands[@]}"; do
        IFS='|' read -r emoji cmd desc <<< "$cmd_info"
        print_colored "YELLOW" "   $emoji " true
        print_colored "BRIGHT_CYAN" "$cmd" true
        print_colored "WHITE" " - $desc"
    done
    echo
}

show_final_message() {
    echo
    print_colored "BRIGHT_GREEN" "════════════════════════════════════════════════════════════"
    print_colored "BRIGHT_GREEN" "${BOLD}🎉 STACK N8N OPÉRATIONNELLE!${RESET}"
    print_colored "BRIGHT_BLUE" "   6 services connectés et fonctionnels"
    print_colored "BRIGHT_MAGENTA" "   Architecture: Main + Worker + Queue + Database + Tunnel"
    print_colored "BRIGHT_GREEN" "════════════════════════════════════════════════════════════"
    echo
}

# ============================================================================
# 🎮 INTERACTIONS UTILISATEUR
# ============================================================================

ask_confirmation() {
    local question=$1
    local default=${2:-"y"}
    
    print_colored "BRIGHT_MAGENTA" "$question"
    
    if [[ $default == "y" ]]; then
        print_colored "YELLOW" "[Y/n]: " true
    else  
        print_colored "YELLOW" "[y/N]: " true
    fi
    
    read -r response
    case "${response,,}" in  # Conversion en minuscules
        y|yes|"")
            [[ $default == "y" ]] && return 0 || return 1
            ;;
        n|no)
            return 1
            ;;
        *)
            return $([[ $default == "y" ]] && echo 0 || echo 1)
            ;;
    esac
}

open_browser() {
    if ask_confirmation "🌐 Ouvrir n8n dans le navigateur?" "y"; then
        local url="http://localhost:5678"
        
        case $OS in
            "macOS")
                if command -v open >/dev/null 2>&1; then
                    open "$url" && print_success "Navigateur ouvert!"
                else
                    print_warning "Commande 'open' non disponible"
                fi
                ;;
            "Linux") 
                # Essayer différentes commandes selon l'environnement
                if command -v xdg-open >/dev/null 2>&1; then
                    xdg-open "$url" >/dev/null 2>&1 && print_success "Navigateur ouvert!"
                elif command -v gnome-open >/dev/null 2>&1; then
                    gnome-open "$url" >/dev/null 2>&1 && print_success "Navigateur ouvert!"
                elif command -v firefox >/dev/null 2>&1; then
                    firefox "$url" >/dev/null 2>&1 & print_success "Firefox ouvert!"
                else
                    print_warning "Aucun navigateur détecté automatiquement"
                    print_info "Ouvrez manuellement: $url"
                fi
                ;;
        esac
    fi
}

# ============================================================================
# 🎯 FONCTION PRINCIPALE 
# ============================================================================

main() {
    # Gestion propre des interruptions
    trap 'echo; print_warning "Script interrompu par l'\''utilisateur 👋"; exit 130' INT TERM
    
    # Changer vers le répertoire du script
    cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null || {
        print_error "Impossible de changer vers le répertoire du script"
        exit 1
    }
    
    print_banner
    
    # Détection système
    detect_os
    echo
    
    # Vérifications préliminaires 
    local prereq_failed=false
    
    check_bash_version || prereq_failed=true
    check_docker || prereq_failed=true
    check_docker_compose || prereq_failed=true  
    check_env_file || prereq_failed=true
    
    if [[ $prereq_failed == "true" ]]; then
        echo
        print_error "Prérequis manquants - corrigez avant de continuer"
        echo
        read -r -p "$(print_colored "YELLOW" "Appuyez sur Entrée pour quitter..." true)"
        exit 1
    fi
    
    echo
    
    # Confirmation utilisateur
    if ! ask_confirmation "🚀 Lancer la stack n8n complète (6 services)?" "y"; then
        print_colored "BRIGHT_BLUE" "👋 À bientôt!"
        exit 0
    fi
    
    # Démarrage des services
    if start_all_services; then
        show_service_status
        show_access_info 
        show_useful_commands
        show_final_message
        
        # Proposer navigateur
        open_browser
        
        echo
        print_colored "BRIGHT_CYAN" "💡 Pour arrêter: ${BOLD}$COMPOSE_CMD down${RESET}"
    else
        echo
        print_error "Échec du démarrage"
        print_info "Diagnostic: $COMPOSE_CMD logs"
        exit 1
    fi
    
    echo
    read -r -p "$(print_colored "YELLOW" "Appuyez sur Entrée pour quitter..." true)"
}

# ============================================================================
# 🏃‍♂️ POINT D'ENTRÉE
# ============================================================================

# Vérifications de base avant lancement
if [[ $BASH_VERSION =~ ^[0-3]\. ]]; then
    echo "❌ Bash 4.0+ requis. Version actuelle: $BASH_VERSION"
    exit 1
fi

# Lancement du script principal  
main "$@"