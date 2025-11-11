# Structure du Projet - Variante C

## Arborescence Complète

```
V-C/
│
├── pom.xml                                  # Configuration Maven (dépendances)
├── Dockerfile                               # Image Docker multi-stage
├── docker-compose.yml                       # Orchestration (Postgres, App, Prometheus, Grafana)
├── prometheus.yml                           # Configuration Prometheus
├── database-init.sql                        # Script d'initialisation de la base
├── start.sh                                 # Script de démarrage rapide
├── .gitignore                              # Fichiers à ignorer par Git
│
├── README.md                                # Documentation principale
├── ARCHITECTURE.md                          # Architecture détaillée
├── API-TESTS.md                            # Tests et exemples d'API
├── PROJECT-STRUCTURE.md                    # Ce fichier
│
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── benchmark/
│       │           └── variantc/
│       │               │
│       │               ├── VariantCApplication.java    # Point d'entrée Spring Boot
│       │               │
│       │               ├── entity/                     # Entités JPA
│       │               │   ├── Category.java           # Entité Catégorie
│       │               │   └── Item.java               # Entité Item
│       │               │
│       │               ├── repository/                 # Repositories Spring Data
│       │               │   ├── CategoryRepository.java # Repository Catégorie
│       │               │   └── ItemRepository.java     # Repository Item
│       │               │
│       │               └── controller/                 # Contrôleurs REST
│       │                   ├── CategoryController.java # API Catégories
│       │                   └── ItemController.java     # API Items
│       │
│       └── resources/
│           └── application.properties                  # Configuration Spring Boot
│
└── target/                                             # Répertoire de build (généré)
    └── variant-c-1.0.0.jar                            # JAR exécutable
```

---

## Description des Fichiers

### Fichiers de Configuration

#### `pom.xml`
**Rôle**: Configuration Maven du projet

**Dépendances clés**:
- `spring-boot-starter-web`: Framework Spring MVC
- `spring-boot-starter-data-jpa`: Persistance JPA/Hibernate
- `postgresql`: Driver PostgreSQL
- `spring-boot-starter-actuator`: Monitoring
- `micrometer-registry-prometheus`: Métriques Prometheus

**Propriétés**:
- Java 17
- Spring Boot 3.2.0
- Packaging: JAR

---

#### `application.properties`
**Rôle**: Configuration de l'application Spring Boot

**Sections principales**:

1. **Application**:
   - Nom de l'application
   - Port (8080)

2. **DataSource (PostgreSQL)**:
   - URL: `jdbc:postgresql://localhost:5432/benchmark_db`
   - User: `benchmark_user`
   - Password: `benchmark_pass`

3. **HikariCP (Connection Pool)**:
   - Max pool size: 20
   - Min idle: 5
   - Connection timeout: 30s
   - Idle timeout: 10min
   - Max lifetime: 30min

4. **JPA/Hibernate**:
   - DDL auto: `update`
   - Batch size: 20
   - Dialect: PostgreSQL

5. **Actuator**:
   - Endpoints exposés: health, info, metrics, prometheus
   - Base path: `/actuator`

6. **Logging**:
   - Level: INFO/DEBUG
   - SQL logging activable

---

### Fichiers Docker

#### `Dockerfile`
**Rôle**: Image Docker multi-stage pour l'application

**Stage 1 - Build**:
- Image: `maven:3.9-eclipse-temurin-17`
- Télécharge les dépendances
- Compile le projet (`mvn clean package`)

**Stage 2 - Runtime**:
- Image: `eclipse-temurin:17-jre-alpine`
- Copie le JAR compilé
- User non-root pour la sécurité
- Health check sur `/actuator/health`
- Expose le port 8080

---

#### `docker-compose.yml`
**Rôle**: Orchestration des services

**Services**:

1. **postgres**:
   - Image: `postgres:15-alpine`
   - Port: 5432
   - Volume: `postgres_data`
   - Init script: `database-init.sql`
   - Health check

2. **app**:
   - Build: Dockerfile local
   - Dépend de: postgres (healthy)
   - Port: 8080
   - Variables d'env pour config DB

3. **prometheus**:
   - Image: `prom/prometheus:latest`
   - Port: 9090
   - Config: `prometheus.yml`
   - Scrape metrics de l'app

4. **grafana**:
   - Image: `grafana/grafana:latest`
   - Port: 3000
   - User/Pass: admin/admin
   - Volume: `grafana_data`

**Network**: `benchmark-network` (bridge)

---

#### `prometheus.yml`
**Rôle**: Configuration de Prometheus

**Jobs**:
- `variant-c-benchmark`: Scrape `/actuator/prometheus` toutes les 10s
- `prometheus`: Self-monitoring

---

### Fichiers de Base de Données

#### `database-init.sql`
**Rôle**: Initialisation de la base PostgreSQL

**Contenu**:
1. Suppression des tables existantes
2. Création des tables (`categories`, `items`)
3. Création des index de performance
4. Insertion de 10 catégories
5. Insertion de 100 items (10 par catégorie)
6. Requêtes de vérification

**Données de test**:
- 10 catégories: ELEC, CLOTH, BOOKS, HOME, SPORTS, TOYS, FOOD, HEALTH, AUTO, MUSIC
- 100 items répartis dans les catégories

---

### Code Source Java

#### `VariantCApplication.java`
**Package**: `com.benchmark.variantc`

**Rôle**: Point d'entrée Spring Boot

**Annotations**:
- `@SpringBootApplication`: Active auto-configuration, component scan, configuration

**Méthode**:
- `main()`: Lance l'application avec `SpringApplication.run()`

---

#### `entity/Category.java`
**Package**: `com.benchmark.variantc.entity`

**Rôle**: Entité JPA pour les catégories

**Annotations clés**:
- `@Entity`: Marque comme entité JPA
- `@Table(name = "categories")`: Nom de la table
- `@Id @GeneratedValue(IDENTITY)`: Clé primaire auto-générée
- `@Column(unique = true)`: Contrainte d'unicité sur `code`
- `@OneToMany(mappedBy = "category")`: Relation vers items
- `@PrePersist`, `@PreUpdate`: Callbacks de cycle de vie

**Champs**:
- `id`: Long (PK)
- `code`: String (unique, 50 chars)
- `name`: String (255 chars)
- `updatedAt`: LocalDateTime
- `items`: List<Item>

**Méthodes**:
- Getters/Setters
- `addItem()`, `removeItem()`: Helpers relationnels
- `equals()`, `hashCode()`, `toString()`

---

#### `entity/Item.java`
**Package**: `com.benchmark.variantc.entity`

**Rôle**: Entité JPA pour les items/produits

**Annotations clés**:
- `@Entity @Table(name = "items")`
- `@ManyToOne(fetch = LAZY)`: Relation vers catégorie (lazy loading)
- `@JoinColumn(name = "category_id")`: Foreign key

**Champs**:
- `id`: Long (PK)
- `sku`: String (unique, 100 chars)
- `name`: String (255 chars)
- `price`: BigDecimal (10,2)
- `stock`: Integer
- `updatedAt`: LocalDateTime
- `category`: Category (nullable, LAZY)

**Optimisations**:
- Lazy loading pour éviter N+1 queries
- `BigDecimal` pour précision monétaire
- Lifecycle callbacks pour `updatedAt`

---

#### `repository/CategoryRepository.java`
**Package**: `com.benchmark.variantc.repository`

**Rôle**: Interface Spring Data JPA pour Category

**Héritage**: `extends JpaRepository<Category, Long>`

**Méthodes personnalisées**:
- `Optional<Category> findByCode(String code)`
- `boolean existsByCode(String code)`

**Méthodes héritées** (de JpaRepository):
- `findAll(Pageable)`: Pagination
- `findById(Long)`: Recherche par ID
- `save(Category)`: Créer/Mettre à jour
- `deleteById(Long)`: Supprimer
- `count()`, `existsById()`, etc.

---

#### `repository/ItemRepository.java`
**Package**: `com.benchmark.variantc.repository`

**Rôle**: Interface Spring Data JPA pour Item

**Méthodes clés**:
- `Optional<Item> findBySku(String sku)`
- `boolean existsBySku(String sku)`
- **`Page<Item> findByCategoryId(Long categoryId, Pageable pageable)`** ⭐

**Note importante**:
La méthode `findByCategoryId()` implémente le **filtrage relationnel avec pagination** requis par le benchmark. Spring Data génère automatiquement la requête SQL:
```sql
SELECT * FROM items WHERE category_id = ? LIMIT ? OFFSET ?
```

---

#### `controller/CategoryController.java`
**Package**: `com.benchmark.variantc.controller`

**Rôle**: Contrôleur REST pour les endpoints de catégories

**Annotations**:
- `@RestController`: Combine @Controller + @ResponseBody
- `@RequestMapping("/api/categories")`: Base path

**Endpoints**:

| Méthode HTTP | Route | Méthode Java | Description |
|--------------|-------|--------------|-------------|
| GET | `/api/categories` | `getAllCategories()` | Liste paginée |
| GET | `/api/categories/{id}` | `getCategoryById()` | Une catégorie |
| POST | `/api/categories` | `createCategory()` | Créer |
| PUT | `/api/categories/{id}` | `updateCategory()` | Mettre à jour |
| DELETE | `/api/categories/{id}` | `deleteCategory()` | Supprimer |
| GET | `/api/categories/{id}/items` | `getItemsByCategory()` | Items (paginé) |

**Injection**:
- `CategoryRepository` (constructor injection)
- `ItemRepository` (pour `/items` endpoint)

**Gestion d'erreurs**:
- 404 Not Found: `ResponseEntity.notFound()`
- 409 Conflict: `ResponseEntity.status(CONFLICT)`
- 201 Created: `ResponseEntity.status(CREATED)`
- 204 No Content: `ResponseEntity.noContent()`

---

#### `controller/ItemController.java`
**Package**: `com.benchmark.variantc.controller`

**Rôle**: Contrôleur REST pour les endpoints d'items

**Endpoints**:

| Méthode HTTP | Route | Méthode Java | Description |
|--------------|-------|--------------|-------------|
| GET | `/api/items` | `getAllItems()` | Liste (avec filter optionnel) |
| GET | `/api/items/{id}` | `getItemById()` | Un item |
| POST | `/api/items` | `createItem()` | Créer |
| PUT | `/api/items/{id}` | `updateItem()` | Mettre à jour |
| DELETE | `/api/items/{id}` | `deleteItem()` | Supprimer |

**Fonctionnalité clé - Filtrage**:
```java
@GetMapping
public ResponseEntity<Map<String, Object>> getAllItems(
        @RequestParam(required = false) Long categoryId,
        Pageable pageable) {
    // Si categoryId fourni, filtre par catégorie
    // Sinon, retourne tous les items
}
```

**Gestion des relations**:
- Accepte `categoryId` dans le body pour POST/PUT
- Valide l'existence de la catégorie
- Permet de set `categoryId = null` pour dissocier

---

### Documentation

#### `README.md`
**Contenu**:
- Vue d'ensemble du projet
- Instructions d'installation
- Configuration PostgreSQL
- Endpoints API (tableau récapitulatif)
- Exemples d'utilisation (curl)
- Monitoring (Actuator, Prometheus)
- Métriques disponibles
- Troubleshooting

---

#### `ARCHITECTURE.md`
**Contenu**:
- Architecture en couches détaillée
- Diagrammes
- Modèle de données (entités, relations)
- Repositories (méthodes Spring Data)
- Contrôleurs (logique métier)
- Configuration de performance (HikariCP, Hibernate)
- Stratégies d'optimisation
- Comparaison avec autres variantes
- Avantages/Limites

---

#### `API-TESTS.md`
**Contenu**:
- Exemples curl pour tous les endpoints
- Tests de pagination
- Tests de filtrage
- Tests de contraintes d'unicité
- Tests de monitoring
- Scripts de test de charge
- Collection Postman

---

#### `PROJECT-STRUCTURE.md`
**Contenu**: Ce fichier - Vue d'ensemble de la structure

---

### Scripts

#### `start.sh`
**Rôle**: Script Bash de démarrage rapide

**Actions**:
1. Vérifie que Docker est démarré
2. Stoppe les containers existants
3. Lance `docker-compose up -d --build`
4. Attend que les services soient prêts
5. Vérifie la santé de chaque service
6. Affiche les URLs et exemples d'utilisation

**Usage**:
```bash
chmod +x start.sh
./start.sh
```

---

## Flux de Données

### Requête HTTP → Réponse

```
Client (curl/browser)
    ↓
[HTTP Request] GET /api/items?categoryId=1&page=0&size=10
    ↓
ItemController.getAllItems(categoryId, pageable)
    ↓
ItemRepository.findByCategoryId(1, Pageable)
    ↓
Spring Data JPA (génère requête SQL)
    ↓
HikariCP (récupère connexion du pool)
    ↓
PostgreSQL (exécute requête)
    ↓
SELECT * FROM items WHERE category_id = 1 LIMIT 10 OFFSET 0
    ↓
Hibernate (map résultats → entités Item)
    ↓
ItemController (construit Map de réponse)
    ↓
Jackson (sérialise Map → JSON)
    ↓
[HTTP Response 200 OK] JSON
    ↓
Client reçoit les données
```

---

## Lifecycle Spring Boot

### Démarrage de l'Application

```
1. VariantCApplication.main()
    ↓
2. SpringApplication.run()
    ↓
3. Auto-configuration Spring Boot
    ├── Scan des @Component, @Service, @Repository, @RestController
    ├── Configuration de la DataSource (HikariCP)
    ├── Configuration de JPA/Hibernate
    ├── Initialisation des repositories
    ├── Mapping des endpoints (@RequestMapping)
    └── Démarrage du serveur Tomcat (port 8080)
    ↓
4. Hibernate DDL (update)
    └── Vérification/Mise à jour du schéma DB
    ↓
5. Actuator Endpoints exposés
    └── /actuator/health, /actuator/prometheus, etc.
    ↓
6. Application prête à recevoir des requêtes
```

---

## Métriques et Monitoring

### Endpoints Actuator Disponibles

| Endpoint | URL | Description |
|----------|-----|-------------|
| Health | `/actuator/health` | État de santé (DB, disk, etc.) |
| Info | `/actuator/info` | Informations de l'app |
| Metrics | `/actuator/metrics` | Liste des métriques |
| Prometheus | `/actuator/prometheus` | Export format Prometheus |

### Métriques Clés

**HikariCP**:
- `hikari.connections.active`: Connexions en cours d'utilisation
- `hikari.connections.idle`: Connexions inactives
- `hikari.connections.total`: Total des connexions
- `hikari.connections.pending`: Threads en attente

**HTTP**:
- `http.server.requests`: Nombre de requêtes par endpoint
- `http.server.requests.duration`: Durée des requêtes

**JVM**:
- `jvm.memory.used`: Mémoire utilisée
- `jvm.memory.max`: Mémoire maximum
- `jvm.threads.live`: Threads actifs
- `jvm.gc.pause`: Pauses GC

---

## Build et Déploiement

### Développement Local

```bash
# 1. Démarrer PostgreSQL
docker run -d -p 5432:5432 \
  -e POSTGRES_DB=benchmark_db \
  -e POSTGRES_USER=benchmark_user \
  -e POSTGRES_PASSWORD=benchmark_pass \
  postgres:15-alpine

# 2. Initialiser la base
psql -U benchmark_user -d benchmark_db -f database-init.sql

# 3. Lancer l'application
mvn spring-boot:run
```

### Production (Docker Compose)

```bash
# Tout-en-un
./start.sh

# Ou manuellement
docker-compose up -d
```

### Build JAR Standalone

```bash
# Compiler
mvn clean package

# Exécuter
java -jar target/variant-c-1.0.0.jar

# Avec profil personnalisé
java -jar target/variant-c-1.0.0.jar --spring.profiles.active=prod
```

---

## Checklist de Développement

### Ajout d'une Nouvelle Entité

- [ ] Créer la classe `@Entity` dans `entity/`
- [ ] Définir les champs avec annotations JPA
- [ ] Ajouter `@PrePersist`, `@PreUpdate` si nécessaire
- [ ] Créer le repository dans `repository/`
- [ ] Créer le controller dans `controller/`
- [ ] Tester avec curl/Postman
- [ ] Mettre à jour `database-init.sql`
- [ ] Documenter dans `API-TESTS.md`

### Ajout d'un Endpoint

- [ ] Ajouter la méthode dans le controller
- [ ] Annoter avec `@GetMapping`/`@PostMapping`/etc.
- [ ] Gérer les erreurs avec `ResponseEntity`
- [ ] Tester manuellement
- [ ] Ajouter des exemples curl dans `API-TESTS.md`

### Optimisation de Performance

- [ ] Activer les logs SQL: `spring.jpa.show-sql=true`
- [ ] Analyser les queries générées
- [ ] Vérifier le lazy loading (éviter N+1)
- [ ] Ajuster la taille du pool HikariCP
- [ ] Ajouter des index sur colonnes fréquemment filtrées
- [ ] Monitorer avec Prometheus/Grafana

---

## Conclusion

Cette structure de projet suit les conventions Spring Boot et les best practices Java:

- **Separation of Concerns**: Couches distinctes (Controller, Repository, Entity)
- **Dependency Injection**: Via constructeurs (@Autowired)
- **Convention over Configuration**: Minimal code pour maximum de fonctionnalités
- **Production-ready**: Monitoring, health checks, Docker
- **Scalable**: Pool de connexions, pagination, lazy loading
- **Maintainable**: Documentation complète, tests, scripts

Pour toute question, référez-vous aux documents:
- **Installation**: `README.md`
- **Architecture**: `ARCHITECTURE.md`
- **Tests API**: `API-TESTS.md`
