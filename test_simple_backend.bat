@echo off
echo ========================================
echo   Test Simple Backend
echo ========================================
echo.

echo [1/4] Test GET /categories
curl.exe -v "http://localhost:8080/api/categories?page=1&size=10"
echo.
echo.

echo [2/4] Test GET /items
curl.exe -v "http://localhost:8080/api/items?page=1&size=10"
echo.
echo.

echo [3/4] Test GET /items avec categoryId=1
curl.exe -v "http://localhost:8080/api/items?categoryId=1&page=1&size=10"
echo.
echo.

echo [4/4] Test GET /categories/1/items
curl.exe -v "http://localhost:8080/api/categories/1/items?page=1&size=10"
echo.
echo.

echo ========================================
echo   Test termine
echo ========================================
pause

