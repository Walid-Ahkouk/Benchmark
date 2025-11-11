@echo off
echo ========================================
echo   Demarrage InfluxDB et Grafana
echo ========================================
echo.

REM Vérifier si Docker est installé
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Docker n'est pas installe ou non accessible
    echo Veuillez installer Docker Desktop pour Windows
    pause
    exit /b 1
)

echo [1/4] Verification de Docker... OK
echo.

REM Vérifier si InfluxDB est déjà en cours d'exécution
curl -s http://localhost:8086/health >nul 2>&1
if not errorlevel 1 (
    echo [2/4] InfluxDB est deja en cours d'execution sur localhost:8086
    echo [OK] InfluxDB accessible
) else (
    REM Vérifier si les conteneurs existent déjà
    docker ps -a --filter "name=influxdb" --format "{{.Names}}" | findstr /C:"influxdb" >nul
    if errorlevel 1 (
        echo [2/4] Creation du conteneur InfluxDB...
        docker run -d ^
          --name influxdb ^
          -p 8086:8086 ^
          -v influxdb-storage:/var/lib/influxdb2 ^
          -e DOCKER_INFLUXDB_INIT_MODE=setup ^
          -e DOCKER_INFLUXDB_INIT_USERNAME=admin ^
          -e DOCKER_INFLUXDB_INIT_PASSWORD=admin123 ^
          -e DOCKER_INFLUXDB_INIT_ORG=myorg ^
          -e DOCKER_INFLUXDB_INIT_BUCKET=jmeter ^
          -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=0g6tixIL9cA2cqiuYKCXU3IjW1z_0Xg53stFC75BuEaS9w1uaeXejWJKTiyarp5f8OVLv6SEokreKWN3nZE22A== ^
          influxdb:2.7
        if errorlevel 1 (
            echo [ERREUR] Impossible de creer le conteneur InfluxDB
            echo.
            echo Si vous avez demarre InfluxDB manuellement, c'est OK.
            echo Executez check_influxdb.bat pour verifier.
            pause
            exit /b 1
        )
        echo [OK] Conteneur InfluxDB cree
    ) else (
        echo [2/4] Demarrage du conteneur InfluxDB existant...
        docker start influxdb
        if errorlevel 1 (
            echo [ATTENTION] Impossible de demarrer le conteneur InfluxDB
            echo.
            echo Si vous avez demarre InfluxDB manuellement, c'est OK.
            echo Executez check_influxdb.bat pour verifier.
        ) else (
            echo [OK] InfluxDB demarre
        )
    )
)

timeout /t 3 /nobreak >nul

REM Vérifier si Grafana existe déjà
docker ps -a --filter "name=grafana" --format "{{.Names}}" | findstr /C:"grafana" >nul
if errorlevel 1 (
    echo [3/4] Creation du conteneur Grafana...
    docker run -d ^
      --name grafana ^
      -p 3000:3000 ^
      -v grafana-storage:/var/lib/grafana ^
      grafana/grafana:latest
    if errorlevel 1 (
        echo [ERREUR] Impossible de creer le conteneur Grafana
        pause
        exit /b 1
    )
    echo [OK] Conteneur Grafana cree
) else (
    echo [3/4] Demarrage du conteneur Grafana existant...
    docker start grafana
    if errorlevel 1 (
        echo [ERREUR] Impossible de demarrer Grafana
        pause
        exit /b 1
    )
    echo [OK] Grafana demarre
)

timeout /t 3 /nobreak >nul

echo [4/4] Verification des services...
echo.

REM Vérifier InfluxDB
curl -s http://localhost:8086/health >nul 2>&1
if errorlevel 1 (
    echo [ATTENTION] InfluxDB ne repond pas sur http://localhost:8086/health
    echo.
    echo Si vous avez demarre InfluxDB manuellement:
    echo   - Verifiez qu'il ecoute sur le port 8086
    echo   - Executez check_influxdb.bat pour un diagnostic detaille
) else (
    echo [OK] InfluxDB est accessible sur http://localhost:8086
    curl -s http://localhost:8086/health
    echo.
)

REM Vérifier Grafana
curl -s http://localhost:3000/api/health >nul 2>&1
if errorlevel 1 (
    echo [ATTENTION] Grafana ne repond pas encore (peut prendre quelques secondes)
    echo   Ou Grafana n'est pas demarre
) else (
    echo [OK] Grafana est accessible sur http://localhost:3000
)

echo.
echo ========================================
echo   Services demarres avec succes !
echo ========================================
echo.
echo InfluxDB: http://localhost:8086
echo   - Username: admin
echo   - Password: admin123
echo.
echo Grafana: http://localhost:3000
echo   - Username: admin
echo   - Password: admin (changez au premier login)
echo.
echo Prochaines etapes:
echo   1. Ouvrir Grafana dans votre navigateur
echo   2. Ajouter InfluxDB comme source de donnees
echo   3. Importer le dashboard JMeter (ID: 5496)
echo   4. Lancer vos tests JMeter
echo.
echo Consultez GRAFANA_INFLUXDB_SETUP.md pour plus de details
echo.
pause

