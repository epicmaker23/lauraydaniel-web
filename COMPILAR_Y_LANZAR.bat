@echo off
setlocal

echo ========================================
echo   Compilando y Lanzando App
echo ========================================
echo.

REM Asegúrate de estar en el directorio del proyecto
cd /d "%~dp0"

REM Compilar con las variables de Appwrite
echo Compilando con variables de Appwrite...
flutter build web --release ^
    --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1" ^
    --dart-define="APPWRITE_PROJECT_ID=6938ac61002541a7230e" ^
    --dart-define="APPWRITE_API_KEY=a4d728408e6eed5c09ce47e9d2105ab02f66c4e677cbd06c3c7513617974d6bbbaa2000dfb8bf465bf7f7df8e61084f621e709f1c7393e3f850977c20d47a33885141181858afd1b7c55fb9161f9bd4aa64da094ad30fd4509a206f9da815c4b9b1a9de9e9683a0975ad80eabb2403f1888bec5c8a1798df3638bed8f5690420" ^
    --dart-define="APPWRITE_DATABASE_ID=boda" ^
    --dart-define="APPWRITE_RSVP_COLLECTION_ID=rsvps" ^
    --dart-define="APPWRITE_GALLERY_COLLECTION_ID=gallery_photos" ^
    --dart-define="APPWRITE_STORAGE_ID=6938b171003af1f91b94"

if %errorlevel% neq 0 (
    echo.
    echo ERROR: La compilación ha fallado.
    pause
    exit /b %errorlevel%
)

echo.
echo Compilación completada. Lanzando servidor...
echo.

REM Detener procesos anteriores
taskkill /F /IM powershell.exe /FI "WINDOWTITLE eq *servir*" 2>nul
timeout /t 1 /nobreak >nul

REM Lanzar servidor y abrir navegador
start http://localhost:8080/admin
timeout /t 1 /nobreak >nul
powershell -ExecutionPolicy Bypass -File servir.ps1

echo.
echo ========================================
echo   Aplicación lanzada en http://localhost:8080/admin
echo ========================================
echo.

endlocal





