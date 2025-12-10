@echo off
echo ========================================
echo   Servidor HTTP - Flutter Web
echo ========================================
echo.

cd /d "%~dp0"

powershell -ExecutionPolicy Bypass -File "%~dp0servir.ps1"

pause







