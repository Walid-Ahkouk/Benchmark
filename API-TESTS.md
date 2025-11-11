# Tests API - Variante C

Ce document contient des exemples de requêtes pour tester tous les endpoints de l'API.

## Variables d'environnement

```bash
export API_URL="http://localhost:8080"
```

---

## 1. Tests des Endpoints Category

### 1.1 GET /api/categories (Liste paginée)

**Récupérer la première page (10 catégories)**
```bash
curl -X GET "${API_URL}/api/categories?page=0&size=10" \
  -H "Content-Type: application/json" | jq
```

**Avec tri par nom (ascendant)**
```bash
curl -X GET "${API_URL}/api/categories?page=0&size=10&sort=name,asc" \
  -H "Content-Type: application/json" | jq
```

**Avec tri par code (descendant)**
```bash
curl -X GET "${API_URL}/api/categories?page=0&size=5&sort=code,desc" \
  -H "Content-Type: application/json" | jq
```

**Réponse attendue:**
```json
{
  "categories": [
    {
      "id": 1,
      "code": "ELEC",
      "name": "Electronics",
      "updatedAt": "2025-01-15T10:30:00"
    }
  ],
  "currentPage": 0,
  "totalItems": 10,
  "totalPages": 1,
  "pageSize": 10
}
```

---

### 1.2 GET /api/categories/{id} (Récupérer une catégorie)

**Récupérer la catégorie avec ID 1**
```bash
curl -X GET "${API_URL}/api/categories/1" \
  -H "Content-Type: application/json" | jq
```

**Tester avec un ID inexistant (404)**
```bash
curl -X GET "${API_URL}/api/categories/999" \
  -H "Content-Type: application/json" -i
```

**Réponse attendue (succès):**
```json
{
  "id": 1,
  "code": "ELEC",
  "name": "Electronics",
  "updatedAt": "2025-01-15T10:30:00"
}
```

---

### 1.3 POST /api/categories (Créer une catégorie)

**Créer une nouvelle catégorie**
```bash
curl -X POST "${API_URL}/api/categories" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "GAMING",
    "name": "Gaming Equipment"
  }' | jq
```

**Tester la contrainte d'unicité (conflict 409)**
```bash
curl -X POST "${API_URL}/api/categories" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "ELEC",
    "name": "Duplicate Code"
  }' -i
```

**Réponse attendue (201 Created):**
```json
{
  "id": 11,
  "code": "GAMING",
  "name": "Gaming Equipment",
  "updatedAt": "2025-01-15T11:00:00"
}
```

---

### 1.4 PUT /api/categories/{id} (Mettre à jour)

**Mettre à jour le nom d'une catégorie**
```bash
curl -X PUT "${API_URL}/api/categories/11" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "GAMING",
    "name": "Gaming & Esports"
  }' | jq
```

**Mettre à jour uniquement le code**
```bash
curl -X PUT "${API_URL}/api/categories/11" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "GAME"
  }' | jq
```

**Tester avec ID inexistant (404)**
```bash
curl -X PUT "${API_URL}/api/categories/999" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Non-existent"
  }' -i
```

---

### 1.5 DELETE /api/categories/{id} (Supprimer)

**Supprimer une catégorie**
```bash
curl -X DELETE "${API_URL}/api/categories/11" -i
```

**Vérifier la suppression (404)**
```bash
curl -X GET "${API_URL}/api/categories/11" -i
```

**Réponse attendue (204 No Content):**
```
HTTP/1.1 204 No Content
```

---

### 1.6 GET /api/categories/{id}/items (Items d'une catégorie)

**Récupérer les items de la catégorie Electronics (ID=1)**
```bash
curl -X GET "${API_URL}/api/categories/1/items?page=0&size=10" \
  -H "Content-Type: application/json" | jq
```

**Avec tri par prix (descendant)**
```bash
curl -X GET "${API_URL}/api/categories/1/items?page=0&size=5&sort=price,desc" \
  -H "Content-Type: application/json" | jq
```

**Pagination de la deuxième page**
```bash
curl -X GET "${API_URL}/api/categories/1/items?page=1&size=5" \
  -H "Content-Type: application/json" | jq
```

**Réponse attendue:**
```json
{
  "items": [
    {
      "id": 1,
      "sku": "ELEC-001",
      "name": "Gaming Laptop 15\"",
      "price": 1299.99,
      "stock": 50,
      "updatedAt": "2025-01-15T10:30:00"
    }
  ],
  "currentPage": 0,
  "totalItems": 10,
  "totalPages": 2,
  "pageSize": 5,
  "categoryId": 1
}
```

---

## 2. Tests des Endpoints Item

### 2.1 GET /api/items (Liste paginée)

**Récupérer tous les items (première page)**
```bash
curl -X GET "${API_URL}/api/items?page=0&size=20" \
  -H "Content-Type: application/json" | jq
```

**Avec tri par prix (ascendant)**
```bash
curl -X GET "${API_URL}/api/items?page=0&size=10&sort=price,asc" \
  -H "Content-Type: application/json" | jq
```

**Avec tri par nom**
```bash
curl -X GET "${API_URL}/api/items?page=0&size=10&sort=name,asc" \
  -H "Content-Type: application/json" | jq
```

---

### 2.2 GET /api/items?categoryId={id} (Filtrer par catégorie)

**Récupérer les items de la catégorie Electronics (ID=1)**
```bash
curl -X GET "${API_URL}/api/items?categoryId=1&page=0&size=10" \
  -H "Content-Type: application/json" | jq
```

**Filtrer par catégorie Books (ID=3) avec pagination**
```bash
curl -X GET "${API_URL}/api/items?categoryId=3&page=0&size=5&sort=price,desc" \
  -H "Content-Type: application/json" | jq
```

**Réponse attendue:**
```json
{
  "items": [
    {
      "id": 1,
      "sku": "ELEC-001",
      "name": "Gaming Laptop 15\"",
      "price": 1299.99,
      "stock": 50,
      "updatedAt": "2025-01-15T10:30:00"
    }
  ],
  "currentPage": 0,
  "totalItems": 10,
  "totalPages": 2,
  "pageSize": 5,
  "categoryId": 1
}
```

---

### 2.3 GET /api/items/{id} (Récupérer un item)

**Récupérer l'item avec ID 1**
```bash
curl -X GET "${API_URL}/api/items/1" \
  -H "Content-Type: application/json" | jq
```

**Tester avec ID inexistant (404)**
```bash
curl -X GET "${API_URL}/api/items/99999" \
  -H "Content-Type: application/json" -i
```

---

### 2.4 POST /api/items (Créer un item)

**Créer un item sans catégorie**
```bash
curl -X POST "${API_URL}/api/items" \
  -H "Content-Type: application/json" \
  -d '{
    "sku": "TEST-001",
    "name": "Test Product",
    "price": 99.99,
    "stock": 100
  }' | jq
```

**Créer un item avec catégorie**
```bash
curl -X POST "${API_URL}/api/items" \
  -H "Content-Type: application/json" \
  -d '{
    "sku": "ELEC-011",
    "name": "Wireless Charger",
    "price": 39.99,
    "stock": 200,
    "categoryId": 1
  }' | jq
```

**Tester la contrainte d'unicité SKU (409)**
```bash
curl -X POST "${API_URL}/api/items" \
  -H "Content-Type: application/json" \
  -d '{
    "sku": "ELEC-001",
    "name": "Duplicate SKU",
    "price": 10.00,
    "stock": 1
  }' -i
```

**Tester avec catégorie inexistante (400)**
```bash
curl -X POST "${API_URL}/api/items" \
  -H "Content-Type: application/json" \
  -d '{
    "sku": "TEST-002",
    "name": "Invalid Category",
    "price": 10.00,
    "stock": 1,
    "categoryId": 999
  }' -i
```

**Réponse attendue (201 Created):**
```json
{
  "id": 101,
  "sku": "ELEC-011",
  "name": "Wireless Charger",
  "price": 39.99,
  "stock": 200,
  "updatedAt": "2025-01-15T11:30:00"
}
```

---

### 2.5 PUT /api/items/{id} (Mettre à jour)

**Mettre à jour le prix et le stock**
```bash
curl -X PUT "${API_URL}/api/items/101" \
  -H "Content-Type: application/json" \
  -d '{
    "price": 34.99,
    "stock": 250
  }' | jq
```

**Changer la catégorie d'un item**
```bash
curl -X PUT "${API_URL}/api/items/101" \
  -H "Content-Type: application/json" \
  -d '{
    "categoryId": 4
  }' | jq
```

**Retirer la catégorie (set to null)**
```bash
curl -X PUT "${API_URL}/api/items/101" \
  -H "Content-Type: application/json" \
  -d '{
    "categoryId": null
  }' | jq
```

**Mettre à jour tous les champs**
```bash
curl -X PUT "${API_URL}/api/items/101" \
  -H "Content-Type: application/json" \
  -d '{
    "sku": "ELEC-011-V2",
    "name": "Wireless Charger Pro",
    "price": 49.99,
    "stock": 150,
    "categoryId": 1
  }' | jq
```

---

### 2.6 DELETE /api/items/{id} (Supprimer)

**Supprimer un item**
```bash
curl -X DELETE "${API_URL}/api/items/101" -i
```

**Vérifier la suppression (404)**
```bash
curl -X GET "${API_URL}/api/items/101" -i
```

---

## 3. Tests de Monitoring

### 3.1 Health Check

**Vérifier l'état de santé de l'application**
```bash
curl -X GET "${API_URL}/actuator/health" | jq
```

**Réponse attendue:**
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "PostgreSQL",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP"
    },
    "ping": {
      "status": "UP"
    }
  }
}
```

---

### 3.2 Métriques Prometheus

**Récupérer toutes les métriques Prometheus**
```bash
curl -X GET "${API_URL}/actuator/prometheus"
```

**Métriques HikariCP**
```bash
curl -X GET "${API_URL}/actuator/metrics/hikari.connections.active" | jq
curl -X GET "${API_URL}/actuator/metrics/hikari.connections.idle" | jq
curl -X GET "${API_URL}/actuator/metrics/hikari.connections.total" | jq
```

**Métriques HTTP**
```bash
curl -X GET "${API_URL}/actuator/metrics/http.server.requests" | jq
```

**Métriques JVM**
```bash
curl -X GET "${API_URL}/actuator/metrics/jvm.memory.used" | jq
curl -X GET "${API_URL}/actuator/metrics/jvm.threads.live" | jq
```

---

## 4. Tests de Performance

### 4.1 Test de charge basique

**Créer 100 requêtes GET en parallèle**
```bash
for i in {1..100}; do
  curl -X GET "${API_URL}/api/items?page=0&size=20" > /dev/null 2>&1 &
done
wait
echo "Test de charge terminé"
```

### 4.2 Test de pagination intensive

**Parcourir toutes les pages**
```bash
for page in {0..10}; do
  echo "Fetching page $page..."
  curl -X GET "${API_URL}/api/items?page=${page}&size=10" \
    -H "Content-Type: application/json" | jq '.currentPage, .totalPages'
  sleep 0.5
done
```

### 4.3 Test de filtrage relationnel

**Tester le filtrage par catégorie**
```bash
for category_id in {1..10}; do
  echo "Testing category $category_id..."
  curl -X GET "${API_URL}/api/items?categoryId=${category_id}&page=0&size=20" \
    -H "Content-Type: application/json" | jq '.totalItems, .categoryId'
  sleep 0.3
done
```

### 4.4 Monitoring pendant le test

**Observer les connexions actives**
```bash
watch -n 1 'curl -s http://localhost:8080/actuator/metrics/hikari.connections.active | jq ".measurements[0].value"'
```

**Observer le nombre de requêtes HTTP**
```bash
watch -n 1 'curl -s http://localhost:8080/actuator/metrics/http.server.requests | jq ".measurements[] | select(.statistic==\"COUNT\") | .value"'
```

---

## 5. Script de test complet

**Sauvegardez ce script dans `test-api.sh`:**

```bash
#!/bin/bash

API_URL="http://localhost:8080"

echo "=========================================="
echo "Tests API - Variante C"
echo "=========================================="

# Test 1: Health check
echo ""
echo "1. Health Check..."
curl -s "${API_URL}/actuator/health" | jq '.status'

# Test 2: Get categories
echo ""
echo "2. Get Categories..."
curl -s "${API_URL}/api/categories?page=0&size=5" | jq '.totalItems'

# Test 3: Create category
echo ""
echo "3. Create Category..."
CATEGORY_ID=$(curl -s -X POST "${API_URL}/api/categories" \
  -H "Content-Type: application/json" \
  -d '{"code":"TEST","name":"Test Category"}' | jq -r '.id')
echo "Created category ID: $CATEGORY_ID"

# Test 4: Get category by ID
echo ""
echo "4. Get Category by ID..."
curl -s "${API_URL}/api/categories/${CATEGORY_ID}" | jq '.code, .name'

# Test 5: Create item
echo ""
echo "5. Create Item..."
ITEM_ID=$(curl -s -X POST "${API_URL}/api/items" \
  -H "Content-Type: application/json" \
  -d "{\"sku\":\"TEST-SKU\",\"name\":\"Test Item\",\"price\":99.99,\"stock\":50,\"categoryId\":${CATEGORY_ID}}" | jq -r '.id')
echo "Created item ID: $ITEM_ID"

# Test 6: Get items by category
echo ""
echo "6. Get Items by Category..."
curl -s "${API_URL}/api/items?categoryId=${CATEGORY_ID}" | jq '.totalItems'

# Test 7: Update item
echo ""
echo "7. Update Item..."
curl -s -X PUT "${API_URL}/api/items/${ITEM_ID}" \
  -H "Content-Type: application/json" \
  -d '{"price":79.99}' | jq '.price'

# Test 8: Delete item
echo ""
echo "8. Delete Item..."
curl -s -X DELETE "${API_URL}/api/items/${ITEM_ID}" -o /dev/null -w "HTTP Status: %{http_code}\n"

# Test 9: Delete category
echo ""
echo "9. Delete Category..."
curl -s -X DELETE "${API_URL}/api/categories/${CATEGORY_ID}" -o /dev/null -w "HTTP Status: %{http_code}\n"

echo ""
echo "=========================================="
echo "Tests terminés!"
echo "=========================================="
```

**Exécuter le script:**
```bash
chmod +x test-api.sh
./test-api.sh
```

---

## 6. Collection Postman

Pour importer dans Postman, créez une collection avec les variables:

**Variables:**
- `base_url`: `http://localhost:8080`
- `category_id`: `1`
- `item_id`: `1`

Utilisez ensuite `{{base_url}}/api/categories` dans vos requêtes.

---

## Notes

- Toutes les réponses sont au format JSON
- Les codes HTTP standards sont utilisés (200, 201, 204, 404, 409)
- La pagination commence à `page=0`
- Le paramètre `jq` est utilisé pour formater le JSON (installer avec `apt install jq` ou `brew install jq`)
