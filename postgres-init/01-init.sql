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
