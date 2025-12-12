# Script para compilar la aplicación Flutter en modo release con variables de Appwrite
# IMPORTANTE: Reemplaza los valores de las variables con tus credenciales reales de Appwrite

$APPWRITE_ENDPOINT = "https://api.lauraydaniel.es/v1"
$APPWRITE_PROJECT_ID = "6938ac61002541a7230e"
$APPWRITE_API_KEY = "a4d728408e6eed5c09ce47e9d2105ab02f66c4e677cbd06c3c7513617974d6bbbaa2000dfb8bf465bf7f7df8e61084f621e709f1c7393e3f850977c20d47a33885141181858afd1b7c55fb9161f9bd4aa64da094ad30fd4509a206f9da815c4b9b1a9de9e9683a0975ad80eabb2403f1888bec5c8a1798df3638bed8f5690420"
$APPWRITE_DATABASE_ID = "boda"
$APPWRITE_RSVP_COLLECTION_ID = "rsvps"
$APPWRITE_GALLERY_COLLECTION_ID = "gallery_photos"
$APPWRITE_STORAGE_ID = "6938b171003af1f91b94"

Write-Host "Compilando aplicación en modo release..." -ForegroundColor Green

flutter build web --release --no-wasm-dry-run --pwa-strategy=none `
  --dart-define=APPWRITE_ENDPOINT="$APPWRITE_ENDPOINT" `
  --dart-define=APPWRITE_PROJECT_ID="$APPWRITE_PROJECT_ID" `
  --dart-define=APPWRITE_API_KEY="$APPWRITE_API_KEY" `
  --dart-define=APPWRITE_DATABASE_ID="$APPWRITE_DATABASE_ID" `
  --dart-define=APPWRITE_RSVP_COLLECTION_ID="$APPWRITE_RSVP_COLLECTION_ID" `
  --dart-define=APPWRITE_GALLERY_COLLECTION_ID="$APPWRITE_GALLERY_COLLECTION_ID" `
  --dart-define=APPWRITE_STORAGE_ID="$APPWRITE_STORAGE_ID"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nCompilación completada exitosamente!" -ForegroundColor Green
    Write-Host "Los archivos compilados están en: build/web/" -ForegroundColor Cyan
    Write-Host "`nPara subir al servidor, copia el contenido de build/web/ a tu servidor web." -ForegroundColor Yellow
} else {
    Write-Host "`nError en la compilación. Revisa los mensajes anteriores." -ForegroundColor Red
    exit $LASTEXITCODE
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nCompilación completada exitosamente!" -ForegroundColor Green
    Write-Host "Los archivos compilados están en: build/web/" -ForegroundColor Cyan
} else {
    Write-Host "`nError en la compilación. Revisa los mensajes anteriores." -ForegroundColor Red
    exit $LASTEXITCODE
}


