# 🚀 N8N Avancé avec PostgreSQL, Redis, Worker & Cloudflare Tunnel

Configuration Docker Compose **avancée** pour héberger n8n avec de bonnes performances, scalabilité et accès HTTPS sécurisé via Cloudflare Tunnel. Idéal pour usage personnel ou petites équipes.

## 🏗️ Architecture de la Solution

```
🌐 Internet (HTTPS)
     ↓
🔧 Cloudflare Tunnel (SSL/TLS + DDoS Protection)
     ↓
🎯 n8n Main (Interface Web + API + Gestion)
     ↓
🚀 Redis Queue ←→ ⚡ n8n Worker (Traitement Parallèle)
     ↓
🗄️ PostgreSQL (Base de Données Production)
```

### 🎯 Pourquoi cette Architecture ?

**🔥 PERFORMANCE MAXIMALE**
- **Mode Queue** : 10 workflows simultanés au lieu de 1 séquentiel
- **Worker dédié** : Interface fluide même avec 100 workflows en cours
- **Redis** : Queue ultra-rapide en mémoire

**🛡️ SÉCURITÉ RENFORCÉE**
- **Variables d'environnement bloquées** dans les workflows
- **Cookies sécurisés** HTTPS obligatoires
- **Resource limits** : Protection des ressources système
- **Logs séparés** : Suivi et débogage

**📈 SCALABILITÉ HORIZONTALE**
- **Workers multiples** : `docker-compose up --scale n8n-worker=5`
- **Auto-scaling** : Ajoutez des workers selon la charge
- **High Availability** : Si un worker plante, les autres continuent

## 📋 Prérequis

### Obligatoire
- **Docker** et **Docker Compose** installés
- **Domaine configuré sur Cloudflare** (gratuit)
- **Compte Cloudflare** (gratuit)

### Recommandé (Usage Avancé)
- **4GB RAM minimum** sur votre serveur/PC
- **2 CPU cores minimum**
- **20GB stockage** pour les volumes Docker

## 🔧 Installation Étape par Étape

### ÉTAPE 1 : Configuration Cloudflare Tunnel

1. **Connectez-vous au dashboard Cloudflare**
2. **Allez dans "Zero Trust" > "Networks" > "Tunnels"**
3. **Créez un nouveau tunnel** (nom : n8n)
4. **Configurez le tunnel :**
   - Type : `HTTPS`
   - URL : `http://n8n:5678` ⚠️ (pas localhost !)
   - Domaine : `votre-domaine.com`
5. **Copiez le token généré** (commence par `eyJ...`)

### ÉTAPE 2 : Configuration du Projet

1. **Clonez ou téléchargez** ce projet
2. **Modifiez le fichier `.env`** avec vos informations :

```bash
# ⚠️ CHANGEZ CES VALEURS !

# PostgreSQL (sécurité générée automatiquement)
POSTGRES_PASSWORD=votre-mot-de-passe-postgres

# n8n Login (ce que VOUS tapez pour vous connecter)
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=VotreMotDePasse123!

# Clé de chiffrement (déjà générée de manière sécurisée)
N8N_ENCRYPTION_KEY=c87c981aecc82232ca61bd22d31e0104da3359a0b0a47356d7d8ad4fd6fcd066

# Cloudflare (remplacez par vos vraies valeurs)
CLOUDFLARE_TUNNEL_TOKEN=eyJ... (votre token)
CLOUDFLARE_DOMAIN=votre-domaine.com
WEBHOOK_URL=https://votre-domaine.com
N8N_EDITOR_BASE_URL=https://votre-domaine.com

# Autres configurations
TIMEZONE=Europe/Paris
```

### ÉTAPE 3 : Lancement

**🚀 SCRIPTS MODERNES DISPONIBLES :**

**Windows (PowerShell 7):**
```powershell
# Script PowerShell 7 moderne avec couleurs et animations
./start.ps1

# Ou script Batch classique
start.bat
```

**macOS/Linux (Bash universel):**
```bash
# Script Bash fun et moderne - Compatible macOS & Linux
./start.sh
```

**Manuel (tous systèmes):**
```bash
# Démarrage complet
docker-compose up -d

# Voir les logs en temps réel
docker-compose logs -f

# Vérifier l'état des services
docker-compose ps
```

### ÉTAPE 4 : Accès

- **Local** : http://localhost:5678
- **Internet** : https://votre-domaine.com
- **Login** : admin / VotreMotDePasse123!

## 🎨 Scripts de Démarrage Modernes

Ce projet inclut des scripts avancés optimisés pour chaque système :

### 📁 Fichiers de Scripts

```
🖥️  Windows:
   ├── start.ps1     - PowerShell 7 moderne (couleurs, animations, gestion d'erreurs)
   └── start.bat     - Batch classique (compatibilité)

🍎 macOS/Linux:
   └── start.sh      - Bash universel fun (macOS & Linux, couleurs, spinners)
```

### ✨ Fonctionnalités des Scripts Modernes

**PowerShell 7 (start.ps1) :**
- 🎨 Interface colorée avec animations
- 🔍 Vérifications avancées (Docker, fichiers, versions)
- 📊 Barres de progression et spinners
- 🌐 Ouverture automatique du navigateur
- 🛡️ Gestion d'erreurs robuste
- 📋 Résumé détaillé des services

**Bash Universel (start.sh) :**
- 🌈 Couleurs adaptatives selon le terminal (8/256 couleurs)
- 🚀 Spinners et animations fluides 
- 🔧 Détection automatique macOS/Linux/distributions
- 📊 Barres de progression pour chaque service
- 🎯 Détection Docker Compose V1/V2 automatique
- 🧠 Vérifications intelligentes (Homebrew, package managers)
- 🎉 Animation de célébration à la fin

### 🎮 Utilisation Recommandée

**Pour une expérience optimale :**

```bash
# Windows - PowerShell 7
./start.ps1

# macOS - Terminal Bash/Zsh
./start.sh

# Linux - Bash universel  
./start.sh

# Fallback manuel
docker-compose up -d
```

## 🎛️ Gestion des Services

### Commandes de Base

```bash
# Arrêter tous les services
docker-compose down

# Redémarrer un service spécifique
docker-compose restart n8n

# Voir les logs d'un service
docker-compose logs postgres
docker-compose logs redis
docker-compose logs n8n-worker

# Mise à jour des images
docker-compose pull
docker-compose up -d
```

### Scaling Avancé

```bash
# Ajouter plus de workers pour plus de performance
docker-compose up -d --scale n8n-worker=3

# Mode économique (sans worker)
docker-compose up -d postgres redis n8n cloudflared

# Redémarrer seulement les workers
docker-compose restart n8n-worker
```

## 📊 Monitoring & Performance

### Surveillance des Ressources

```bash
# Voir l'utilisation des ressources
docker stats

# Logs en temps réel de tous les services
docker-compose logs -f --tail=100

# Vérifier l'état de santé
docker-compose ps
```

### Métriques Importantes

- **CPU Usage** : n8n main (~50%), worker (~30%), redis (~10%)
- **Memory Usage** : n8n main (~1GB), worker (~500MB), redis (~200MB)
- **Queue Redis** : Visible dans les logs Redis
- **Workflows actifs** : Visible dans l'interface n8n

## 🛡️ Sécurité & Bonnes Pratiques

### 🔐 Configuration Sécurisée

**✅ CE QUI EST DÉJÀ CONFIGURÉ :**
- Mots de passe sécurisés générés avec OpenSSL
- Clé de chiffrement unique pour vos données
- Variables d'environnement bloquées dans les workflows
- Limites de ressources sur tous les conteneurs
- Vérifications de santé sur tous les services
- Réseau isolé Docker

**⚠️ À FAIRE MANUELLEMENT :**
- Changez `N8N_BASIC_AUTH_PASSWORD` dans `.env`
- Ne commitez JAMAIS le fichier `.env` sur Git
- Sauvegardez votre clé `N8N_ENCRYPTION_KEY` (si perdue = données irrécupérables)

### 🚨 Alertes de Sécurité

```bash
# Vérifiez que les ports ne sont PAS exposés (sauf 5678)
docker-compose ps

# PostgreSQL et Redis ne doivent PAS être accessibles de l'extérieur
# Seul le port 5678 (n8n) doit être ouvert
```

## 💾 Sauvegarde & Restauration

### Sauvegarde Complète

```bash
# Sauvegarde PostgreSQL
docker-compose exec postgres pg_dump -U n8n_user n8n_database > backup_$(date +%Y%m%d).sql

# Sauvegarde des volumes Docker
docker run --rm -v n8n_app_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n_volumes_$(date +%Y%m%d).tar.gz /data

# Sauvegarde des configurations
cp .env .env.backup
cp docker-compose.yml docker-compose.yml.backup
```

### Restauration

```bash
# Restaurer PostgreSQL
docker-compose exec postgres psql -U n8n_user -d n8n_database < backup_20241128.sql

# Restaurer les volumes
docker run --rm -v n8n_app_data:/data -v $(pwd):/backup alpine tar xzf /backup/n8n_volumes_20241128.tar.gz -C /
```

## 🚀 Optimisations Avancées

### Performance Tuning

**Pour CHARGE IMPORTANTE (>1000 workflows/jour) :**

```yaml
# Dans docker-compose.yml, modifiez :
environment:
  - N8N_CONCURRENCY_PRODUCTION=20  # Plus de parallélisme
  - EXECUTIONS_DATA_MAX_AGE=72     # Garde moins longtemps (3 jours)
```

**Pour ÉCONOMIE DE RESSOURCES :**

```bash
# Lancez sans worker
docker-compose up -d postgres n8n cloudflared

# Réduisez les resource limits
deploy:
  resources:
    limits:
      memory: 1G  # Au lieu de 2G
```

### Scaling Multi-Serveurs

```bash
# Sur serveur 1 : Base de données
docker-compose up -d postgres redis

# Sur serveur 2 : Application
docker-compose up -d n8n cloudflared

# Sur serveur 3 : Workers seulement
docker-compose up -d --scale n8n-worker=5 n8n-worker
```

## 🔍 Dépannage (Troubleshooting)

### Problèmes Courants

**❌ n8n ne démarre pas**
```bash
# Vérifiez les logs
docker-compose logs n8n

# Souvent : problème de connexion à PostgreSQL
docker-compose logs postgres

# Solution : Attendez que PostgreSQL soit prêt
docker-compose up -d postgres
# Attendez 30 secondes puis
docker-compose up -d n8n
```

**❌ Worker ne fonctionne pas**
```bash
# Vérifiez que Redis fonctionne
docker-compose logs redis

# Vérifiez que le worker démarre
docker-compose logs n8n-worker

# Solution : Redémarrez dans l'ordre
docker-compose up -d postgres redis n8n
docker-compose up -d n8n-worker
```

**❌ Cloudflare Tunnel ne fonctionne pas**
```bash
# Vérifiez le token dans .env
echo $CLOUDFLARE_TUNNEL_TOKEN

# Vérifiez les logs
docker-compose logs cloudflared

# Solution courante : Token expiré, regénérez-le
```

### Commandes de Diagnostic

```bash
# État détaillé de tous les services
docker-compose ps -a

# Utilisation des ressources
docker stats --no-stream

# Logs des 50 dernières lignes de chaque service
docker-compose logs --tail=50

# Tester la connectivité réseau
docker-compose exec n8n ping postgres
docker-compose exec n8n ping redis
```

## 📚 Ressources Utiles

### Documentation Officielle
- [n8n Documentation](https://docs.n8n.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Cloudflare Tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

### Communauté
- [n8n Community Forum](https://community.n8n.io/)
- [n8n Discord](https://discord.gg/n8n)
- [GitHub Issues](https://github.com/n8n-io/n8n/issues)

---

## 🎉 Félicitations !

Vous avez maintenant une installation n8n **solide et bien configurée** avec :
- ⚡ **Performance** : Queue + Workers + Redis
- 🛡️ **Sécurité** : Chiffrement + Isolation + Limites de ressources
- 📈 **Scalabilité** : Architecture distribuée
- 🌐 **Accessibilité** : HTTPS mondial via Cloudflare
- 📊 **Monitoring** : Logs + Vérifications + Métriques

**Cette configuration est parfaite pour un usage personnel avancé ou de petites équipes !** 🚀

> **Note** : Pour de vrais environnements d'entreprise, des configurations plus complexes seraient nécessaires (haute disponibilité, clustering, monitoring avancé, etc.)