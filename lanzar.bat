@echo off
echo ========================================
echo   Iniciando servidor Flutter Web
echo ========================================
echo.

cd /d "%~dp0"

echo Abriendo navegador...
start http://localhost:8080

echo.
echo Iniciando servidor...
echo Presiona Ctrl+C para detener
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0servir.ps1"

pause







