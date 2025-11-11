@echo off
echo ========================================
echo   Analyse des Erreurs JMeter
echo ========================================
echo.

if "%1"=="" (
    echo Usage: analyze_jmeter_errors.bat ^<fichier.jtl^>
    echo.
    echo Exemple: analyze_jmeter_errors.bat results_read_heavy.jtl
    echo.
    pause
    exit /b 1
)

set JTL_FILE=%1

if not exist "%JTL_FILE%" (
    echo [ERREUR] Fichier non trouve: %JTL_FILE%
    pause
    exit /b 1
)

echo Analyse du fichier: %JTL_FILE%
echo.

echo [1/3] Recherche des erreurs...
findstr /C:"false" "%JTL_FILE%" > temp_errors.txt 2>nul
if errorlevel 1 (
    echo Aucune erreur trouvee dans le fichier
    del temp_errors.txt 2>nul
    pause
    exit /b 0
)

echo Erreurs trouvees. Analyse...
echo.

echo [2/3] Codes de reponse HTTP...
findstr /C:"false" "%JTL_FILE%" | findstr /R "200 404 500" >nul
echo.

echo [3/3] Messages d'erreur uniques...
echo.
echo Les 10 premiers messages d'erreur:
echo ----------------------------------------
for /f "tokens=*" %%a in ('findstr /C:"false" "%JTL_FILE%" ^| head -n 10') do (
    echo %%a
)
echo.

echo Pour voir toutes les erreurs, ouvrez le fichier dans un editeur de texte
echo et cherchez les lignes contenant "false"
echo.

del temp_errors.txt 2>nul

echo ========================================
echo   Analyse terminee
echo ========================================
echo.
echo IMPORTANT: Pour un diagnostic complet, ouvrez JMeter GUI:
echo   1. C:\JMeter\bin\jmeter.bat
echo   2. File -^> Open -^> 1_read_heavy.jmx
echo   3. Ajouter View Results Tree
echo   4. Lancer avec 1 thread
echo   5. Regarder la premiere requete pour voir l'erreur exacte
echo.
pause

