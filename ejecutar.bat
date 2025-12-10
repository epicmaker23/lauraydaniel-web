@echo off
echo ========================================
echo   Iniciando aplicacion Flutter Web
echo ========================================
echo.

cd /d "%~dp0"

echo Compilando aplicacion...
call flutter build web --release
if errorlevel 1 (
    echo ERROR: Fallo al compilar
    pause
    exit /b 1
)

echo.
echo Iniciando servidor en http://localhost:8080
echo.
echo Abriendo navegador...
start http://localhost:8080

echo.
echo Ejecutando Flutter...
call flutter run -d chrome --web-port=8080

pause







