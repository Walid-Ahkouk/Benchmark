# Architecture de la Variante C

## Vue d'ensemble

La **Variante C** est une implémentation de benchmark de performance utilisant le stack **Spring Boot** avec une architecture REST classique. Cette variante se concentre sur les meilleures pratiques de Spring Framework et l'optimisation des performances avec JPA/Hibernate.

## Stack Technique

### Framework & Bibliothèques

- **Spring Boot 3.2.0**: Framework principal
- **Spring MVC**: Contrôleurs REST (`@RestController`)
- **Spring Data JPA**: Abstraction de persistance
- **Hibernate**: Implémentation ORM
- **HikariCP**: Pool de connexions (intégré par défaut)
- **PostgreSQL**: Base de données relationnelle
- **Spring Boot Actuator**: Monitoring et métriques
- **Micrometer**: Métriques avec export Prometheus

### Java & Build

- **Java 17**: Version LTS
- **Maven**: Gestion de dépendances et build

## Architecture en Couches

```
┌─────────────────────────────────────────┐
│         Controllers Layer               │
│   (CategoryController, ItemController)  │
│         @RestController                 │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│        Repository Layer                 │
│  (CategoryRepository, ItemRepository)   │
│         Spring Data JPA                 │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│          Entity Layer                   │
│      (Category, Item)                   │
│         JPA Entities                    │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         Database Layer                  │
│          PostgreSQL                     │
└─────────────────────────────────────────┘
```

## Structure des Packages

```
com.benchmark.variantc/
├── VariantCApplication.java        # Point d'entrée Spring Boot
├── entity/                         # Entités JPA
│   ├── Category.java               # Entité Catégorie
│   └── Item.java                   # Entité Item
├── repository/                     # Repositories Spring Data
│   ├── CategoryRepository.java     # Repository Catégorie
│   └── ItemRepository.java         # Repository Item
└── controller/                     # Contrôleurs REST
    ├── CategoryController.java     # API Catégories
    └── ItemController.java         # API Items
```

## Modèle de Données

### Entité Category

```java
@Entity
@Table(name = "categories")
public class Category {
    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String code;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "category")
    private List<Item> items;
}
```

**Caractéristiques:**
- Clé primaire auto-générée
- Code unique (index automatique)
- Timestamp auto-updaté (`@PreUpdate`)
- Relation bidirectionnelle vers Items

### Entité Item

```java
@Entity
@Table(name = "items")
public class Item {
    @Id @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String sku;

    @Column(nullable = false)
    private String name;

    @Column(precision = 10, scale = 2)
    private BigDecimal price;

    private Integer stock;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = LAZY)
    @JoinColumn(name = "category_id")
    private Category category;
}
```

**Caractéristiques:**
- SKU unique (index automatique)
- Prix en `BigDecimal` pour précision
- **Lazy Loading** pour la relation Category
- Foreign key nullable

### Relations JPA

**Item → Category (Many-to-One)**
```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "category_id")
private Category category;
```

**Avantages:**
- Chargement paresseux pour éviter N+1 queries
- Join explicite seulement quand nécessaire
- Optimisation des performances

**Category → Items (One-to-Many)**
```java
@OneToMany(mappedBy = "category", cascade = ALL, orphanRemoval = true)
private List<Item> items;
```

## Repositories (Spring Data JPA)

### CategoryRepository

```java
@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    Optional<Category> findByCode(String code);
    boolean existsByCode(String code);
}
```

**Méthodes héritées:**
- `findAll(Pageable)`: Pagination automatique
- `findById(Long)`: Recherche par ID
- `save(Category)`: Création/Mise à jour
- `deleteById(Long)`: Suppression
- `existsById(Long)`: Vérification d'existence

### ItemRepository

```java
@Repository
public interface ItemRepository extends JpaRepository<Item, Long> {
    Optional<Item> findBySku(String sku);
    boolean existsBySku(String sku);
    Page<Item> findByCategoryId(Long categoryId, Pageable pageable);
}
```

**Méthode clé:**
- `findByCategoryId()`: Filtrage relationnel avec pagination
- Génère automatiquement: `SELECT * FROM items WHERE category_id = ? LIMIT ? OFFSET ?`

## Contrôleurs REST

### Architecture des Endpoints

Tous les contrôleurs suivent le même pattern:

1. **Injection de dépendances** via constructeur
2. **Gestion des erreurs** avec ResponseEntity
3. **Support de pagination** via Pageable
4. **Validation** des contraintes d'unicité
5. **Réponses JSON standardisées**

### CategoryController

**Endpoints implémentés:**

| Méthode | Route | Description | Pagination |
|---------|-------|-------------|------------|
| GET | `/api/categories` | Liste toutes les catégories | ✓ |
| GET | `/api/categories/{id}` | Récupère une catégorie | - |
| POST | `/api/categories` | Crée une catégorie | - |
| PUT | `/api/categories/{id}` | Met à jour une catégorie | - |
| DELETE | `/api/categories/{id}` | Supprime une catégorie | - |
| GET | `/api/categories/{id}/items` | Items d'une catégorie | ✓ |

**Exemple de méthode:**

```java
@GetMapping
public ResponseEntity<Map<String, Object>> getAllCategories(Pageable pageable) {
    Page<Category> page = categoryRepository.findAll(pageable);

    Map<String, Object> response = new HashMap<>();
    response.put("categories", page.getContent());
    response.put("currentPage", page.getNumber());
    response.put("totalItems", page.getTotalElements());
    response.put("totalPages", page.getTotalPages());

    return ResponseEntity.ok(response);
}
```

### ItemController

**Endpoints implémentés:**

| Méthode | Route | Description | Filtrage |
|---------|-------|-------------|----------|
| GET | `/api/items` | Liste tous les items | CategoryId (optionnel) |
| GET | `/api/items/{id}` | Récupère un item | - |
| POST | `/api/items` | Crée un item | - |
| PUT | `/api/items/{id}` | Met à jour un item | - |
| DELETE | `/api/items/{id}` | Supprime un item | - |

**Filtrage par catégorie:**

```java
@GetMapping
public ResponseEntity<Map<String, Object>> getAllItems(
        @RequestParam(required = false) Long categoryId,
        Pageable pageable) {

    Page<Item> itemPage = (categoryId != null)
        ? itemRepository.findByCategoryId(categoryId, pageable)
        : itemRepository.findAll(pageable);

    // ...
}
```

## Pagination

### Utilisation de Pageable

Spring Data fournit l'interface `Pageable` pour la pagination:

**Paramètres de requête:**
- `page`: Numéro de page (commence à 0)
- `size`: Taille de la page (défaut: 20)
- `sort`: Tri (ex: `name,asc` ou `id,desc`)

**Exemple de requête:**
```
GET /api/items?page=0&size=10&sort=price,desc
```

**Réponse JSON:**
```json
{
  "items": [...],
  "currentPage": 0,
  "totalItems": 100,
  "totalPages": 10,
  "pageSize": 10
}
```

## Configuration de Performance

### HikariCP (Connection Pool)

Configuration optimale dans `application.properties`:

```properties
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000
```

**Métriques HikariCP exposées:**
- `hikari.connections.active`
- `hikari.connections.idle`
- `hikari.connections.pending`
- `hikari.connections.total`
- `hikari.connections.usage`

### Hibernate (JPA)

**Optimisations activées:**

```properties
# Batch processing
spring.jpa.properties.hibernate.jdbc.batch_size=20
spring.jpa.properties.hibernate.order_inserts=true
spring.jpa.properties.hibernate.order_updates=true

# Query optimization
spring.jpa.properties.hibernate.format_sql=false
spring.jpa.show-sql=false
```

### Lazy Loading

**Stratégie:**
- Relations `@ManyToOne` en **LAZY** par défaut
- Évite les N+1 queries
- Charge les données seulement si nécessaire

## Monitoring avec Actuator

### Endpoints exposés

```properties
management.endpoints.web.exposure.include=health,info,metrics,prometheus
```

**URLs disponibles:**
- `/actuator/health`: État de santé (DB, disk, ping)
- `/actuator/metrics`: Liste des métriques
- `/actuator/metrics/{metric}`: Métrique spécifique
- `/actuator/prometheus`: Export Prometheus

### Métriques personnalisées

**Métriques JVM:**
- `jvm.memory.used`
- `jvm.memory.max`
- `jvm.threads.live`
- `jvm.gc.pause`

**Métriques HTTP:**
- `http.server.requests` (count, duration)
- `http.server.requests.active`

**Métriques Database:**
- `hikari.connections.*`
- `jdbc.connections.*`

## Déploiement

### Docker Compose

L'application est déployable avec Docker Compose:

```yaml
services:
  postgres:    # Base de données
  app:         # Application Spring Boot
  prometheus:  # Collecte de métriques
  grafana:     # Visualisation
```

**Commandes:**
```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f app

# Arrêter
docker-compose down
```

### Build Maven

**Compilation:**
```bash
mvn clean package
```

**Exécution:**
```bash
java -jar target/variant-c-1.0.0.jar
```

## Comparaison avec d'autres Variantes

| Aspect | Variante C (Spring Boot) | Autres Variantes |
|--------|-------------------------|------------------|
| **Framework** | Spring Boot (full-stack) | Micronaut, Quarkus, etc. |
| **Configuration** | Annotations + Properties | Typesafe config, YAML |
| **Injection** | @Autowired / Constructor | DI frameworks variés |
| **ORM** | Spring Data JPA | Autres ORM ou SQL natif |
| **Monitoring** | Actuator + Micrometer | Custom ou autres libs |
| **Startup** | ~3-5s | Variable selon framework |

## Avantages de la Variante C

1. **Écosystème mature**: Documentation riche, communauté large
2. **Productivité**: Spring Data élimine le boilerplate SQL
3. **Monitoring intégré**: Actuator + Prometheus prêts à l'emploi
4. **Convention over configuration**: Peu de config manuelle
5. **Support entreprise**: VMware/Broadcom backing

## Points de Performance

### Optimisations clés

1. **HikariCP**: Pool de connexions le plus rapide
2. **Lazy Loading**: Évite les requêtes inutiles
3. **Batch Processing**: Réduit les roundtrips DB
4. **Pagination**: Limite les résultats chargés
5. **Indexes**: Code et SKU indexés automatiquement

### Limites connues

1. **Startup time**: ~3-5s (plus lent que Quarkus/Micronaut)
2. **Memory footprint**: ~150-200MB au repos
3. **Reflection overhead**: Annotations scannées au startup
4. **N+1 queries**: Possibles si lazy loading mal géré

## Conclusion

La **Variante C** représente une implémentation standard et robuste d'une API REST avec Spring Boot. Elle privilégie la productivité et la maintenabilité grâce aux conventions Spring, tout en offrant des performances solides grâce aux optimisations HikariCP et Hibernate.

Cette architecture est particulièrement adaptée pour:
- Applications d'entreprise avec équipes expérimentées en Spring
- Projets nécessitant un monitoring avancé
- Systèmes avec besoins de scalabilité horizontale
- Environnements où le time-to-market est critique
