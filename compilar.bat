@echo off
echo ========================================
echo   Compilando Flutter Web con Appwrite
echo ========================================
echo.

flutter clean
echo.
echo Limpiando cache...
echo.

flutter pub get
echo.
echo Obteniendo dependencias...
echo.

echo Compilando con variables de Appwrite...
echo.

flutter build web --release ^
  --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1" ^
  --dart-define="APPWRITE_PROJECT_ID=6938ac61002541a7230e" ^
  --dart-define="APPWRITE_API_KEY=a4d728408e6eed5c09ce47e9d2105ab02f66c4e677cbd06c3c7513617974d6bbbaa2000dfb8bf465bf7f7df8e61084f621e709f1c7393e3f850977c20d47a33885141181858afd1b7c55fb9161f9bd4aa64da094ad30fd4509a206f9da815c4b9b1a9de9e9683a0975ad80eabb2403f1888bec5c8a1798df3638bed8f5690420" ^
  --dart-define="APPWRITE_DATABASE_ID=boda" ^
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=rsvps" ^
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=gallery_photos" ^
  --dart-define="APPWRITE_STORAGE_ID=6938b171003af1f91b94"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   Compilacion exitosa!
    echo ========================================
    echo.
    echo Verificando que no hay referencias a Supabase...
    findstr /C:"supabase.epicmaker" build\web\main.dart.js >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo ERROR: Todavia contiene referencias a Supabase!
    ) else (
        echo OK: No contiene referencias a Supabase
    )
    echo.
    echo Verificando que contiene api.lauraydaniel.es...
    findstr /C:"api.lauraydaniel.es" build\web\main.dart.js >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo OK: Contiene api.lauraydaniel.es
    ) else (
        echo ADVERTENCIA: No contiene api.lauraydaniel.es
    )
    echo.
    echo Ejecuta: .\lanzar.bat
) else (
    echo.
    echo ========================================
    echo   ERROR en la compilacion!
    echo ========================================
)

pause







