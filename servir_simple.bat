@echo off
echo ========================================
echo   Servidor HTTP Simple - Flutter Web
echo ========================================
echo.

cd /d "%~dp0\build\web"

echo Servidor iniciado en http://localhost:8080
echo.
echo Abriendo navegador...
timeout /t 2 /nobreak >nul
start http://localhost:8080

echo.
echo Serviendo archivos desde: %CD%
echo Presiona Ctrl+C para detener
echo.

python -m http.server 8080

pause







