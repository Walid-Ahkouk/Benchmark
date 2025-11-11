# JMeter Backend Communication Plan

## 1. Backend Overview

### Server Configuration
- **Server Type**: Jetty Embedded Server
- **Protocol**: HTTP
- **Host**: `localhost` (or your server IP)
- **Port**: `8080`
- **Base API Path**: `/api`
- **Content-Type**: `application/json`
- **Framework**: JAX-RS (Jersey) with JPA/Hibernate
- **Database**: PostgreSQL

### Base URL
```
http://localhost:8080/api
```

---

## 2. Available API Endpoints

### 2.1 Items Endpoints

#### GET /api/items
**Description**: List all items with pagination and optional category filter

**Query Parameters**:
- `page` (optional, default: 1) - Page number
- `size` (optional, default: 10) - Items per page
- `categoryId` (optional) - Filter by category ID

**Example Request**:
```
GET http://localhost:8080/api/items?page=1&size=50
GET http://localhost:8080/api/items?page=1&size=50&categoryId=1
```

**Expected Response**: `200 OK` with JSON array of items

---

#### GET /api/items/{id}
**Description**: Get a specific item by ID

**Path Parameters**:
- `id` - Item ID (Long)

**Example Request**:
```
GET http://localhost:8080/api/items/1
```

**Expected Response**: `200 OK` with item JSON, or `404 NOT FOUND`

---

#### POST /api/items
**Description**: Create a new item

**Query Parameters**:
- `categoryId` (required) - Category ID for the item

**Request Body** (JSON):
```json
{
  "sku": "SKU-001",
  "name": "Item Name",
  "price": 19.99,
  "stock": 100
}
```

**Example Request**:
```
POST http://localhost:8080/api/items?categoryId=1
Content-Type: application/json
```

**Expected Response**: `201 CREATED` with created item JSON, or `400 BAD REQUEST`

---

#### PUT /api/items/{id}
**Description**: Update an existing item

**Path Parameters**:
- `id` - Item ID (Long)

**Query Parameters**:
- `categoryId` (optional) - New category ID

**Request Body** (JSON):
```json
{
  "sku": "SKU-001-UPDATED",
  "name": "Updated Item Name",
  "price": 29.99,
  "stock": 150
}
```

**Example Request**:
```
PUT http://localhost:8080/api/items/1?categoryId=2
Content-Type: application/json
```

**Expected Response**: `200 OK` with updated item JSON, or `404 NOT FOUND`, or `400 BAD REQUEST`

---

#### DELETE /api/items/{id}
**Description**: Delete an item

**Path Parameters**:
- `id` - Item ID (Long)

**Example Request**:
```
DELETE http://localhost:8080/api/items/1
```

**Expected Response**: `204 NO CONTENT`, or `404 NOT FOUND`

---

### 2.2 Categories Endpoints

#### GET /api/categories
**Description**: List all categories with pagination

**Query Parameters**:
- `page` (optional, default: 1) - Page number
- `size` (optional, default: 10) - Categories per page

**Example Request**:
```
GET http://localhost:8080/api/categories?page=1&size=50
```

**Expected Response**: `200 OK` with JSON array of categories

---

#### GET /api/categories/{id}
**Description**: Get a specific category by ID

**Path Parameters**:
- `id` - Category ID (Long)

**Example Request**:
```
GET http://localhost:8080/api/categories/1
```

**Expected Response**: `200 OK` with category JSON, or `404 NOT FOUND`

---

#### GET /api/categories/{id}/items
**Description**: Get all items for a specific category

**Path Parameters**:
- `id` - Category ID (Long)

**Query Parameters**:
- `page` (optional, default: 1) - Page number
- `size` (optional, default: 10) - Items per page

**Example Request**:
```
GET http://localhost:8080/api/categories/1/items?page=1&size=50
```

**Expected Response**: `200 OK` with JSON array of items

---

#### POST /api/categories
**Description**: Create a new category

**Request Body** (JSON):
```json
{
  "code": "CAT-001",
  "name": "Category Name"
}
```

**Example Request**:
```
POST http://localhost:8080/api/categories
Content-Type: application/json
```

**Expected Response**: `201 CREATED` with created category JSON

---

#### PUT /api/categories/{id}
**Description**: Update an existing category

**Path Parameters**:
- `id` - Category ID (Long)

**Request Body** (JSON):
```json
{
  "code": "CAT-001-UPDATED",
  "name": "Updated Category Name"
}
```

**Example Request**:
```
PUT http://localhost:8080/api/categories/1
Content-Type: application/json
```

**Expected Response**: `200 OK` with updated category JSON, or `404 NOT FOUND`

---

#### DELETE /api/categories/{id}
**Description**: Delete a category

**Path Parameters**:
- `id` - Category ID (Long)

**Example Request**:
```
DELETE http://localhost:8080/api/categories/1
```

**Expected Response**: `204 NO CONTENT`, or `404 NOT FOUND`

---

## 3. JMeter Configuration

### 3.1 HTTP Request Defaults

Configure these settings in JMeter's "HTTP Request Defaults" element:

| Property | Value |
|----------|-------|
| **Server Name or IP** | `${HOST}` (default: `localhost`) |
| **Port Number** | `${PORT}` (default: `8080`) |
| **Protocol** | `http` |
| **Path** | `${API_PATH}` (default: `/api`) |
| **Implementation** | `HttpClient4` or `Java` |
| **Content-Type** | `application/json` (for POST/PUT) |

### 3.2 User Defined Variables

Create these variables at the Test Plan level:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `HOST` | `localhost` | Backend server hostname |
| `PORT` | `8080` | Backend server port |
| `API_PATH` | `/api` | Base API path |
| `PAGE_SIZE` | `50` | Default page size for pagination |
| `RAMP_UP` | `60` | Ramp-up time in seconds |
| `PALIER_DURATION` | `600` | Test duration in seconds |

---

## 4. JMeter Test Scenarios

### 4.1 Read-Heavy Scenario (Already Implemented)

**File**: `1_read_heavy.jmx`

**Test Distribution**:
- 50% - GET /items (list)
- 20% - GET /items?categoryId=...
- 20% - GET /categories/{id}/items
- 10% - GET /categories (list)

**Thread Configuration**:
- Stepping Thread Group
- Start: 50 users
- Max: 150 users
- Ramp-up: 60 seconds
- Duration: 600 seconds

**Data Requirements**:
- `category_ids.csv` - List of category IDs
- `item_ids.csv` - List of item IDs

---

### 4.2 Write-Heavy Scenario (Recommended)

**Test Distribution**:
- 30% - POST /items
- 20% - PUT /items/{id}
- 20% - POST /categories
- 15% - PUT /categories/{id}
- 10% - DELETE /items/{id}
- 5% - DELETE /categories/{id}

**Data Requirements**:
- `payloads_1k.csv` or `payloads_5k.csv` - Item payloads
- `category_ids.csv` - For categoryId parameter
- `item_ids.csv` - For update/delete operations

---

### 4.3 Mixed Workload Scenario (Recommended)

**Test Distribution**:
- 40% - GET /items (various queries)
- 20% - GET /categories/{id}/items
- 15% - POST /items
- 10% - PUT /items/{id}
- 10% - GET /categories
- 5% - DELETE /items/{id}

---

## 5. JMeter Elements Setup

### 5.1 HTTP Request Sampler Configuration

#### For GET Requests:
1. **Method**: GET
2. **Path**: `/items`, `/categories`, `/items/{id}`, etc.
3. **Parameters**: Add query parameters (page, size, categoryId)
4. **Headers**: Usually not needed for GET

#### For POST/PUT Requests:
1. **Method**: POST or PUT
2. **Path**: `/items`, `/categories`, `/items/{id}`, etc.
3. **Body Data**: JSON payload
4. **Headers Manager**: Add `Content-Type: application/json`

### 5.2 CSV Data Set Config

**For Category IDs**:
- **Filename**: `category_ids.csv`
- **Variable Names**: `csvCatId`
- **Delimiter**: `,`
- **Recycle**: `true`
- **Stop thread on EOF**: `false`

**For Item IDs**:
- **Filename**: `item_ids.csv`
- **Variable Names**: `csvItemId`
- **Delimiter**: `,`
- **Recycle**: `true`
- **Stop thread on EOF**: `false`

**For Payloads**:
- **Filename**: `payloads_1k.csv` or `payloads_5k.csv`
- **Variable Names**: `payload`
- **Delimiter**: `,` (or appropriate delimiter)
- **Recycle**: `true`

### 5.3 Headers Manager

Add this header for POST/PUT requests:
```
Content-Type: application/json
```

### 5.4 Response Assertions

Add assertions to validate:
- **Response Code**: `200`, `201`, `204` (depending on operation)
- **Response Time**: Set maximum acceptable response time
- **Response Body**: Validate JSON structure (optional)

### 5.5 Listeners

Recommended listeners:
- **View Results Tree** (for debugging, disable in production runs)
- **Summary Report**
- **Aggregate Report**
- **Backend Listener** (for InfluxDB integration, if configured)

---

## 6. Sample JMeter Test Structure

```
Test Plan
├── User Defined Variables
│   ├── HOST = localhost
│   ├── PORT = 8080
│   ├── API_PATH = /api
│   └── PAGE_SIZE = 50
│
├── Thread Group / Stepping Thread Group
│   ├── HTTP Request Defaults
│   │   ├── Server: ${HOST}
│   │   ├── Port: ${PORT}
│   │   └── Path: ${API_PATH}
│   │
│   ├── CSV Data Set Config (Category IDs)
│   ├── CSV Data Set Config (Item IDs)
│   ├── CSV Data Set Config (Payloads) [if needed]
│   │
│   ├── HTTP Header Manager
│   │   └── Content-Type: application/json
│   │
│   └── HTTP Request Samplers
│       ├── GET /items
│       ├── GET /items/{id}
│       ├── GET /items?categoryId={id}
│       ├── GET /categories
│       ├── GET /categories/{id}
│       ├── GET /categories/{id}/items
│       ├── POST /items
│       ├── POST /categories
│       ├── PUT /items/{id}
│       ├── PUT /categories/{id}
│       ├── DELETE /items/{id}
│       └── DELETE /categories/{id}
│
└── Listeners
    ├── View Results Tree
    ├── Summary Report
    └── Backend Listener (InfluxDB)
```

---

## 7. JSON Payload Examples

### Create Item Payload
```json
{
  "sku": "SKU-${__Random(1000,9999)}",
  "name": "Test Item ${__time()}",
  "price": ${__Random(10,1000)},
  "stock": ${__Random(1,1000)}
}
```

### Update Item Payload
```json
{
  "sku": "SKU-UPDATED-${__Random(1000,9999)}",
  "name": "Updated Item ${__time()}",
  "price": ${__Random(10,1000)},
  "stock": ${__Random(1,1000)}
}
```

### Create Category Payload
```json
{
  "code": "CAT-${__Random(1000,9999)}",
  "name": "Category ${__time()}"
}
```

### Update Category Payload
```json
{
  "code": "CAT-UPDATED-${__Random(1000,9999)}",
  "name": "Updated Category ${__time()}"
}
```

---

## 8. Testing Checklist

### Pre-Test Setup
- [ ] Backend server is running on port 8080
- [ ] Database is accessible and populated with test data
- [ ] CSV files are in the correct location
- [ ] JMeter plugins are installed (if using Stepping Thread Group)
- [ ] Network connectivity is verified

### Test Configuration
- [ ] HTTP Request Defaults configured correctly
- [ ] User Defined Variables set
- [ ] CSV Data Set Configs point to correct files
- [ ] Headers Manager configured for JSON requests
- [ ] Thread Group parameters set appropriately
- [ ] Listeners configured (disable View Results Tree for production)

### During Test
- [ ] Monitor backend server logs
- [ ] Monitor database connections
- [ ] Check for errors in JMeter results
- [ ] Monitor system resources (CPU, Memory, Network)

### Post-Test
- [ ] Review response times
- [ ] Check error rates
- [ ] Validate response codes
- [ ] Analyze throughput
- [ ] Review backend logs for errors

---

## 9. Common Issues and Solutions

### Issue: Connection Refused
**Solution**: 
- Verify backend is running: `curl http://localhost:8080/api/categories`
- Check firewall settings
- Verify HOST and PORT variables

### Issue: 404 Not Found
**Solution**:
- Verify API_PATH is set to `/api`
- Check endpoint path spelling
- Ensure backend is deployed correctly

### Issue: 400 Bad Request
**Solution**:
- Verify JSON payload format
- Check required parameters (e.g., categoryId for POST /items)
- Validate Content-Type header is set

### Issue: 500 Internal Server Error
**Solution**:
- Check backend logs
- Verify database connection
- Check for data integrity issues

### Issue: CSV File Not Found
**Solution**:
- Use absolute paths in CSV Data Set Config
- Verify file exists and is readable
- Check file encoding (UTF-8 recommended)

---

## 10. Performance Testing Best Practices

1. **Start Small**: Begin with low user counts and gradually increase
2. **Warm-up Period**: Allow backend to warm up before collecting metrics
3. **Realistic Data**: Use realistic payload sizes and data distributions
4. **Monitor Resources**: Monitor both JMeter and backend server resources
5. **Isolate Tests**: Run tests in isolated environments
6. **Baseline First**: Establish baseline performance before optimization
7. **Iterative Testing**: Run multiple test iterations for consistency
8. **Document Results**: Keep detailed records of test configurations and results

---

## 11. Next Steps

1. **Create Write-Heavy Test Plan**: Implement POST/PUT/DELETE scenarios
2. **Create Mixed Workload Test Plan**: Combine read and write operations
3. **Add Response Validation**: Implement JSON schema validation
4. **Implement Correlation**: Extract IDs from responses for chained requests
5. **Add Custom Metrics**: Implement custom listeners for specific metrics
6. **Automate Test Execution**: Create scripts to run tests automatically
7. **Integrate with CI/CD**: Add performance tests to your pipeline

---

## 12. Quick Reference

### Base URL
```
http://localhost:8080/api
```

### Key Endpoints
- Items: `/api/items`
- Categories: `/api/categories`
- Category Items: `/api/categories/{id}/items`

### Required Headers
```
Content-Type: application/json
```

### Common Query Parameters
- `page` - Page number (default: 1)
- `size` - Page size (default: 10)
- `categoryId` - Filter by category (for GET /items)

---

**Last Updated**: Based on current backend implementation
**Backend Version**: JAX-RS with Jersey 3.1.0, Jetty 11.0.15

