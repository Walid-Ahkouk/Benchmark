@echo off
echo ========================================
echo   Verification Backend Stable
echo ========================================
echo.

set SUCCESS=0
set FAILED=0

echo Test de stabilite du backend (10 requetes)...
echo.

for /L %%i in (1,1,10) do (
    echo [Test %%i/10] GET /api/items?page=1^&size=10
    curl.exe -s -o nul -w "%%{http_code}" --connect-timeout 5 --max-time 10 "http://localhost:8080/api/items?page=1&size=10" > temp_code.txt 2>nul
    set /p HTTP_CODE=<temp_code.txt
    del temp_code.txt 2>nul
    
    if "!HTTP_CODE!"=="200" (
        echo   [OK] HTTP 200
        set /a SUCCESS+=1
    ) else (
        echo   [ERREUR] Code: !HTTP_CODE!
        set /a FAILED+=1
    )
    timeout /t 1 /nobreak >nul
)

echo.
echo ========================================
echo   Resultats
echo ========================================
echo Reussites: %SUCCESS%/10
echo Echecs: %FAILED%/10
echo.

if %FAILED% GTR 0 (
    echo [ATTENTION] Le backend n'est pas stable !
    echo            %FAILED% requetes sur 10 ont echoue.
    echo.
    echo Solutions:
    echo   1. Verifier que le backend est bien demarre
    echo   2. Verifier les logs du backend pour les erreurs
    echo   3. Redemarrer le backend
    echo   4. Verifier que le port 8080 n'est pas utilise par un autre processus
    echo.
) else (
    echo [OK] Le backend est stable - Toutes les requetes ont reussi
    echo.
)

pause

