@echo off
echo ========================================
echo   Verification Grafana
echo ========================================
echo.

echo [1/2] Verification du port 3000...
netstat -an | findstr ":3000" >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Aucun service n'ecoute sur le port 3000
    echo.
    echo Verifiez que Grafana est demarre
    pause
    exit /b 1
) else (
    echo [OK] Un service ecoute sur le port 3000
)

echo.
echo [2/2] Test de connexion HTTP...
curl -s http://localhost:3000/api/health >nul 2>&1
if errorlevel 1 (
    echo [ATTENTION] Grafana ne repond pas encore (peut prendre quelques secondes)
    echo.
    echo Verifiez que:
    echo   - Grafana est bien demarre
    echo   - Le port 3000 n'est pas bloque par le firewall
) else (
    echo [OK] Grafana repond correctement
    curl -s http://localhost:3000/api/health
    echo.
)

echo.
echo ========================================
echo   Verification terminee
echo ========================================
echo.
echo URL Grafana: http://localhost:3000
echo   - Username par defaut: admin
echo   - Password par defaut: admin
echo.
pause

