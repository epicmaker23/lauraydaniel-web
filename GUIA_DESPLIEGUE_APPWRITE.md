# 🚀 Guía de Despliegue - Flutter Web con Appwrite

## 📋 Resumen del Proceso

Esta guía te ayudará a desplegar tu aplicación Flutter web que usa Appwrite como backend.

---

## 🔧 Paso 1: Compilar la Aplicación Flutter

En tu máquina local (Windows), ejecuta:

```powershell
cd C:\Users\Maza\Documents\Flutter\lauraydaniel_web

flutter build web --release `
  --dart-define="APPWRITE_ENDPOINT=https://tu-servidor-appwrite.com/v1" `
  --dart-define="APPWRITE_PROJECT_ID=tu_project_id" `
  --dart-define="APPWRITE_API_KEY=tu_api_key" `
  --dart-define="APPWRITE_DATABASE_ID=tu_database_id" `
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=tu_rsvp_collection_id" `
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=tu_gallery_collection_id" `
  --dart-define="APPWRITE_STORAGE_ID=tu_storage_id"
```

**⚠️ IMPORTANTE:** Reemplaza todos los valores `tu_*` con los valores reales de tu Appwrite.

Esto generará los archivos estáticos en `build/web/`

---

## 📦 Paso 2: Subir Archivos al Servidor

### Opción A: Usando SCP (desde PowerShell)

```powershell
# Comprimir la carpeta build/web
Compress-Archive -Path .\build\web\* -DestinationPath .\web-build.zip

# Subir al servidor (reemplaza con tus credenciales)
scp .\web-build.zip usuario@tu-servidor.com:/home/usuario/
```

### Opción B: Usando Git

Si tienes un repositorio Git configurado en el servidor:

```powershell
git add build/web
git commit -m "Build producción"
git push
```

Luego en el servidor:
```bash
git pull
```

### Opción C: Usando FTP/SFTP

Usa FileZilla, WinSCP o similar para subir la carpeta `build/web` completa.

---

## 🖥️ Paso 3: Configurar el Servidor

### 3.1. Conectarse al Servidor

```bash
ssh usuario@tu-servidor.com
```

### 3.2. Crear Directorio para la Aplicación

```bash
# Crear directorio (ajusta la ruta según tu configuración)
sudo mkdir -p /var/www/lauraydaniel-web
sudo chown -R $USER:$USER /var/www/lauraydaniel-web
cd /var/www/lauraydaniel-web
```

### 3.3. Extraer/Colocar Archivos

Si usaste SCP:
```bash
unzip ~/web-build.zip -d /var/www/lauraydaniel-web/build/web/
```

Si usaste Git:
```bash
git clone tu-repositorio.git .
# Los archivos ya están en build/web
```

Si usaste FTP/SFTP:
```bash
# Los archivos ya deberían estar en el servidor
# Asegúrate de que estén en /var/www/lauraydaniel-web/build/web/
```

---

## 🐳 Paso 4: Configurar Docker (si usas gostatic)

Si tu servidor usa `gostatic` según el PDF, crea o actualiza `docker-compose.yml`:

```bash
cd /var/www/lauraydaniel-web
nano docker-compose.yml
```

Contenido:

```yaml
services:
  lauraydaniel-web:
    image: pierrezemb/gostatic
    container_name: lauraydaniel-web
    restart: unless-stopped
    command: ["-port","8043","-fallback","/index.html","/srv/http"]
    volumes:
      - ./build/web:/srv/http
    ports:
      - "127.0.0.1:8043:8043"  # Solo localhost (Nginx hará proxy)
```

Iniciar:
```bash
docker-compose up -d
```

---

## 🌐 Paso 5: Configurar Nginx (Proxy Reverso)

### 5.1. Crear Configuración de Nginx

```bash
sudo nano /etc/nginx/sites-available/lauraydaniel-web
```

Contenido:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name lauraydaniel.es www.lauraydaniel.es;

    # Si tienes SSL, descomenta estas líneas después de configurar Let's Encrypt
    # listen 443 ssl http2;
    # listen [::]:443 ssl http2;
    # ssl_certificate /etc/letsencrypt/live/lauraydaniel.es/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/lauraydaniel.es/privkey.pem;

    # Redirigir HTTP a HTTPS (si tienes SSL)
    # return 301 https://$server_name$request_uri;

    # Si no tienes SSL aún, usa esto:
    location / {
        proxy_pass http://127.0.0.1:8043;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Archivos estáticos con caché
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://127.0.0.1:8043;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 5.2. Habilitar el Sitio

```bash
# Crear enlace simbólico
sudo ln -s /etc/nginx/sites-available/lauraydaniel-web /etc/nginx/sites-enabled/

# Verificar configuración
sudo nginx -t

# Recargar Nginx
sudo systemctl reload nginx
```

---

## 🔒 Paso 6: Configurar SSL con Let's Encrypt (Recomendado)

```bash
# Instalar Certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx -y

# Obtener certificado SSL
sudo certbot --nginx -d lauraydaniel.es -d www.lauraydaniel.es

# El certificado se renovará automáticamente
```

Después de esto, Nginx se configurará automáticamente para usar HTTPS.

---

## ✅ Paso 7: Verificar que Todo Funciona

1. **Verificar Docker:**
   ```bash
   docker ps | grep lauraydaniel-web
   docker-compose logs lauraydaniel-web
   ```

2. **Verificar Nginx:**
   ```bash
   sudo systemctl status nginx
   sudo nginx -t
   ```

3. **Probar la aplicación:**
   - Abre `http://tu-dominio.com` o `https://tu-dominio.com`
   - Verifica que la página principal carga
   - Prueba la ruta `/formulario`
   - Prueba enviar un formulario de prueba

---

## 🔄 Paso 8: Actualizar la Aplicación (Futuras Actualizaciones)

Cuando necesites actualizar:

1. **En tu máquina local:**
   ```powershell
   flutter build web --release `
     --dart-define="APPWRITE_ENDPOINT=..." `
     # ... resto de variables
   ```

2. **Subir archivos al servidor** (SCP, Git, o FTP)

3. **En el servidor:**
   ```bash
   cd /var/www/lauraydaniel-web
   docker-compose restart
   # O si cambiaste archivos:
   docker-compose down
   docker-compose up -d
   ```

---

## 🛠️ Solución de Problemas

### Error: Puerto 8043 ya en uso
```bash
sudo lsof -i :8043
# Cambiar el puerto en docker-compose.yml si es necesario
```

### Error: No se ven los cambios
- Limpiar caché del navegador (Ctrl+Shift+R)
- Reiniciar Docker: `docker-compose restart`

### Error: Ruta /formulario no funciona
- Verifica que `docker-compose.yml` tenga `-fallback` configurado
- Verifica que Nginx esté configurado correctamente
- Revisa logs: `docker-compose logs`

### Error: CORS en Appwrite
- Ve al panel de Appwrite
- Settings → Domains
- Añade tu dominio (ej: `lauraydaniel.es`)
- Verifica permisos de las colecciones

---

## 📝 Checklist Final

- [ ] Aplicación compilada con variables de entorno correctas
- [ ] Archivos subidos al servidor
- [ ] `docker-compose.yml` creado y configurado
- [ ] Contenedor Docker corriendo
- [ ] Nginx configurado y funcionando
- [ ] Dominio apuntando al servidor (DNS)
- [ ] SSL configurado (opcional pero recomendado)
- [ ] Aplicación accesible en `http://tu-dominio.com`
- [ ] Ruta `/formulario` funciona
- [ ] Formulario puede enviar datos a Appwrite
- [ ] CORS/Dominios configurados en Appwrite

---

## ❓ ¿Necesitas Ayuda?

Si el PDF tiene instrucciones específicas diferentes, compárteme:
1. ¿Qué dice el PDF sobre cómo servir los archivos estáticos?
2. ¿Usa Docker, Nginx directamente, o otro método?
3. ¿Hay alguna configuración especial de Appwrite mencionada?

Con esa información puedo ajustar la guía exactamente según tu configuración.







