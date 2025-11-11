# Diagrammes - Variante C

Visualisation de l'architecture et des flux de données.

---

## 1. Architecture Globale

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           CLIENT (Browser/curl)                          │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │ HTTP Request
                                   │ GET /api/items?categoryId=1
                                   ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                        SPRING BOOT APPLICATION                           │
│                            (Port 8080)                                   │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │              CONTROLLER LAYER (@RestController)                    │ │
│  │  ┌─────────────────────┐     ┌────────────────────────┐           │ │
│  │  │ CategoryController  │     │   ItemController       │           │ │
│  │  │ - getAllCategories()│     │ - getAllItems()        │           │ │
│  │  │ - getCategoryById() │     │ - getItemById()        │           │ │
│  │  │ - createCategory()  │     │ - createItem()         │           │ │
│  │  │ - updateCategory()  │     │ - updateItem()         │           │ │
│  │  │ - deleteCategory()  │     │ - deleteItem()         │           │ │
│  │  │ - getItemsByCat()   │     │                        │           │ │
│  │  └─────────────────────┘     └────────────────────────┘           │ │
│  └──────────────────┬───────────────────┬───────────────────────────────┘ │
│                     │                   │                                 │
│  ┌──────────────────┴───────────────────┴───────────────────────────────┐ │
│  │            REPOSITORY LAYER (Spring Data JPA)                        │ │
│  │  ┌─────────────────────────────┐  ┌──────────────────────────────┐  │ │
│  │  │   CategoryRepository        │  │     ItemRepository           │  │ │
│  │  │   extends JpaRepository     │  │     extends JpaRepository    │  │ │
│  │  │                             │  │                              │  │ │
│  │  │ - findAll(Pageable)         │  │ - findAll(Pageable)          │  │ │
│  │  │ - findById(Long)            │  │ - findById(Long)             │  │ │
│  │  │ - save(Category)            │  │ - save(Item)                 │  │ │
│  │  │ - deleteById(Long)          │  │ - deleteById(Long)           │  │ │
│  │  │ - findByCode(String)        │  │ - findBySku(String)          │  │ │
│  │  │ - existsByCode(String)      │  │ - existsBySku(String)        │  │ │
│  │  │                             │  │ - findByCategoryId(Long,     │  │ │
│  │  │                             │  │       Pageable) ⭐           │  │ │
│  │  └─────────────────────────────┘  └──────────────────────────────┘  │ │
│  └──────────────────┬───────────────────┬───────────────────────────────┘ │
│                     │                   │                                 │
│  ┌──────────────────┴───────────────────┴───────────────────────────────┐ │
│  │                 ENTITY LAYER (JPA Entities)                          │ │
│  │  ┌──────────────────────┐         ┌───────────────────────────┐     │ │
│  │  │    Category          │         │         Item              │     │ │
│  │  │  @Entity             │ 1     ∞ │       @Entity             │     │ │
│  │  │                      │◄────────┤                           │     │ │
│  │  │ - id: Long           │         │ - id: Long                │     │ │
│  │  │ - code: String       │         │ - sku: String             │     │ │
│  │  │ - name: String       │         │ - name: String            │     │ │
│  │  │ - updatedAt: DateTime│         │ - price: BigDecimal       │     │ │
│  │  │ - items: List<Item>  │         │ - stock: Integer          │     │ │
│  │  │   @OneToMany         │         │ - updatedAt: DateTime     │     │ │
│  │  │                      │         │ - category: Category      │     │ │
│  │  │                      │         │   @ManyToOne(LAZY)        │     │ │
│  │  └──────────────────────┘         └───────────────────────────┘     │ │
│  └──────────────────┬───────────────────┬───────────────────────────────┘ │
│                     │                   │                                 │
│  ┌──────────────────┴───────────────────┴───────────────────────────────┐ │
│  │                  HIBERNATE (ORM Layer)                               │ │
│  │  - SQL Generation                                                    │ │
│  │  - Entity Mapping (ResultSet → Objects)                             │ │
│  │  - Lazy Loading (CGLIB Proxies)                                     │ │
│  │  - Batch Processing (20 statements/batch)                           │ │
│  │  - Second Level Cache (disabled by default)                         │ │
│  └──────────────────┬───────────────────────────────────────────────────┘ │
│                     │                                                     │
│  ┌──────────────────┴─────────────────────────────────────────────────┐ │
│  │              HIKARICP (Connection Pool)                             │ │
│  │  - Maximum Pool Size: 20                                            │ │
│  │  - Minimum Idle: 5                                                  │ │
│  │  - Connection Timeout: 30s                                          │ │
│  │  - Idle Timeout: 10 min                                             │ │
│  │  - Max Lifetime: 30 min                                             │ │
│  └──────────────────┬─────────────────────────────────────────────────┘ │
└────────────────────┬┴──────────────────────────────────────────────────┘
                     │ JDBC
                     ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                       PostgreSQL DATABASE                                │
│                           (Port 5432)                                    │
│  ┌────────────────────────┐         ┌────────────────────────────┐     │
│  │  Table: categories     │         │    Table: items            │     │
│  │  ┌──────────────────┐  │         │  ┌──────────────────────┐  │     │
│  │  │ id (BIGSERIAL PK)│  │         │  │ id (BIGSERIAL PK)    │  │     │
│  │  │ code (VARCHAR)   │  │         │  │ sku (VARCHAR UNIQUE) │  │     │
│  │  │ name (VARCHAR)   │  │         │  │ name (VARCHAR)       │  │     │
│  │  │ updated_at (TS)  │  │         │  │ price (DECIMAL)      │  │     │
│  │  └──────────────────┘  │         │  │ stock (INTEGER)      │  │     │
│  │  Index: idx_code       │         │  │ updated_at (TS)      │  │     │
│  └────────────────────────┘         │  │ category_id (FK)     │  │     │
│                                     │  └──────────────────────┘  │     │
│                                     │  Index: idx_sku            │     │
│                                     │  Index: idx_category_id    │     │
│                                     └────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                      MONITORING & METRICS                                │
│  ┌────────────────┐  ┌──────────────┐  ┌──────────────────────────┐    │
│  │   Actuator     │  │  Prometheus  │  │       Grafana            │    │
│  │  (Port 8080)   │→ │  (Port 9090) │→ │      (Port 3000)         │    │
│  │                │  │              │  │                          │    │
│  │ /health        │  │  Scrapes     │  │  Dashboards with:        │    │
│  │ /metrics       │  │  every 10s   │  │  - HikariCP metrics      │    │
│  │ /prometheus    │  │              │  │  - JVM metrics           │    │
│  └────────────────┘  └──────────────┘  │  - HTTP request metrics  │    │
│                                        └──────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Flux de Requête HTTP

### GET /api/items?categoryId=1&page=0&size=10

```
┌─────────┐
│ Client  │
└────┬────┘
     │
     │ 1. HTTP GET Request
     │    /api/items?categoryId=1&page=0&size=10
     ↓
┌────────────────────┐
│  Tomcat Server     │
│  (Port 8080)       │
└────┬───────────────┘
     │
     │ 2. Route to Controller
     ↓
┌────────────────────────────────────────┐
│  ItemController                        │
│  @GetMapping                           │
│  getAllItems(                          │
│    @RequestParam Long categoryId,      │
│    Pageable pageable                   │
│  )                                     │
└────┬───────────────────────────────────┘
     │
     │ 3. Parse query parameters
     │    categoryId = 1
     │    pageable = {page: 0, size: 10}
     ↓
┌────────────────────────────────────────┐
│  Conditional Logic                     │
│  if (categoryId != null)               │
│    → itemRepository.findByCategoryId() │
│  else                                  │
│    → itemRepository.findAll()          │
└────┬───────────────────────────────────┘
     │
     │ 4. Call repository method
     ↓
┌────────────────────────────────────────┐
│  ItemRepository                        │
│  findByCategoryId(1, pageable)         │
└────┬───────────────────────────────────┘
     │
     │ 5. Spring Data JPA generates query
     ↓
┌────────────────────────────────────────┐
│  Hibernate Query Generator             │
│  SELECT * FROM items                   │
│  WHERE category_id = ?                 │
│  LIMIT 10 OFFSET 0                     │
└────┬───────────────────────────────────┘
     │
     │ 6. Get connection from pool
     ↓
┌────────────────────────────────────────┐
│  HikariCP                              │
│  - Check for idle connection           │
│  - Validate connection                 │
│  - Return connection                   │
└────┬───────────────────────────────────┘
     │
     │ 7. Execute SQL query
     ↓
┌────────────────────────────────────────┐
│  PostgreSQL                            │
│  - Use index idx_category_id           │
│  - Fetch 10 rows where category_id=1   │
│  - Return ResultSet                    │
└────┬───────────────────────────────────┘
     │
     │ 8. Map ResultSet to entities
     ↓
┌────────────────────────────────────────┐
│  Hibernate Entity Mapper               │
│  ResultSet → List<Item>                │
│  - Create Item objects                 │
│  - Populate fields                     │
│  - Create Category proxies (LAZY)      │
└────┬───────────────────────────────────┘
     │
     │ 9. Return connection to pool
     ↓
┌────────────────────────────────────────┐
│  HikariCP                              │
│  - Mark connection as idle             │
│  - Ready for next request              │
└────┬───────────────────────────────────┘
     │
     │ 10. Wrap in Page<Item>
     ↓
┌────────────────────────────────────────┐
│  Spring Data Pagination                │
│  Page {                                │
│    content: List<Item>,                │
│    number: 0,                          │
│    size: 10,                           │
│    totalElements: 100,                 │
│    totalPages: 10                      │
│  }                                     │
└────┬───────────────────────────────────┘
     │
     │ 11. Build response Map
     ↓
┌────────────────────────────────────────┐
│  ItemController                        │
│  Map<String, Object> {                 │
│    "items": [...],                     │
│    "currentPage": 0,                   │
│    "totalItems": 100,                  │
│    "totalPages": 10,                   │
│    "categoryId": 1                     │
│  }                                     │
└────┬───────────────────────────────────┘
     │
     │ 12. Serialize to JSON
     ↓
┌────────────────────────────────────────┐
│  Jackson JSON Serializer               │
│  - Convert Map to JSON                 │
│  - Handle LocalDateTime format         │
│  - Handle BigDecimal format            │
└────┬───────────────────────────────────┘
     │
     │ 13. HTTP Response 200 OK
     ↓
┌─────────┐
│ Client  │ Receives JSON response
└─────────┘
```

**Temps total estimé**: 10-50ms (selon charge DB)

---

## 3. Relations JPA

```
┌───────────────────────────────────────────────────────────────┐
│                        RELATIONS JPA                          │
└───────────────────────────────────────────────────────────────┘

Category (Parent)                              Item (Child)
┌─────────────────────────┐                  ┌──────────────────────────┐
│ @Entity                 │                  │ @Entity                  │
│ @Table("categories")    │                  │ @Table("items")          │
├─────────────────────────┤                  ├──────────────────────────┤
│ @Id                     │                  │ @Id                      │
│ - id: Long              │                  │ - id: Long               │
│                         │                  │                          │
│ - code: String          │                  │ - sku: String            │
│ - name: String          │                  │ - name: String           │
│ - updatedAt: DateTime   │                  │ - price: BigDecimal      │
│                         │                  │ - stock: Integer         │
│ @OneToMany              │  1           ∞   │ - updatedAt: DateTime    │
│ - items: List<Item> ◄───┼──────────────────┼─► category: Category     │
│   (mappedBy="category") │                  │   @ManyToOne(LAZY)       │
│   (cascade = ALL)       │                  │   @JoinColumn            │
│   (orphanRemoval=true)  │                  │   ("category_id")        │
└─────────────────────────┘                  └──────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    DATABASE REPRESENTATION                          │
└─────────────────────────────────────────────────────────────────────┘

Table: categories                      Table: items
┌──────────────────┐                  ┌──────────────────────┐
│ id (PK)          │                  │ id (PK)              │
│ code (UNIQUE)    │                  │ sku (UNIQUE)         │
│ name             │                  │ name                 │
│ updated_at       │                  │ price                │
└──────────────────┘                  │ stock                │
                                      │ updated_at           │
                                      │ category_id (FK) ────┐
                                      └──────────────────────┘
                                               │
                                               │ FOREIGN KEY
                                               │ REFERENCES
                                               │ categories(id)
                                               │ ON DELETE SET NULL
                                               ↓
                                      ┌──────────────────┐
                                      │ categories       │
                                      └──────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     LAZY LOADING BEHAVIOR                           │
└─────────────────────────────────────────────────────────────────────┘

When fetching an Item:

1. Initial Query:
   SELECT * FROM items WHERE id = 1

2. Item object created:
   Item {
     id: 1,
     sku: "ELEC-001",
     name: "Gaming Laptop",
     price: 1299.99,
     stock: 50,
     category: <CGLIB Proxy>  ← NOT LOADED YET!
   }

3. Only when accessing item.getCategory().getName():
   SELECT * FROM categories WHERE id = ?

   Now category is loaded:
   Item {
     ...
     category: Category {
       id: 1,
       code: "ELEC",
       name: "Electronics"
     }
   }

Benefits:
✓ Avoids unnecessary joins
✓ Reduces initial query complexity
✓ Loads data on-demand
✗ Risk of N+1 queries if not careful
```

---

## 4. Architecture Docker Compose

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DOCKER COMPOSE STACK                             │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    Docker Network: benchmark-network                │
│                                                                     │
│  ┌────────────────────┐       ┌────────────────────────────┐       │
│  │   Container:       │       │   Container:               │       │
│  │   postgres         │       │   app                      │       │
│  │                    │       │                            │       │
│  │ Image:             │       │ Build:                     │       │
│  │ postgres:15-alpine │       │ ./Dockerfile               │       │
│  │                    │       │                            │       │
│  │ Environment:       │       │ Environment:               │       │
│  │ - POSTGRES_DB      │       │ - SPRING_DATASOURCE_URL    │       │
│  │ - POSTGRES_USER    │       │ - SPRING_DATASOURCE_USER   │       │
│  │ - POSTGRES_PASS    │       │ - SPRING_DATASOURCE_PASS   │       │
│  │                    │       │                            │       │
│  │ Port: 5432         │◄──────┤ Depends on:                │       │
│  │                    │ JDBC  │ postgres (healthy)         │       │
│  │ Volumes:           │       │                            │       │
│  │ - postgres_data    │       │ Port: 8080                 │       │
│  │ - ./init.sql       │       │                            │       │
│  │                    │       │ Healthcheck:               │       │
│  │ Healthcheck:       │       │ /actuator/health           │       │
│  │ pg_isready         │       │                            │       │
│  └────────────────────┘       └────────────┬───────────────┘       │
│                                            │ Metrics              │
│                                            │ HTTP                 │
│  ┌────────────────────┐                    │                      │
│  │   Container:       │                    │                      │
│  │   prometheus       │◄───────────────────┘                      │
│  │                    │ Scrape                                    │
│  │ Image:             │ /actuator/prometheus                      │
│  │ prom/prometheus    │ every 10s                                 │
│  │                    │                                           │
│  │ Config:            │                                           │
│  │ ./prometheus.yml   │                                           │
│  │                    │                                           │
│  │ Port: 9090         │                                           │
│  │                    │                                           │
│  │ Volumes:           │                                           │
│  │ - prometheus_data  │                                           │
│  └────────┬───────────┘                                           │
│           │ Metrics                                               │
│           │ PromQL                                                │
│           ↓                                                       │
│  ┌────────────────────┐                                           │
│  │   Container:       │                                           │
│  │   grafana          │                                           │
│  │                    │                                           │
│  │ Image:             │                                           │
│  │ grafana/grafana    │                                           │
│  │                    │                                           │
│  │ Port: 3000         │                                           │
│  │                    │                                           │
│  │ Credentials:       │                                           │
│  │ admin/admin        │                                           │
│  │                    │                                           │
│  │ Volumes:           │                                           │
│  │ - grafana_data     │                                           │
│  └────────────────────┘                                           │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

Host Ports Mapping:
- 5432  → postgres:5432   (PostgreSQL)
- 8080  → app:8080        (Spring Boot API)
- 9090  → prometheus:9090 (Prometheus UI)
- 3000  → grafana:3000    (Grafana UI)

Persistent Volumes:
- postgres_data    (Database files)
- prometheus_data  (Metrics history)
- grafana_data     (Dashboards & settings)
```

---

## 5. Pagination Flow

```
┌──────────────────────────────────────────────────────────────────┐
│               PAGINATION REQUEST FLOW                            │
└──────────────────────────────────────────────────────────────────┘

Client Request:
GET /api/items?page=2&size=10&sort=price,desc

     ↓

┌────────────────────────────────────────────────────────────────┐
│  Spring MVC Parameter Resolver                                 │
│  Converts query params → Pageable object                       │
│                                                                │
│  Pageable pageable = PageRequest.of(                           │
│    page: 2,                 // 0-indexed                       │
│    size: 10,                // items per page                  │
│    sort: Sort.by(           // sort criteria                   │
│      Direction.DESC,                                           │
│      "price"                                                   │
│    )                                                           │
│  );                                                            │
└────────────────────┬───────────────────────────────────────────┘
                     │
                     ↓
┌────────────────────────────────────────────────────────────────┐
│  Repository Method                                             │
│  Page<Item> findAll(Pageable pageable)                         │
└────────────────────┬───────────────────────────────────────────┘
                     │
                     ↓
┌────────────────────────────────────────────────────────────────┐
│  Spring Data JPA Query Generation                              │
│                                                                │
│  1. Count Query:                                               │
│     SELECT COUNT(*) FROM items                                 │
│     → totalElements = 100                                      │
│                                                                │
│  2. Data Query:                                                │
│     SELECT * FROM items                                        │
│     ORDER BY price DESC                                        │
│     LIMIT 10 OFFSET 20  ← (page 2 × size 10)                  │
│     → Returns 10 items                                         │
└────────────────────┬───────────────────────────────────────────┘
                     │
                     ↓
┌────────────────────────────────────────────────────────────────┐
│  Page Object Construction                                      │
│                                                                │
│  Page<Item> {                                                  │
│    content: [Item11, Item12, ..., Item20],  // 10 items       │
│    pageable: {                                                 │
│      pageNumber: 2,                                            │
│      pageSize: 10,                                             │
│      offset: 20,                                               │
│      sort: {                                                   │
│        orders: [{property: "price", direction: "DESC"}]        │
│      }                                                         │
│    },                                                          │
│    totalElements: 100,   // from COUNT query                   │
│    totalPages: 10,       // calculated: totalElements/size     │
│    number: 2,            // current page                       │
│    size: 10,             // page size                          │
│    first: false,         // not first page                     │
│    last: false,          // not last page                      │
│    hasNext: true,        // has page 3                         │
│    hasPrevious: true     // has page 1                         │
│  }                                                             │
└────────────────────┬───────────────────────────────────────────┘
                     │
                     ↓
┌────────────────────────────────────────────────────────────────┐
│  Controller Response Mapping                                   │
│                                                                │
│  Map<String, Object> {                                         │
│    "items": page.getContent(),                                 │
│    "currentPage": page.getNumber(),                            │
│    "totalItems": page.getTotalElements(),                      │
│    "totalPages": page.getTotalPages(),                         │
│    "pageSize": page.getSize()                                  │
│  }                                                             │
└────────────────────┬───────────────────────────────────────────┘
                     │
                     ↓ JSON

Client receives:
{
  "items": [
    {"id": 11, "sku": "...", "price": 499.99, ...},
    {"id": 12, "sku": "...", "price": 449.99, ...},
    ...
  ],
  "currentPage": 2,
  "totalItems": 100,
  "totalPages": 10,
  "pageSize": 10
}
```

---

## 6. Monitoring & Metrics Flow

```
┌────────────────────────────────────────────────────────────────┐
│                  METRICS COLLECTION FLOW                        │
└────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Spring Boot Application (Port 8080)                    │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Application Code                                 │  │
│  │  - HTTP Requests                                  │  │
│  │  - Database Queries                               │  │
│  │  - Business Logic                                 │  │
│  └───────────────┬───────────────────────────────────┘  │
│                  │ Events & Metrics                     │
│                  ↓                                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Micrometer (Metrics Facade)                      │  │
│  │  - Collects metrics from:                         │  │
│  │    * HikariCP (connection pool)                   │  │
│  │    * JVM (memory, threads, GC)                    │  │
│  │    * Tomcat (requests, sessions)                  │  │
│  │    * HTTP (request count, duration)               │  │
│  │    * Custom application metrics                   │  │
│  └───────────────┬───────────────────────────────────┘  │
│                  │                                       │
│                  ↓                                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Actuator Endpoints                               │  │
│  │                                                   │  │
│  │  /actuator/health                                 │  │
│  │  /actuator/metrics                                │  │
│  │  /actuator/prometheus  ← Prometheus format        │  │
│  └───────────────┬───────────────────────────────────┘  │
└──────────────────┼──────────────────────────────────────┘
                   │ HTTP GET every 10s
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│  Prometheus (Port 9090)                                 │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Scraper                                          │  │
│  │  - Fetches /actuator/prometheus every 10s        │  │
│  │  - Parses metrics in Prometheus format           │  │
│  └───────────────┬───────────────────────────────────┘  │
│                  ↓                                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Time-Series Database (TSDB)                      │  │
│  │  - Stores metrics with timestamps                 │  │
│  │  - Retention: configurable (default 15 days)      │  │
│  │                                                   │  │
│  │  Example data:                                    │  │
│  │  hikari_connections_active{pool="Hikari"} 5       │  │
│  │  http_server_requests_total{uri="/api/items"} 120│  │
│  │  jvm_memory_used_bytes{area="heap"} 157286400    │  │
│  └───────────────┬───────────────────────────────────┘  │
│                  │                                       │
│  ┌───────────────┴───────────────────────────────────┐  │
│  │  PromQL Query Engine                              │  │
│  │  - Aggregation functions (sum, avg, rate)         │  │
│  │  - Time-based queries                             │  │
│  │  - Alerting rules (optional)                      │  │
│  └───────────────┬───────────────────────────────────┘  │
└──────────────────┼──────────────────────────────────────┘
                   │ PromQL Queries
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│  Grafana (Port 3000)                                    │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Data Source: Prometheus                          │  │
│  │  URL: http://prometheus:9090                      │  │
│  └───────────────┬───────────────────────────────────┘  │
│                  ↓                                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Dashboards                                       │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │ Panel: Active Connections                   │  │  │
│  │  │ Query: hikari_connections_active             │  │  │
│  │  │ Graph: Line chart over time                  │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │ Panel: Request Rate                         │  │  │
│  │  │ Query: rate(http_server_requests[5m])       │  │  │
│  │  │ Graph: Bar chart                             │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │ Panel: JVM Heap Usage                       │  │  │
│  │  │ Query: jvm_memory_used_bytes{area="heap"}   │  │  │
│  │  │ Graph: Gauge                                 │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                   ↓
              User Views
         Beautiful Dashboards!
```

**Key Metrics Available:**

1. **HikariCP**:
   - `hikari.connections.active`
   - `hikari.connections.idle`
   - `hikari.connections.total`
   - `hikari.connections.pending`

2. **HTTP**:
   - `http.server.requests` (count, duration)
   - By status, URI, method

3. **JVM**:
   - `jvm.memory.used`
   - `jvm.threads.live`
   - `jvm.gc.pause`

4. **Database**:
   - `jdbc.connections.active`
   - Query execution times

---

## 7. Request Lifecycle Timeline

```
Time →

0ms    │ Client sends HTTP request
       │ GET /api/items?categoryId=1&page=0&size=10
       ↓
2ms    │ Tomcat receives request
       │ → DispatcherServlet
       ↓
4ms    │ Spring MVC routes to ItemController
       │ → Resolves Pageable parameter
       ↓
6ms    │ Controller calls repository
       │ → itemRepository.findByCategoryId(1, pageable)
       ↓
8ms    │ Spring Data JPA generates queries
       │ → COUNT query + SELECT query
       ↓
10ms   │ HikariCP provides connection
       │ → Connection retrieved from pool (2ms)
       ↓
15ms   │ PostgreSQL executes COUNT query
       │ → Uses index, returns total=10
       ↓
25ms   │ PostgreSQL executes SELECT query
       │ → Uses index on category_id
       │ → Fetches 10 rows
       │ → Returns ResultSet
       ↓
35ms   │ Hibernate maps ResultSet → List<Item>
       │ → Creates 10 Item objects
       │ → Creates Category proxies (LAZY, not fetched)
       ↓
37ms   │ HikariCP returns connection to pool
       ↓
40ms   │ Spring Data creates Page<Item>
       │ → Wraps items with pagination metadata
       ↓
42ms   │ Controller builds response Map
       │ → Adds items, currentPage, totalItems, etc.
       ↓
45ms   │ Jackson serializes Map → JSON
       │ → Converts LocalDateTime to ISO-8601
       │ → Converts BigDecimal to string
       ↓
48ms   │ Tomcat sends HTTP response
       │ → Status 200 OK
       │ → Content-Type: application/json
       ↓
50ms   │ Client receives response
       │ ✓ Request completed

┌──────────────────────────────────────────────────────────┐
│  Total Time: ~50ms (typical for indexed query)          │
│                                                          │
│  Breakdown:                                              │
│  - Network/Routing:    10ms (20%)                        │
│  - Database Query:     20ms (40%)                        │
│  - ORM Mapping:        10ms (20%)                        │
│  - JSON Serialization: 10ms (20%)                        │
└──────────────────────────────────────────────────────────┘
```

---

Ces diagrammes fournissent une visualisation complète de l'architecture et des flux de données de la Variante C!
