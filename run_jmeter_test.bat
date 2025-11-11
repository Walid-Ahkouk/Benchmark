@echo off
setlocal enabledelayedexpansion
echo ========================================
echo   Lancement Test JMeter
echo ========================================
echo.

if "%1"=="" (
    echo Usage: run_jmeter_test.bat ^<scenario^> [skip-check]
    echo.
    echo Scenarios disponibles:
    echo   1 - READ-heavy
    echo   2 - JOIN-filter
    echo   3 - MIXED
    echo   4 - HEAVY-body
    echo.
    echo Options:
    echo   skip-check  - Saute la verification du backend
    echo.
    pause
    exit /b 1
)

set SKIP_CHECK=0
if /i "%2"=="skip-check" (
    set SKIP_CHECK=1
)

set SCENARIO=%1
set TEST_DIR=%~dp0

REM Chercher JMeter dans les emplacements courants
set JMETER_HOME=
if exist "C:\JMeter\bin\jmeter.bat" (
    set JMETER_HOME=C:\JMeter
    echo [OK] JMeter trouve dans: C:\JMeter
) else if exist "C:\apache-jmeter-5.6.3\bin\jmeter.bat" (
    set JMETER_HOME=C:\apache-jmeter-5.6.3
    echo [OK] JMeter trouve dans: C:\apache-jmeter-5.6.3
) else if exist "C:\Program Files\Apache\jmeter\bin\jmeter.bat" (
    set JMETER_HOME=C:\Program Files\Apache\jmeter
    echo [OK] JMeter trouve dans: C:\Program Files\Apache\jmeter
) else if exist "%JMETER_HOME%\bin\jmeter.bat" (
    REM Utiliser la variable d'environnement si definie
    echo [OK] JMeter trouve via variable d'environnement: %JMETER_HOME%
) else (
    echo [ERREUR] JMeter non trouve
    echo.
    echo Chemins verifies:
    echo   - C:\JMeter\bin\jmeter.bat
    echo   - C:\apache-jmeter-5.6.3\bin\jmeter.bat
    echo   - C:\Program Files\Apache\jmeter\bin\jmeter.bat
    echo   - Variable d'environnement JMETER_HOME
    echo.
    echo Veuillez:
    echo   1. Verifier que JMeter est installe dans C:\JMeter
    echo   2. Definir la variable d'environnement JMETER_HOME=C:\JMeter
    echo   3. Ou modifier ce script avec le chemin correct
    echo.
    pause
    exit /b 1
)
echo.

if "%SCENARIO%"=="1" (
    set TEST_FILE=1_read_heavy.jmx
    set RESULT_FILE=results_read_heavy.jtl
    set REPORT_DIR=report_read_heavy
    set SCENARIO_NAME=READ-heavy
) else if "%SCENARIO%"=="2" (
    set TEST_FILE=2_join_filter.jmx
    set RESULT_FILE=results_join_filter.jtl
    set REPORT_DIR=report_join_filter
    set SCENARIO_NAME=JOIN-filter
) else if "%SCENARIO%"=="3" (
    set TEST_FILE=3_mixed.jmx
    set RESULT_FILE=results_mixed.jtl
    set REPORT_DIR=report_mixed
    set SCENARIO_NAME=MIXED
) else if "%SCENARIO%"=="4" (
    set TEST_FILE=4_heavy_body.jmx
    set RESULT_FILE=results_heavy_body.jtl
    set REPORT_DIR=report_heavy_body
    set SCENARIO_NAME=HEAVY-body
) else (
    echo [ERREUR] Scenario invalide: %SCENARIO%
    echo.
    echo Scenarios valides: 1, 2, 3, 4
    pause
    exit /b 1
)

echo Scenario: %SCENARIO_NAME%
echo Fichier de test: %TEST_FILE%
echo.

REM Verifier que le fichier de test existe
if not exist "%TEST_DIR%%TEST_FILE%" (
    echo [ERREUR] Fichier de test non trouve: %TEST_FILE%
    echo.
    echo Repertoire actuel: %TEST_DIR%
    pause
    exit /b 1
)

REM Verification du backend supprimee - le test se lancera directement
echo [1/4] Verification du backend... SKIP
echo        Assurez-vous que le backend est demarre sur http://localhost:8080
echo.

REM Verification InfluxDB supprimee
echo [2/4] Verification d'InfluxDB... SKIP
echo        Les donnees seront envoyees a Grafana si InfluxDB est accessible
echo.

:start_jmeter

echo [3/4] Lancement du test JMeter...
echo.

REM Supprimer les anciens fichiers de resultats s'ils existent
if exist "%TEST_DIR%%RESULT_FILE%" (
    echo Suppression de l'ancien fichier de resultats: %RESULT_FILE%
    del /F /Q "%TEST_DIR%%RESULT_FILE%" >nul 2>&1
)

REM Supprimer l'ancien rapport s'il existe
if exist "%TEST_DIR%%REPORT_DIR%" (
    echo Suppression de l'ancien rapport: %REPORT_DIR%
    rmdir /S /Q "%TEST_DIR%%REPORT_DIR%" >nul 2>&1
)

echo Commande executee:
echo   %JMETER_HOME%\bin\jmeter.bat -n -t "%TEST_FILE%" -l "%RESULT_FILE%" -e -o "%REPORT_DIR%"
echo.

"%JMETER_HOME%\bin\jmeter.bat" -n -t "%TEST_DIR%%TEST_FILE%" -l "%TEST_DIR%%RESULT_FILE%" -e -o "%TEST_DIR%%REPORT_DIR%"

if errorlevel 1 (
    echo.
    echo [ERREUR] Le test a echoue
    echo.
    echo Verifiez:
    echo   - Que le backend est demarre
    echo   - Que les fichiers CSV existent
    echo   - Les logs ci-dessus pour plus de details
    pause
    exit /b 1
)

echo.
echo [4/4] Test termine avec succes !
echo.
echo ========================================
echo   Resultats
echo ========================================
echo.
echo Fichier de resultats JTL:
echo   %TEST_DIR%%RESULT_FILE%
echo.
echo Rapport HTML:
echo   %TEST_DIR%%REPORT_DIR%\index.html
echo.

REM Ouvrir le rapport automatiquement
if exist "%TEST_DIR%%REPORT_DIR%\index.html" (
    echo Ouverture du rapport HTML...
    start "" "%TEST_DIR%%REPORT_DIR%\index.html"
) else (
    echo [ATTENTION] Le rapport HTML n'a pas ete genere
)

echo.
echo Pour visualiser dans Grafana:
echo   1. Ouvrir http://localhost:3000
echo   2. Ouvrir le dashboard JMeter
echo.
pause

