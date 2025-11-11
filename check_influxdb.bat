@echo off
echo ========================================
echo   Verification InfluxDB
echo ========================================
echo.

echo [1/3] Verification du port 8086...
netstat -an | findstr ":8086" >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Aucun service n'ecoute sur le port 8086
    echo.
    echo Verifiez que InfluxDB est demarre
    pause
    exit /b 1
) else (
    echo [OK] Un service ecoute sur le port 8086
)

echo.
echo [2/3] Test de connexion HTTP...
curl -s http://localhost:8086/health >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] InfluxDB ne repond pas sur http://localhost:8086/health
    echo.
    echo Verifiez que:
    echo   - InfluxDB est bien demarre
    echo   - Le port 8086 n'est pas bloque par le firewall
    echo   - InfluxDB ecoute sur localhost:8086
    pause
    exit /b 1
) else (
    echo [OK] InfluxDB repond correctement
)

echo.
echo [3/3] Test de l'endpoint /health...
curl -s http://localhost:8086/health
if errorlevel 1 (
    echo [ATTENTION] Impossible d'obtenir la reponse de /health
) else (
    echo.
    echo [OK] Endpoint /health accessible
)

echo.
echo ========================================
echo   InfluxDB est operationnel !
echo ========================================
echo.
echo URL: http://localhost:8086
echo.
echo Vous pouvez maintenant:
echo   1. Configurer Grafana avec cette URL
echo   2. Lancer vos tests JMeter
echo   3. Les donnees seront envoyees a InfluxDB
echo.
pause

