@echo off
REM ========================================
REM Variant C - Quick Start Script (Windows)
REM ========================================

echo ==========================================
echo Variant C - Spring Boot Benchmark
echo ==========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running. Please start Docker and try again.
    pause
    exit /b 1
)

REM Check if Docker Compose is available
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo Error: docker-compose is not installed.
    pause
    exit /b 1
)

echo Step 1: Stopping existing containers...
docker-compose down

echo.
echo Step 2: Building and starting containers...
docker-compose up -d --build

echo.
echo Step 3: Waiting for services to be ready...
timeout /t 10 /nobreak >nul

echo.
echo Step 4: Checking service health...

REM Check PostgreSQL
docker-compose ps | findstr "postgres.*healthy" >nul
if not errorlevel 1 (
    echo [OK] PostgreSQL is healthy
) else (
    echo [!] PostgreSQL is not ready
)

REM Wait for Spring Boot app
echo.
echo Waiting for Spring Boot application to start (this may take 30-60 seconds)...
set RETRY=0
:WAIT_LOOP
if %RETRY% GEQ 30 goto TIMEOUT
curl -s http://localhost:8080/actuator/health >nul 2>&1
if not errorlevel 1 (
    echo [OK] Spring Boot application is running
    goto APP_READY
)
echo|set /p=.
timeout /t 2 /nobreak >nul
set /a RETRY+=1
goto WAIT_LOOP

:TIMEOUT
echo.
echo [!] Application did not start within expected time
echo Check logs with: docker-compose logs app
goto END

:APP_READY
echo.
echo.
echo ==========================================
echo Services are ready!
echo ==========================================
echo.
echo Application URLs:
echo   - Spring Boot API:      http://localhost:8080
echo   - Actuator Health:      http://localhost:8080/actuator/health
echo   - Prometheus Metrics:   http://localhost:8080/actuator/prometheus
echo   - Prometheus UI:        http://localhost:9090
echo   - Grafana:              http://localhost:3000 (admin/admin)
echo.
echo API Endpoints:
echo   - GET  /api/categories
echo   - GET  /api/categories/{id}
echo   - POST /api/categories
echo   - PUT  /api/categories/{id}
echo   - DELETE /api/categories/{id}
echo   - GET  /api/categories/{id}/items
echo.
echo   - GET  /api/items
echo   - GET  /api/items?categoryId={id}
echo   - GET  /api/items/{id}
echo   - POST /api/items
echo   - PUT  /api/items/{id}
echo   - DELETE /api/items/{id}
echo.
echo Example Commands (PowerShell):
echo   # Get all categories (paginated)
echo   curl 'http://localhost:8080/api/categories?page=0&size=10' ^| ConvertFrom-Json
echo.
echo   # Get items by category
echo   curl 'http://localhost:8080/api/items?categoryId=1&page=0&size=20' ^| ConvertFrom-Json
echo.
echo   # Create a new category
echo   curl -X POST http://localhost:8080/api/categories `
echo     -H 'Content-Type: application/json' `
echo     -d '{\"code\":\"TEST\",\"name\":\"Test Category\"}'
echo.
echo To view logs:
echo   docker-compose logs -f app
echo.
echo To stop all services:
echo   docker-compose down
echo.
echo ==========================================

:END
pause
