@echo off
echo ========================================
echo   Nettoyage des Resultats JMeter
echo ========================================
echo.

set TEST_DIR=%~dp0

echo Suppression des fichiers de resultats...
if exist "%TEST_DIR%results_read_heavy.jtl" (
    del /F /Q "%TEST_DIR%results_read_heavy.jtl"
    echo [OK] results_read_heavy.jtl supprime
)

if exist "%TEST_DIR%results_join_filter.jtl" (
    del /F /Q "%TEST_DIR%results_join_filter.jtl"
    echo [OK] results_join_filter.jtl supprime
)

if exist "%TEST_DIR%results_mixed.jtl" (
    del /F /Q "%TEST_DIR%results_mixed.jtl"
    echo [OK] results_mixed.jtl supprime
)

if exist "%TEST_DIR%results_heavy_body.jtl" (
    del /F /Q "%TEST_DIR%results_heavy_body.jtl"
    echo [OK] results_heavy_body.jtl supprime
)

echo.
echo Suppression des rapports HTML...
if exist "%TEST_DIR%report_read_heavy" (
    rmdir /S /Q "%TEST_DIR%report_read_heavy"
    echo [OK] report_read_heavy supprime
)

if exist "%TEST_DIR%report_join_filter" (
    rmdir /S /Q "%TEST_DIR%report_join_filter"
    echo [OK] report_join_filter supprime
)

if exist "%TEST_DIR%report_mixed" (
    rmdir /S /Q "%TEST_DIR%report_mixed"
    echo [OK] report_mixed supprime
)

if exist "%TEST_DIR%report_heavy_body" (
    rmdir /S /Q "%TEST_DIR%report_heavy_body"
    echo [OK] report_heavy_body supprime
)

echo.
echo ========================================
echo   Nettoyage termine
echo ========================================
echo.
pause

