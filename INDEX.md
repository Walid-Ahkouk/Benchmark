# Index - Variante C

Guide de navigation pour tous les fichiers du projet.

---

## Vue d'Ensemble

**Variante**: C - Spring Boot + Spring MVC + Spring Data JPA + PostgreSQL
**Fichiers générés**: 23
**Lignes de code**: ~4000+
**Documentation**: ~3000+ lignes
**Status**: ✅ Prêt pour production

---

## 📚 Documentation (7 fichiers)

### Documentation Utilisateur

| Fichier | Description | Quand l'utiliser |
|---------|-------------|------------------|
| [README.md](README.md) | **Documentation principale** - Vue d'ensemble complète | Premier fichier à lire |
| [QUICK-START.md](QUICK-START.md) | **Démarrage rapide (5 min)** - Installation et premiers tests | Pour démarrer rapidement |
| [API-TESTS.md](API-TESTS.md) | **Tests API complets** - Exemples curl pour tous les endpoints | Pour tester l'API |

### Documentation Technique

| Fichier | Description | Quand l'utiliser |
|---------|-------------|------------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | **Architecture détaillée** - Design patterns, optimisations | Pour comprendre le design |
| [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md) | **Structure complète** - Tous les packages et fichiers | Pour naviguer le code |
| [DIAGRAMS.md](DIAGRAMS.md) | **Diagrammes ASCII** - Visualisation des flux | Pour visualiser l'architecture |
| [FILES-GENERATED.md](FILES-GENERATED.md) | **Liste des fichiers** - Inventaire complet | Pour référence rapide |

### Ce Fichier

| Fichier | Description |
|---------|-------------|
| [INDEX.md](INDEX.md) | **Guide de navigation** - Table des matières |

---

## 💻 Code Source (7 fichiers Java)

### Point d'Entrée

| Fichier | Package | Ligne | Description |
|---------|---------|-------|-------------|
| [VariantCApplication.java](src/main/java/com/benchmark/variantc/VariantCApplication.java) | `com.benchmark.variantc` | ~20 | Classe principale Spring Boot |

### Entités JPA (2 fichiers)

| Fichier | Package | Lignes | Description |
|---------|---------|--------|-------------|
| [Category.java](src/main/java/com/benchmark/variantc/entity/Category.java) | `.entity` | ~130 | Entité Category avec @OneToMany |
| [Item.java](src/main/java/com/benchmark/variantc/entity/Item.java) | `.entity` | ~150 | Entité Item avec @ManyToOne LAZY |

### Repositories (2 fichiers)

| Fichier | Package | Lignes | Description |
|---------|---------|--------|-------------|
| [CategoryRepository.java](src/main/java/com/benchmark/variantc/repository/CategoryRepository.java) | `.repository` | ~30 | Interface Spring Data pour Category |
| [ItemRepository.java](src/main/java/com/benchmark/variantc/repository/ItemRepository.java) | `.repository` | ~40 | Interface Spring Data pour Item + filtrage |

### Contrôleurs REST (2 fichiers)

| Fichier | Package | Lignes | Endpoints |
|---------|---------|--------|-----------|
| [CategoryController.java](src/main/java/com/benchmark/variantc/controller/CategoryController.java) | `.controller` | ~160 | 6 endpoints (CRUD + items relationnels) |
| [ItemController.java](src/main/java/com/benchmark/variantc/controller/ItemController.java) | `.controller` | ~200 | 5 endpoints (CRUD + filtrage) |

---

## ⚙️ Configuration (3 fichiers)

### Build & Dépendances

| Fichier | Format | Lignes | Description |
|---------|--------|--------|-------------|
| [pom.xml](pom.xml) | XML | ~80 | Configuration Maven, dépendances Spring Boot |
| [.gitignore](.gitignore) | Text | ~30 | Exclusions Git (target/, .idea/, etc.) |

### Application

| Fichier | Format | Lignes | Description |
|---------|--------|--------|-------------|
| [application.properties](src/main/resources/application.properties) | Properties | ~80 | Config complète (DB, HikariCP, Actuator, etc.) |

---

## 🐳 Docker & Déploiement (4 fichiers)

### Images & Conteneurs

| Fichier | Format | Lignes | Description |
|---------|--------|--------|-------------|
| [Dockerfile](Dockerfile) | Dockerfile | ~35 | Image multi-stage (Maven build + JRE runtime) |
| [docker-compose.yml](docker-compose.yml) | YAML | ~80 | 4 services (Postgres, App, Prometheus, Grafana) |
| [prometheus.yml](prometheus.yml) | YAML | ~20 | Config scraping Prometheus |

### Scripts de Démarrage

| Fichier | Platform | Lignes | Description |
|---------|----------|--------|-------------|
| [start.sh](start.sh) | Linux/Mac | ~70 | Script Bash de démarrage automatique |
| [start.bat](start.bat) | Windows | ~110 | Script Batch de démarrage automatique |

---

## 💾 Base de Données (1 fichier)

| Fichier | Format | Lignes | Description |
|---------|--------|--------|-------------|
| [database-init.sql](database-init.sql) | SQL | ~240 | Création tables + 10 catégories + 100 items |

---

## 📂 Structure par Fonctionnalité

### 1. Démarrage Rapide

```
Premier pas ?
↓
QUICK-START.md → start.sh/start.bat → Votre app tourne!
```

**Fichiers impliqués**:
- [QUICK-START.md](QUICK-START.md)
- [start.sh](start.sh) ou [start.bat](start.bat)
- [docker-compose.yml](docker-compose.yml)

---

### 2. Comprendre l'Architecture

```
Comment ça marche ?
↓
ARCHITECTURE.md → DIAGRAMS.md → PROJECT-STRUCTURE.md
```

**Fichiers impliqués**:
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [DIAGRAMS.md](DIAGRAMS.md)
- [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md)

---

### 3. Développer l'API

```
Ajouter un endpoint ?
↓
CategoryController.java → CategoryRepository.java → Category.java
```

**Fichiers impliqués**:
- [CategoryController.java](src/main/java/com/benchmark/variantc/controller/CategoryController.java)
- [ItemController.java](src/main/java/com/benchmark/variantc/controller/ItemController.java)
- [CategoryRepository.java](src/main/java/com/benchmark/variantc/repository/CategoryRepository.java)
- [ItemRepository.java](src/main/java/com/benchmark/variantc/repository/ItemRepository.java)
- [Category.java](src/main/java/com/benchmark/variantc/entity/Category.java)
- [Item.java](src/main/java/com/benchmark/variantc/entity/Item.java)

---

### 4. Tester l'API

```
Tester les endpoints ?
↓
API-TESTS.md → Copier les commandes curl → Tester
```

**Fichiers impliqués**:
- [API-TESTS.md](API-TESTS.md)

---

### 5. Configurer l'Application

```
Changer la config ?
↓
application.properties → docker-compose.yml (pour Docker)
```

**Fichiers impliqués**:
- [application.properties](src/main/resources/application.properties)
- [docker-compose.yml](docker-compose.yml)
- [pom.xml](pom.xml)

---

### 6. Déployer

```
Mettre en production ?
↓
Dockerfile → docker-compose.yml → start.sh
```

**Fichiers impliqués**:
- [Dockerfile](Dockerfile)
- [docker-compose.yml](docker-compose.yml)
- [start.sh](start.sh) / [start.bat](start.bat)

---

## 🎯 Par Use Case

### Use Case 1: "Je veux juste lancer l'app maintenant"

1. Lis [QUICK-START.md](QUICK-START.md) (5 min)
2. Lance `./start.sh` (Linux/Mac) ou `start.bat` (Windows)
3. Teste avec les exemples de [API-TESTS.md](API-TESTS.md)

**Temps**: 10 minutes

---

### Use Case 2: "Je veux comprendre le code"

1. Lis [README.md](README.md) pour la vue d'ensemble
2. Lis [ARCHITECTURE.md](ARCHITECTURE.md) pour le design
3. Consulte [DIAGRAMS.md](DIAGRAMS.md) pour les visuels
4. Explore [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md) pour les détails

**Temps**: 1 heure

---

### Use Case 3: "Je veux ajouter un nouvel endpoint"

1. Regarde les contrôleurs existants:
   - [CategoryController.java](src/main/java/com/benchmark/variantc/controller/CategoryController.java)
   - [ItemController.java](src/main/java/com/benchmark/variantc/controller/ItemController.java)
2. Crée ta méthode en suivant le même pattern
3. Teste avec curl (voir [API-TESTS.md](API-TESTS.md))
4. Ajoute la doc dans [API-TESTS.md](API-TESTS.md)

**Temps**: 30 minutes

---

### Use Case 4: "Je veux modifier la config DB"

1. Modifie [application.properties](src/main/resources/application.properties)
2. Ou modifie [docker-compose.yml](docker-compose.yml) (variables d'env)
3. Relance l'app

**Temps**: 5 minutes

---

### Use Case 5: "Je veux ajouter des données de test"

1. Modifie [database-init.sql](database-init.sql)
2. Redémarre le conteneur Postgres:
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

**Temps**: 10 minutes

---

## 🔍 Par Type de Fichier

### Java (7)

- **Application**: [VariantCApplication.java](src/main/java/com/benchmark/variantc/VariantCApplication.java)
- **Entities**: [Category.java](src/main/java/com/benchmark/variantc/entity/Category.java), [Item.java](src/main/java/com/benchmark/variantc/entity/Item.java)
- **Repositories**: [CategoryRepository.java](src/main/java/com/benchmark/variantc/repository/CategoryRepository.java), [ItemRepository.java](src/main/java/com/benchmark/variantc/repository/ItemRepository.java)
- **Controllers**: [CategoryController.java](src/main/java/com/benchmark/variantc/controller/CategoryController.java), [ItemController.java](src/main/java/com/benchmark/variantc/controller/ItemController.java)

### Configuration (4)

- **Maven**: [pom.xml](pom.xml)
- **Spring Boot**: [application.properties](src/main/resources/application.properties)
- **Docker**: [docker-compose.yml](docker-compose.yml), [prometheus.yml](prometheus.yml)

### Documentation (7)

- [README.md](README.md)
- [QUICK-START.md](QUICK-START.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [API-TESTS.md](API-TESTS.md)
- [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md)
- [DIAGRAMS.md](DIAGRAMS.md)
- [FILES-GENERATED.md](FILES-GENERATED.md)

### Scripts & Autres (5)

- **Démarrage**: [start.sh](start.sh), [start.bat](start.bat)
- **Database**: [database-init.sql](database-init.sql)
- **Docker**: [Dockerfile](Dockerfile)
- **Git**: [.gitignore](.gitignore)

---

## 📊 Statistiques Rapides

```
Total Fichiers:     23
├── Java:           7  (30%)
├── Documentation:  7  (30%)
├── Configuration:  4  (17%)
├── Scripts/SQL:    3  (13%)
└── Autres:         2  (10%)

Lignes de Code:     ~1100 (Java + Config)
Lignes de Doc:      ~3000
Total:              ~4100+ lignes

Endpoints API:      11
├── Categories:     6
└── Items:          5

Services Docker:    4
├── PostgreSQL
├── Spring Boot
├── Prometheus
└── Grafana
```

---

## 🚀 Commandes Rapides

### Démarrer

```bash
# Linux/Mac
./start.sh

# Windows
start.bat

# Docker Compose manuel
docker-compose up -d
```

### Tester

```bash
# Health check
curl http://localhost:8080/actuator/health

# Categories
curl "http://localhost:8080/api/categories?page=0&size=5"

# Items
curl "http://localhost:8080/api/items?page=0&size=10"
```

### Logs

```bash
# Tous les services
docker-compose logs -f

# Juste l'app
docker-compose logs -f app

# Juste Postgres
docker-compose logs -f postgres
```

### Arrêter

```bash
# Arrêt normal
docker-compose down

# Supprimer les volumes (reset complet)
docker-compose down -v
```

---

## 🆘 Aide Rapide

| Problème | Solution |
|----------|----------|
| L'app ne démarre pas | Voir [QUICK-START.md](QUICK-START.md) section Troubleshooting |
| Erreur de connexion DB | Vérifier [docker-compose.yml](docker-compose.yml) et [application.properties](src/main/resources/application.properties) |
| Endpoint 404 | Vérifier les contrôleurs dans [CategoryController.java](src/main/java/com/benchmark/variantc/controller/CategoryController.java) et [ItemController.java](src/main/java/com/benchmark/variantc/controller/ItemController.java) |
| Comment ajouter une entité ? | Suivre le pattern dans [Category.java](src/main/java/com/benchmark/variantc/entity/Category.java) et [Item.java](src/main/java/com/benchmark/variantc/entity/Item.java) |
| Comment tester ? | Voir [API-TESTS.md](API-TESTS.md) |
| Comprendre l'architecture ? | Lire [ARCHITECTURE.md](ARCHITECTURE.md) et [DIAGRAMS.md](DIAGRAMS.md) |

---

## 🎓 Parcours d'Apprentissage

### Niveau 1: Débutant (30 min)

1. [QUICK-START.md](QUICK-START.md) - Lancer l'app
2. [API-TESTS.md](API-TESTS.md) - Tester quelques endpoints
3. [README.md](README.md) - Vue d'ensemble

### Niveau 2: Intermédiaire (2h)

1. [ARCHITECTURE.md](ARCHITECTURE.md) - Comprendre le design
2. [DIAGRAMS.md](DIAGRAMS.md) - Visualiser les flux
3. [CategoryController.java](src/main/java/com/benchmark/variantc/controller/CategoryController.java) - Lire le code
4. [Category.java](src/main/java/com/benchmark/variantc/entity/Category.java) - Comprendre JPA

### Niveau 3: Avancé (4h+)

1. [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md) - Structure complète
2. Tous les fichiers Java - Analyse du code
3. [docker-compose.yml](docker-compose.yml) - Architecture Docker
4. [application.properties](src/main/resources/application.properties) - Optimisations
5. Modifications et expérimentations

---

## 📞 Support

**Documentation locale**: Tous les MD dans ce dossier
**Logs**: `docker-compose logs app`
**Métriques**: http://localhost:8080/actuator
**Database**: Voir [database-init.sql](database-init.sql)

---

## ✅ Checklist de Démarrage

- [ ] J'ai lu [QUICK-START.md](QUICK-START.md)
- [ ] J'ai lancé `./start.sh` ou `start.bat`
- [ ] L'app répond sur http://localhost:8080
- [ ] J'ai testé `/actuator/health`
- [ ] J'ai testé un endpoint avec curl
- [ ] J'ai lu [README.md](README.md)
- [ ] J'ai consulté [ARCHITECTURE.md](ARCHITECTURE.md)
- [ ] Je sais où trouver les logs
- [ ] Je comprends la structure du projet

---

**Projet complet et documenté!** 🎉

Commencez par [QUICK-START.md](QUICK-START.md) pour démarrer rapidement!
