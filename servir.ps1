# Servidor HTTP simple usando PowerShell (sin necesidad de Python)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Servidor HTTP - Flutter Web" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$port = 8080
$url = "http://localhost:$port/"

# Directorio base
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseDir = Join-Path $scriptDir "build\web"

if (-not (Test-Path $baseDir)) {
    Write-Host "ERROR: No se encuentra el directorio build\web" -ForegroundColor Red
    Write-Host "Ejecuta primero: flutter build web --release" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "Servidor iniciado en: $url" -ForegroundColor Green
Write-Host "Directorio: $baseDir" -ForegroundColor Gray
Write-Host ""
Write-Host "Abriendo navegador..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
Start-Process $url
Write-Host ""
Write-Host "Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

# Crear listener HTTP
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)

try {
    $listener.Start()
    Write-Host "Servidor activo. Esperando peticiones..." -ForegroundColor Green
    Write-Host ""
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Obtener ruta
        $localPath = $request.Url.LocalPath
        if ($localPath -eq "/" -or $localPath -eq "") {
            $localPath = "/index.html"
        }
        
        # Construir ruta del archivo
        $relativePath = $localPath.TrimStart('/').Replace('/', '\')
        $filePath = Join-Path $baseDir $relativePath
        
        Write-Host "$($request.HttpMethod) $localPath" -ForegroundColor Gray
        
        # Verificar si existe
        if (Test-Path $filePath -PathType Leaf) {
            try {
                $content = [System.IO.File]::ReadAllBytes($filePath)
                
                # Tipo MIME
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $mimeType = switch ($ext) {
                    ".html" { "text/html; charset=utf-8" }
                    ".js" { "application/javascript; charset=utf-8" }
                    ".css" { "text/css; charset=utf-8" }
                    ".json" { "application/json; charset=utf-8" }
                    ".png" { "image/png" }
                    ".jpg" { "image/jpeg" }
                    ".jpeg" { "image/jpeg" }
                    ".gif" { "image/gif" }
                    ".svg" { "image/svg+xml" }
                    ".ico" { "image/x-icon" }
                    ".woff" { "font/woff" }
                    ".woff2" { "font/woff2" }
                    ".ttf" { "font/ttf" }
                    ".wasm" { "application/wasm" }
                    ".bin" { "application/octet-stream" }
                    default { "application/octet-stream" }
                }
                
                $response.ContentType = $mimeType
                $response.ContentLength64 = $content.Length
                $response.StatusCode = 200
                $response.Headers.Add("Access-Control-Allow-Origin", "*")
                
                # Headers anti-caché para HTML y JS
                if ($ext -eq ".html" -or $ext -eq ".js") {
                    $response.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate")
                    $response.Headers.Add("Pragma", "no-cache")
                    $response.Headers.Add("Expires", "0")
                }
                
                $response.OutputStream.Write($content, 0, $content.Length)
                $response.OutputStream.Close()
            } catch {
                Write-Host "  ERROR: $_" -ForegroundColor Red
                $response.StatusCode = 500
                $response.Close()
            }
        } else {
            # Para SPA: servir index.html si no existe el archivo
            $indexPath = Join-Path $baseDir "index.html"
            if (Test-Path $indexPath) {
                $content = [System.IO.File]::ReadAllBytes($indexPath)
                $response.ContentType = "text/html; charset=utf-8"
                $response.ContentLength64 = $content.Length
                $response.StatusCode = 200
                $response.Headers.Add("Access-Control-Allow-Origin", "*")
                $response.OutputStream.Write($content, 0, $content.Length)
                $response.OutputStream.Close()
                Write-Host "  -> index.html (SPA routing)" -ForegroundColor DarkGray
            } else {
                Write-Host "  -> 404 Not Found" -ForegroundColor Red
                $response.StatusCode = 404
                $response.Close()
            }
        }
    }
} catch {
    Write-Host "`nERROR: $_" -ForegroundColor Red
} finally {
    $listener.Stop()
    Write-Host "`nServidor detenido." -ForegroundColor Yellow
}

