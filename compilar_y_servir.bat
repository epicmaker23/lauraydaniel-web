@echo off
echo Compilando aplicacion Flutter...
flutter build web --release --no-wasm-dry-run --dart-define=APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1 --dart-define=APPWRITE_PROJECT_ID=6938ac61002541a7230e --dart-define=APPWRITE_API_KEY=a4d728408e6eed5c09ce47e9d2105ab02f66c4e677cbd06c3c7513617974d6bbbaa2000dfb8bf465bf7f7df8e61084f621e709f1c7393e3f850977c20d47a33885141181858afd1b7c55fb9161f9bd4aa64da094ad30fd4509a206f9da815c4b9b1a9de9e9683a0975ad80eabb2403f1888bec5c8a1798df3638bed8f5690420 --dart-define=APPWRITE_DATABASE_ID=boda --dart-define=APPWRITE_RSVP_COLLECTION_ID=rsvps --dart-define=APPWRITE_GALLERY_COLLECTION_ID=gallery_photos --dart-define=APPWRITE_STORAGE_ID=6938b171003af1f91b94
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Compilacion completada exitosamente!
    echo Iniciando servidor web en http://localhost:8080
    echo.
    python -m http.server 8080 --directory build/web
) else (
    echo.
    echo Error en la compilacion. Revisa los mensajes anteriores.
    pause
)





