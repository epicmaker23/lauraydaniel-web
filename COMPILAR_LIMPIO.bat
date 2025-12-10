@echo off
echo ========================================
echo   COMPILACION LIMPIA - Flutter Web
echo ========================================
echo.

echo Paso 1: Eliminando build anterior...
if exist build rmdir /S /Q build
echo OK: Build eliminado
echo.

echo Paso 2: Limpiando cache de Flutter...
flutter clean
echo OK: Cache limpiado
echo.

echo Paso 3: Obteniendo dependencias...
flutter pub get
echo OK: Dependencias obtenidas
echo.

echo Paso 4: Compilando con variables de Appwrite...
echo.
flutter build web --release ^
  --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1" ^
  --dart-define="APPWRITE_PROJECT_ID=6938ac61002541a7230e" ^
  --dart-define="APPWRITE_API_KEY=a4d728408e6eed5c09ce47e9d2105ab02f66c4e677cbd06c3c7513617974d6bbbaa2000dfb8bf465bf7f7df8e61084f621e709f1c7393e3f850977c20d47a33885141181858afd1b7c55fb9161f9bd4aa64da094ad30fd4509a206f9da815c4b9b1a9de9e9683a0975ad80eabb2403f1888bec5c8a1798df3638bed8f5690420" ^
  --dart-define="APPWRITE_DATABASE_ID=boda" ^
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=rsvps" ^
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=gallery_photos" ^
  --dart-define="APPWRITE_STORAGE_ID=6938b171003af1f91b94"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo   ERROR EN LA COMPILACION!
    echo ========================================
    pause
    exit /b 1
)

echo.
echo ========================================
echo   VERIFICANDO COMPILACION...
echo ========================================
echo.

if not exist build\web\main.dart.js (
    echo ERROR: main.dart.js no se genero!
    pause
    exit /b 1
)

echo Verificando que NO contiene Supabase...
findstr /C:"supabase.epicmaker" build\web\main.dart.js >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ERROR: Todavia contiene referencias a Supabase!
    echo.
    echo Esto significa que hay codigo antiguo en el build.
    echo Intenta eliminar manualmente la carpeta build y recompilar.
    pause
    exit /b 1
) else (
    echo OK: No contiene referencias a Supabase
)

echo Verificando que contiene api.lauraydaniel.es...
findstr /C:"api.lauraydaniel.es" build\web\main.dart.js >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo OK: Contiene api.lauraydaniel.es
) else (
    echo ADVERTENCIA: No contiene api.lauraydaniel.es
    echo Las variables de entorno pueden no haberse pasado correctamente.
)

echo.
echo ========================================
echo   COMPILACION COMPLETADA!
echo ========================================
echo.
echo Ejecuta: .\lanzar.bat
echo.
pause







