# Servidor HTTP simple para servir la aplicación Flutter web compilada
Write-Host "🚀 Iniciando servidor HTTP en http://localhost:8080" -ForegroundColor Green

$port = 8080
$url = "http://localhost:$port/"

# Crear listener HTTP
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "✅ Servidor iniciado en $url" -ForegroundColor Green
Write-Host "📂 Sirviendo archivos desde: $PSScriptRoot\build\web" -ForegroundColor Cyan
Write-Host "🌐 Abriendo navegador..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

# Abrir navegador
Start-Process $url

# Directorio base de los archivos
$baseDir = Join-Path $PSScriptRoot "build\web"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Obtener ruta del archivo solicitado
        $localPath = $request.Url.LocalPath
        
        # Si es la raíz, servir index.html
        if ($localPath -eq "/" -or $localPath -eq "") {
            $localPath = "/index.html"
        }
        
        # Construir ruta completa del archivo
        $filePath = Join-Path $baseDir $localPath.TrimStart('/').Replace('/', '\')
        
        Write-Host "$($request.HttpMethod) $localPath" -ForegroundColor Gray
        
        # Verificar si el archivo existe
        if (Test-Path $filePath -PathType Leaf) {
            try {
                $content = [System.IO.File]::ReadAllBytes($filePath)
                
                # Determinar tipo MIME
                $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
                $mimeType = switch ($extension) {
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
                    default { "application/octet-stream" }
                }
                
                $response.ContentType = $mimeType
                $response.ContentLength64 = $content.Length
                $response.StatusCode = 200
                
                # Headers CORS para desarrollo
                $response.Headers.Add("Access-Control-Allow-Origin", "*")
                
                $response.OutputStream.Write($content, 0, $content.Length)
                $response.OutputStream.Close()
            } catch {
                Write-Host "Error leyendo archivo: $_" -ForegroundColor Red
                $response.StatusCode = 500
                $response.Close()
            }
        } else {
            # Si no existe, intentar servir index.html (para SPA routing)
            $indexPath = Join-Path $baseDir "index.html"
            if (Test-Path $indexPath) {
                $content = [System.IO.File]::ReadAllBytes($indexPath)
                $response.ContentType = "text/html; charset=utf-8"
                $response.ContentLength64 = $content.Length
                $response.StatusCode = 200
                $response.Headers.Add("Access-Control-Allow-Origin", "*")
                $response.OutputStream.Write($content, 0, $content.Length)
                $response.OutputStream.Close()
                Write-Host "  → Redirigido a index.html (SPA)" -ForegroundColor Gray
            } else {
                Write-Host "  → 404 Not Found" -ForegroundColor Red
                $response.StatusCode = 404
                $response.Close()
            }
        }
    }
} finally {
    $listener.Stop()
    Write-Host "`n🛑 Servidor detenido" -ForegroundColor Yellow
}







