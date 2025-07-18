# 🔄 N8N Auto-hébergé avec Backup Automatique

## 📋 Description

Ce projet permet d'auto-héberger n8n avec PostgreSQL et inclut un système de backup automatique des workflows via GitHub.

## 🚀 Installation Rapide

### 1. Cloner le projet
```bash
git clone https://github.com/yanix2445/n8n.git
cd n8n
```

### 2. Lancer le script d'installation
```powershell
.\setup-n8n.ps1
```

### 3. Démarrer n8n
```bash
docker-compose up -d
```

### 4. Accéder à n8n
- URL : http://localhost:2445
- Utilisateur : `admin`
- Mot de passe : `445012`

## 📁 Structure

```
├── docker-compose.yml     # Configuration n8n + PostgreSQL
├── setup-n8n.ps1         # Script d'installation automatique
├── monitor.ps1           # Script de surveillance
├── backup/               # Dossier des sauvegardes de workflows
└── .env                  # Variables d'environnement (généré automatiquement)
```

## 🐳 Docker Compose

Le `docker-compose.yml` configure :
- **n8n** : Interface d'automatisation sur le port 2445
- **PostgreSQL** : Base de données pour stocker les workflows
- **Volumes persistants** : Données sauvegardées automatiquement
- **Configuration optimisée** : Prêt pour la production

## 🔧 Scripts d'Installation

### setup-n8n.ps1
Script PowerShell qui fait tout automatiquement :
- Vérifie Docker
- Crée les dossiers nécessaires
- Génère les mots de passe sécurisés
- Configure le fichier `.env`
- Initialise PostgreSQL

### monitor.ps1
Script de surveillance pour vérifier que tout fonctionne bien.

## 💾 Système de Backup

### 2 Workflows pour gérer les sauvegardes :

#### 1. Workflow "backup" 
**Ce qu'il fait :**
- Récupère automatiquement tous les workflows de votre instance n8n
- Les sauvegarde au format JSON 
- Les envoie sur votre repository GitHub
- Envoie un email de confirmation

**Quand ça se déclenche :**
- Automatiquement selon la planification
- Manuellement si besoin

#### 2. Workflow "importe backup"
**Ce qu'il fait :**
- Se déclenche avec la commande Telegram : `backup n8n`
- Liste tous les backups disponibles sur GitHub
- Vous permet de choisir lequel restaurer
- Télécharge le fichier JSON
- Recrée le workflow dans votre instance n8n

## 🔄 Comment ça marche

```
Instance n8n ──┐
               │
               ▼
         Workflow backup ──► GitHub Repository
               │                    │
               │                    │
               ▼                    ▼
          Email notification   Fichiers JSON sauvegardés
                                    │
                                    │
Instance n8n ◄── Workflow restore ◄─┘
               │
               ▼
         Commande Telegram
```

## ⚙️ Configuration

Le fichier `.env` est généré automatiquement avec :
- Mots de passe sécurisés
- Configuration PostgreSQL
- URLs d'accès
- Paramètres de backup

## 🎯 Avantages

- **Installation en 3 commandes**
- **Backup automatique** de tous vos workflows
- **Restauration simple** via Telegram
- **Données persistantes** même après redémarrage
- **Configuration sécurisée** générée automatiquement

---

🚀 **C'est tout ! Votre n8n est prêt avec backup automatique intégré.**
