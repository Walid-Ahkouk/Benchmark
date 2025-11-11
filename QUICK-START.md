# Quick Start - Variante C

Guide de démarrage rapide pour lancer l'application en 5 minutes.

## Prérequis

- Docker & Docker Compose installés
- Port 8080, 5432, 9090, 3000 disponibles

## Option 1: Démarrage Ultra-Rapide (Recommandé)

```bash
cd V-C
chmod +x start.sh
./start.sh
```

Le script va:
1. Démarrer PostgreSQL avec données de test
2. Builder et lancer l'application Spring Boot
3. Démarrer Prometheus et Grafana
4. Vérifier que tout fonctionne
5. Afficher les URLs et exemples

**Temps estimé**: 2-3 minutes

---

## Option 2: Démarrage Manuel avec Docker Compose

```bash
cd V-C
docker-compose up -d
```

Attendre 30-60 secondes, puis vérifier:

```bash
curl http://localhost:8080/actuator/health
```

---

## Option 3: Démarrage Local (Sans Docker)

### 1. Démarrer PostgreSQL

```bash
docker run -d --name variant-c-postgres \
  -e POSTGRES_DB=benchmark_db \
  -e POSTGRES_USER=benchmark_user \
  -e POSTGRES_PASSWORD=benchmark_pass \
  -p 5432:5432 \
  postgres:15-alpine
```

### 2. Initialiser la base

```bash
docker cp database-init.sql variant-c-postgres:/tmp/
docker exec variant-c-postgres psql -U benchmark_user -d benchmark_db -f /tmp/database-init.sql
```

### 3. Lancer l'application

```bash
mvn spring-boot:run
```

**Temps estimé**: 3-4 minutes

---

## Vérifier que Tout Fonctionne

### Test 1: Health Check

```bash
curl http://localhost:8080/actuator/health | jq
```

**Résultat attendu**: `"status": "UP"`

### Test 2: Récupérer les Catégories

```bash
curl "http://localhost:8080/api/categories?page=0&size=5" | jq
```

**Résultat attendu**: JSON avec 5 catégories

### Test 3: Récupérer les Items

```bash
curl "http://localhost:8080/api/items?page=0&size=10" | jq
```

**Résultat attendu**: JSON avec 10 items

### Test 4: Filtrer par Catégorie

```bash
curl "http://localhost:8080/api/items?categoryId=1&page=0&size=5" | jq
```

**Résultat attendu**: Items de la catégorie Electronics

---

## URLs Disponibles

| Service | URL | Credentials |
|---------|-----|-------------|
| **API** | http://localhost:8080 | - |
| **Health** | http://localhost:8080/actuator/health | - |
| **Metrics** | http://localhost:8080/actuator/prometheus | - |
| **Prometheus** | http://localhost:9090 | - |
| **Grafana** | http://localhost:3000 | admin / admin |
| **PostgreSQL** | localhost:5432 | benchmark_user / benchmark_pass |

---

## Premiers Pas avec l'API

### 1. Créer une Catégorie

```bash
curl -X POST http://localhost:8080/api/categories \
  -H "Content-Type: application/json" \
  -d '{
    "code": "GAMING",
    "name": "Gaming Equipment"
  }' | jq
```

### 2. Créer un Item

```bash
curl -X POST http://localhost:8080/api/items \
  -H "Content-Type: application/json" \
  -d '{
    "sku": "GAME-001",
    "name": "Gaming Mouse RGB",
    "price": 59.99,
    "stock": 100,
    "categoryId": 1
  }' | jq
```

### 3. Lister les Items Paginés

```bash
curl "http://localhost:8080/api/items?page=0&size=10&sort=price,desc" | jq
```

### 4. Mettre à Jour un Item

```bash
curl -X PUT http://localhost:8080/api/items/1 \
  -H "Content-Type: application/json" \
  -d '{
    "price": 1199.99,
    "stock": 45
  }' | jq
```

### 5. Supprimer un Item

```bash
curl -X DELETE http://localhost:8080/api/items/101 -i
```

---

## Monitoring Rapide

### Voir les Connexions Actives (HikariCP)

```bash
curl -s http://localhost:8080/actuator/metrics/hikari.connections.active | jq
```

### Voir le Nombre de Requêtes HTTP

```bash
curl -s http://localhost:8080/actuator/metrics/http.server.requests | jq
```

### Voir l'Utilisation Mémoire

```bash
curl -s http://localhost:8080/actuator/metrics/jvm.memory.used | jq
```

### Dashboard Grafana

1. Ouvrir http://localhost:3000
2. Login: `admin` / `admin`
3. Ajouter une Data Source: Prometheus (http://prometheus:9090)
4. Créer un dashboard avec les métriques de l'app

---

## Test de Performance Rapide

### Générer 100 Requêtes

```bash
for i in {1..100}; do
  curl -s "http://localhost:8080/api/items?page=0&size=20" > /dev/null &
done
wait
echo "Test terminé!"
```

### Observer les Métriques en Temps Réel

```bash
watch -n 1 'curl -s http://localhost:8080/actuator/metrics/hikari.connections.active | jq ".measurements[0].value"'
```

---

## Arrêter l'Application

### Docker Compose

```bash
docker-compose down
```

### Supprimer les Volumes (Reset complet)

```bash
docker-compose down -v
```

### Maven Local

```bash
# Ctrl+C dans le terminal où mvn spring-boot:run s'exécute
```

---

## Troubleshooting

### L'application ne démarre pas

**Vérifier les logs:**
```bash
docker-compose logs app
```

**Vérifier que PostgreSQL est démarré:**
```bash
docker-compose ps postgres
```

### Port 8080 déjà utilisé

**Changer le port dans `application.properties`:**
```properties
server.port=8081
```

Ou via variable d'environnement:
```bash
SERVER_PORT=8081 mvn spring-boot:run
```

### Erreur de connexion à PostgreSQL

**Vérifier que PostgreSQL accepte les connexions:**
```bash
docker-compose exec postgres psql -U benchmark_user -d benchmark_db -c "SELECT 1;"
```

### Données de test manquantes

**Réexécuter le script d'initialisation:**
```bash
docker-compose exec postgres psql -U benchmark_user -d benchmark_db -f /docker-entrypoint-initdb.d/init.sql
```

---

## Prochaines Étapes

1. **Lire la documentation complète**: [README.md](README.md)
2. **Comprendre l'architecture**: [ARCHITECTURE.md](ARCHITECTURE.md)
3. **Tester tous les endpoints**: [API-TESTS.md](API-TESTS.md)
4. **Explorer la structure**: [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md)

---

## Résumé des Commandes

```bash
# Démarrer (Option 1)
./start.sh

# Démarrer (Option 2)
docker-compose up -d

# Vérifier l'état
curl http://localhost:8080/actuator/health

# Tester l'API
curl "http://localhost:8080/api/categories?page=0&size=5" | jq

# Voir les logs
docker-compose logs -f app

# Arrêter
docker-compose down
```

---

**Temps total de démarrage**: 2-3 minutes
**Prêt à benchmarker!** 🚀
