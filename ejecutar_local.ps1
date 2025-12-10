# Script para ejecutar la aplicación Flutter web localmente
Write-Host "🚀 Iniciando aplicación Flutter web..." -ForegroundColor Green

# Navegar al directorio del proyecto
Set-Location $PSScriptRoot

# Verificar que Flutter está instalado
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterPath) {
    Write-Host "❌ Flutter no está instalado o no está en el PATH" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Flutter encontrado" -ForegroundColor Green

# Compilar si es necesario
if (-not (Test-Path "build\web\index.html")) {
    Write-Host "📦 Compilando aplicación..." -ForegroundColor Yellow
    flutter build web --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al compilar" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Aplicación compilada" -ForegroundColor Green

# Intentar ejecutar con Flutter
Write-Host "🌐 Iniciando servidor en http://localhost:8080" -ForegroundColor Cyan
Write-Host "Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

# Abrir navegador después de un segundo
Start-Sleep -Seconds 2
Start-Process "http://localhost:8080"

# Ejecutar Flutter
flutter run -d chrome --web-port=8080







