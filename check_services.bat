@echo off
echo ========================================
echo   Verification des Services
echo ========================================
echo.

echo [INFLUXDB]
echo ----------
netstat -an | findstr ":8086" >nul 2>&1
if errorlevel 1 (
    echo [X] InfluxDB n'est pas accessible sur le port 8086
) else (
    echo [OK] Port 8086 est ouvert
    curl -s http://localhost:8086/health >nul 2>&1
    if errorlevel 1 (
        echo [X] InfluxDB ne repond pas sur http://localhost:8086/health
    ) else (
        echo [OK] InfluxDB repond correctement
        echo       URL: http://localhost:8086
    )
)

echo.
echo [GRAFANA]
echo ----------
netstat -an | findstr ":3000" >nul 2>&1
if errorlevel 1 (
    echo [X] Grafana n'est pas accessible sur le port 3000
) else (
    echo [OK] Port 3000 est ouvert
    curl -s http://localhost:3000/api/health >nul 2>&1
    if errorlevel 1 (
        echo [X] Grafana ne repond pas sur http://localhost:3000/api/health
    ) else (
        echo [OK] Grafana repond correctement
        echo       URL: http://localhost:3000
    )
)

echo.
echo [JMETER BACKEND]
echo ---------------
echo Verification de la configuration JMeter...
echo.
echo Les fichiers .jmx sont configures pour envoyer des donnees a:
echo   - URL: http://localhost:8086/api/v2/write?org=myorg&bucket=jmeter
echo   - Token: (configure dans les fichiers .jmx)
echo.
echo Pour tester:
echo   1. Verifiez qu'InfluxDB est accessible (voir ci-dessus)
echo   2. Lancez un test JMeter
echo   3. Verifiez les donnees dans InfluxDB UI
echo.

echo ========================================
echo   Resume
echo ========================================
echo.
if exist "check_influxdb.bat" (
    echo Pour verifier InfluxDB en detail: check_influxdb.bat
)
if exist "check_grafana.bat" (
    echo Pour verifier Grafana en detail: check_grafana.bat
)
echo.
pause

