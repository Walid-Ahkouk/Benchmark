# Variante C - Spring Boot Performance Benchmark

Application de benchmark de performance utilisant Spring Boot, Spring MVC, Spring Data JPA et PostgreSQL.

## Stack Technique

- **Framework**: Spring Boot 3.2.0
- **API REST**: Spring MVC (`@RestController`)
- **ORM**: Spring Data JPA avec Hibernate
- **Base de données**: PostgreSQL
- **Connection Pool**: HikariCP
- **Monitoring**: Spring Boot Actuator + Prometheus
- **Build Tool**: Maven
- **Java Version**: 17

## Structure du Projet

```
V-C/
├── pom.xml
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── benchmark/
│       │           └── variantc/
│       │               ├── VariantCApplication.java
│       │               ├── entity/
│       │               │   ├── Category.java
│       │               │   └── Item.java
│       │               ├── repository/
│       │               │   ├── CategoryRepository.java
│       │               │   └── ItemRepository.java
│       │               └── controller/
│       │                   ├── CategoryController.java
│       │                   └── ItemController.java
│       └── resources/
│           └── application.properties
```

## Configuration de la Base de Données

### Prérequis PostgreSQL

Créez une base de données PostgreSQL avec les commandes suivantes :

```sql
CREATE DATABASE benchmark_db;
CREATE USER benchmark_user WITH PASSWORD 'benchmark_pass';
GRANT ALL PRIVILEGES ON DATABASE benchmark_db TO benchmark_user;
```

### Configuration HikariCP

Le pool de connexions HikariCP est configuré dans `application.properties` :

- **Maximum Pool Size**: 20 connexions
- **Minimum Idle**: 5 connexions
- **Connection Timeout**: 30 secondes
- **Idle Timeout**: 10 minutes
- **Max Lifetime**: 30 minutes

## Compilation et Exécution

### 1. Compiler le projet

```bash
cd V-C
mvn clean install
```

### 2. Lancer l'application

```bash
mvn spring-boot:run
```

Ou avec le JAR compilé :

```bash
java -jar target/variant-c-1.0.0.jar
```

L'application démarre sur le port **8080**.

## Endpoints API

### Categories

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/categories` | Liste paginée des catégories |
| GET | `/api/categories/{id}` | Récupérer une catégorie |
| POST | `/api/categories` | Créer une catégorie |
| PUT | `/api/categories/{id}` | Mettre à jour une catégorie |
| DELETE | `/api/categories/{id}` | Supprimer une catégorie |
| GET | `/api/categories/{id}/items` | Items d'une catégorie (paginé) |

### Items

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/items` | Liste paginée des items |
| GET | `/api/items?categoryId={id}` | Items filtrés par catégorie |
| GET | `/api/items/{id}` | Récupérer un item |
| POST | `/api/items` | Créer un item |
| PUT | `/api/items/{id}` | Mettre à jour un item |
| DELETE | `/api/items/{id}` | Supprimer un item |

### Pagination

Tous les endpoints de liste supportent la pagination avec les paramètres :

- `page`: Numéro de page (commence à 0)
- `size`: Taille de la page (par défaut: 20)
- `sort`: Tri (ex: `name,asc` ou `id,desc`)

**Exemple:**
```bash
GET /api/categories?page=0&size=10&sort=name,asc
```

## Exemples d'Utilisation

### Créer une Catégorie

```bash
curl -X POST http://localhost:8080/api/categories \
  -H "Content-Type: application/json" \
  -d '{
    "code": "ELEC",
    "name": "Electronics"
  }'
```

### Créer un Item

```bash
curl -X POST http://localhost:8080/api/items \
  -H "Content-Type: application/json" \
  -d '{
    "sku": "LAPTOP-001",
    "name": "Gaming Laptop",
    "price": 1299.99,
    "stock": 50,
    "categoryId": 1
  }'
```

### Récupérer les Items d'une Catégorie

```bash
curl "http://localhost:8080/api/categories/1/items?page=0&size=10"
```

### Filtrer les Items par Catégorie

```bash
curl "http://localhost:8080/api/items?categoryId=1&page=0&size=20"
```

## Monitoring et Métriques

### Endpoints Actuator

- **Health**: `http://localhost:8080/actuator/health`
- **Info**: `http://localhost:8080/actuator/info`
- **Metrics**: `http://localhost:8080/actuator/metrics`
- **Prometheus**: `http://localhost:8080/actuator/prometheus`

### Métriques Prometheus

L'application exporte automatiquement les métriques suivantes :

- Métriques JVM (heap, threads, GC)
- Métriques système (CPU, mémoire)
- Métriques Tomcat (sessions, requêtes)
- Métriques HikariCP (connexions actives, idle, waiting)
- Métriques custom Spring Boot

**Exemple de scraping Prometheus:**

```yaml
scrape_configs:
  - job_name: 'variant-c-benchmark'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['localhost:8080']
```

## Modèle de Données

### Entity: Category

```java
@Entity
@Table(name = "categories")
public class Category {
    @Id @GeneratedValue
    private Long id;

    @Column(unique = true)
    private String code;

    private String name;
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "category")
    private List<Item> items;
}
```

### Entity: Item

```java
@Entity
@Table(name = "items")
public class Item {
    @Id @GeneratedValue
    private Long id;

    @Column(unique = true)
    private String sku;

    private String name;
    private BigDecimal price;
    private Integer stock;
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = LAZY)
    @JoinColumn(name = "category_id")
    private Category category;
}
```

## Relations JPA

- **Item → Category**: `@ManyToOne(fetch = LAZY)` - Chargement paresseux pour optimiser les performances
- **Category → Items**: `@OneToMany(mappedBy = "category")` - Relation bidirectionnelle

## Tests de Performance

### Test de Charge avec curl

```bash
# Test de pagination intensive
for i in {1..100}; do
  curl "http://localhost:8080/api/items?page=$i&size=50" > /dev/null 2>&1
done

# Test de filtrage relationnel
for i in {1..50}; do
  curl "http://localhost:8080/api/items?categoryId=$((i % 10 + 1))&page=0&size=20" > /dev/null 2>&1
done
```

### Monitoring pendant les Tests

```bash
# Observer les métriques Prometheus
watch -n 1 'curl -s http://localhost:8080/actuator/metrics/hikari.connections.active | jq .'

# Observer la santé de l'application
watch -n 1 'curl -s http://localhost:8080/actuator/health | jq .'
```

## Optimisations Implémentées

1. **Connection Pooling**: HikariCP avec configuration optimisée
2. **Lazy Loading**: Relations `@ManyToOne` avec `FETCH = LAZY`
3. **Batch Processing**: Hibernate batch inserts/updates activé
4. **Pagination**: Utilisation de `Pageable` pour limiter les résultats
5. **Indexation**: Colonnes `code` et `sku` avec contrainte `unique`
6. **Lifecycle Callbacks**: Auto-update de `updated_at` avec `@PreUpdate`

## Troubleshooting

### Problème de Connexion à PostgreSQL

Vérifiez que PostgreSQL est démarré et accessible :

```bash
psql -U benchmark_user -d benchmark_db -h localhost -p 5432
```

### Modifier la Configuration de la Base

Éditez `src/main/resources/application.properties` :

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/benchmark_db
spring.datasource.username=benchmark_user
spring.datasource.password=benchmark_pass
```

### Logs de Débogage

Pour activer les logs SQL détaillés :

```properties
spring.jpa.show-sql=true
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
```

## Licence

MIT
