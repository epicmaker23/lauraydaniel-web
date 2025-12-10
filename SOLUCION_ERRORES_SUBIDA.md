# Solución de Errores de Subida de Archivos

## Problemas Identificados

### 1. Error CORS (Cross-Origin Resource Sharing)
**Síntoma:** El navegador bloquea la solicitud con el mensaje:
```
Access to fetch at 'https://api.lauraydaniel.es/v1/storage/...' from origin 'http://localhost:8080' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present
```

**Causa:** Appwrite no está configurado para aceptar solicitudes desde `localhost:8080`.

**Solución:**
1. Accede al panel de administración de Appwrite: `https://api.lauraydaniel.es`
2. Ve a **Settings** → **Platforms**
3. Haz clic en **Add Platform** → **Web App**
4. Ingresa la URL: `http://localhost:8080`
5. Guarda los cambios
6. Si también usas producción, agrega tu dominio de producción (ej: `https://lauraydaniel.es`)

### 2. Error 502 Bad Gateway
**Síntoma:** El servidor responde con error 502 después de intentar subir el archivo.

**Causas posibles:**
- El archivo es demasiado grande para los límites configurados en Appwrite
- Timeout del servidor durante la subida
- Problemas de configuración en el servidor/proxy de Appwrite

**Soluciones:**

#### A. Configurar límite de tamaño de archivo en Appwrite

Si tienes acceso al `docker-compose.yml` de Appwrite, agrega o modifica:

```yaml
services:
  appwrite:
    environment:
      _APP_STORAGE_LIMIT: "200000000"  # ~200 MB en bytes
```

Luego reinicia Appwrite:
```bash
docker-compose down
docker-compose up -d
```

#### B. Verificar configuración del servidor/proxy

Si Appwrite está detrás de un proxy (nginx, Apache, etc.), verifica:
- Límites de tamaño de archivo (`client_max_body_size` en nginx)
- Timeouts (`proxy_read_timeout`, `proxy_send_timeout`)
- Límites de memoria del servidor

#### C. Verificar logs de Appwrite

Revisa los logs del contenedor de Appwrite para ver errores específicos:
```bash
docker logs appwrite
```

### 3. Archivos muy grandes (>50MB)

Para archivos muy grandes, considera:
- Comprimir videos antes de subirlos
- Usar un servicio de almacenamiento especializado (S3, Cloud Storage)
- Implementar subida por chunks (requiere cambios en el código)

## Verificación

Después de aplicar las soluciones:

1. **CORS:** Intenta subir un archivo pequeño (ej: una imagen de 1MB). Si funciona, CORS está resuelto.
2. **502:** Intenta subir el archivo grande nuevamente. Si sigue fallando, revisa los logs del servidor.

## Notas Adicionales

- El código ahora muestra mensajes de error más descriptivos que incluyen instrucciones específicas
- Los timeouts están configurados a 10 minutos para archivos grandes
- El progreso de subida se muestra visualmente durante el proceso







