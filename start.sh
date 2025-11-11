#!/bin/bash

# ========================================
# Variant C - Quick Start Script
# ========================================

echo "=========================================="
echo "Variant C - Spring Boot Benchmark"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose is not installed."
    exit 1
fi

echo "Step 1: Stopping existing containers..."
docker-compose down

echo ""
echo "Step 2: Building and starting containers..."
docker-compose up -d --build

echo ""
echo "Step 3: Waiting for services to be ready..."
sleep 10

echo ""
echo "Step 4: Checking service health..."

# Check PostgreSQL
if docker-compose ps | grep -q "postgres.*healthy"; then
    echo "✓ PostgreSQL is healthy"
else
    echo "✗ PostgreSQL is not ready"
fi

# Wait for Spring Boot app
echo ""
echo "Waiting for Spring Boot application to start (this may take 30-60 seconds)..."
for i in {1..30}; do
    if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
        echo "✓ Spring Boot application is running"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""
echo ""
echo "=========================================="
echo "Services are ready!"
echo "=========================================="
echo ""
echo "Application URLs:"
echo "  - Spring Boot API:      http://localhost:8080"
echo "  - Actuator Health:      http://localhost:8080/actuator/health"
echo "  - Prometheus Metrics:   http://localhost:8080/actuator/prometheus"
echo "  - Prometheus UI:        http://localhost:9090"
echo "  - Grafana:              http://localhost:3000 (admin/admin)"
echo ""
echo "API Endpoints:"
echo "  - GET  /api/categories"
echo "  - GET  /api/categories/{id}"
echo "  - POST /api/categories"
echo "  - PUT  /api/categories/{id}"
echo "  - DELETE /api/categories/{id}"
echo "  - GET  /api/categories/{id}/items"
echo ""
echo "  - GET  /api/items"
echo "  - GET  /api/items?categoryId={id}"
echo "  - GET  /api/items/{id}"
echo "  - POST /api/items"
echo "  - PUT  /api/items/{id}"
echo "  - DELETE /api/items/{id}"
echo ""
echo "Example Commands:"
echo "  # Get all categories (paginated)"
echo "  curl 'http://localhost:8080/api/categories?page=0&size=10'"
echo ""
echo "  # Get items by category"
echo "  curl 'http://localhost:8080/api/items?categoryId=1&page=0&size=20'"
echo ""
echo "  # Create a new category"
echo "  curl -X POST http://localhost:8080/api/categories \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"code\":\"TEST\",\"name\":\"Test Category\"}'"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f app"
echo ""
echo "To stop all services:"
echo "  docker-compose down"
echo ""
echo "=========================================="
