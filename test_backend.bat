@echo off
echo ========================================
echo   Test de Diagnostic Backend
echo ========================================
echo.

echo [1/6] Test GET /categories
echo ----------------------------------------
curl.exe -v http://localhost:8080/api/categories
echo.
echo.
pause

echo [2/6] Test GET /categories avec pagination
echo ----------------------------------------
curl.exe -v "http://localhost:8080/api/categories?page=1&size=10"
echo.
echo.
pause

echo [3/6] Test GET /items
echo ----------------------------------------
curl.exe -v "http://localhost:8080/api/items?page=1&size=10"
echo.
echo.
pause

echo [4/6] Test GET /items avec categoryId
echo ----------------------------------------
curl.exe -v "http://localhost:8080/api/items?categoryId=1&page=1&size=10"
echo.
echo.
pause

echo [5/6] Test GET /categories/{id}/items
echo ----------------------------------------
curl.exe -v "http://localhost:8080/api/categories/1/items?page=1&size=10"
echo.
echo.
pause

echo [6/6] Test GET /items/{id}
echo ----------------------------------------
curl.exe -v "http://localhost:8080/api/items/1"
echo.
echo.

echo ========================================
echo   Diagnostic termine
echo ========================================
echo.
echo Si tous les tests fonctionnent, le probleme est dans la configuration JMeter
echo Si certains tests echouent, le probleme est dans le backend
echo.
pause

