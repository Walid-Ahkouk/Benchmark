@echo off
echo ========================================
echo   Arret d'InfluxDB et Grafana
echo ========================================
echo.

docker stop influxdb grafana 2>nul
if errorlevel 1 (
    echo [ATTENTION] Certains conteneurs n'existaient pas ou etaient deja arretes
) else (
    echo [OK] Services arretes
)

echo.
echo Pour redemarrer, executez: start_influxdb_grafana.bat
echo.
pause

