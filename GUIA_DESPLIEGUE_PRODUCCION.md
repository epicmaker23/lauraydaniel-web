# 🚀 Guía de Despliegue en Producción - Laura & Daniel Web

## 📋 Requisitos Previos

- ✅ Servidor Ubuntu configurado según el PDF
- ✅ Docker y Docker Compose instalados
- ✅ Appwrite configurado y funcionando según el PDF
- ✅ Flutter SDK instalado en tu máquina local
- ✅ Acceso SSH al servidor

---

## 🔧 Paso 1: Compilar la Aplicación Flutter para Producción

En tu máquina local (Windows), ejecuta:

```powershell
# Navega al directorio del proyecto
cd C:\Users\Maza\Documents\Flutter\lauraydaniel_web

# Compila la aplicación con las variables de entorno de Appwrite
flutter build web --release `
  --dart-define="APPWRITE_ENDPOINT=https://tu-servidor.com/v1" `
  --dart-define="APPWRITE_PROJECT_ID=tu_project_id" `
  --dart-define="APPWRITE_API_KEY=tu_api_key" `
  --dart-define="APPWRITE_DATABASE_ID=tu_database_id" `
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=tu_rsvp_collection_id" `
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=tu_gallery_collection_id" `
  --dart-define="APPWRITE_STORAGE_ID=tu_storage_id"
```

**⚠️ IMPORTANTE:**
- Reemplaza `https://tu-servidor.com/v1` con la URL real de tu servidor Appwrite (debe terminar en `/v1`)
- Reemplaza `tu_project_id` con el ID de tu proyecto en Appwrite
- Reemplaza `tu_api_key` con tu API Key de Appwrite (puedes obtenerla en Settings → API Keys)
- Reemplaza `tu_database_id` con el ID de tu base de datos en Appwrite
- Reemplaza los IDs de colecciones y storage con los valores reales de tu configuración

**Ejemplo real:**
```powershell
flutter build web --release `
  --dart-define="APPWRITE_ENDPOINT=https://appwrite.lauraydaniel.es/v1" `
  --dart-define="APPWRITE_PROJECT_ID=64a1b2c3d4e5f6g7h8i9j0k" `
  --dart-define="APPWRITE_API_KEY=abc123xyz789..." `
  --dart-define="APPWRITE_DATABASE_ID=64a1b2c3d4e5f6g7h8i9j0l" `
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=64a1b2c3d4e5f6g7h8i9j0m" `
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=64a1b2c3d4e5f6g7h8i9j0n" `
  --dart-define="APPWRITE_STORAGE_ID=64a1b2c3d4e5f6g7h8i9j0o"
```

Esto generará los archivos estáticos en `build/web/`

---

## 📦 Paso 2: Preparar Archivos para el Servidor

### Opción A: Usando SCP (desde PowerShell)

```powershell
# Comprimir la carpeta build/web
Compress-Archive -Path .\build\web\* -DestinationPath .\web-build.zip

# Subir al servidor (reemplaza usuario@servidor con tus credenciales)
scp .\web-build.zip usuario@tu-servidor.com:/home/usuario/
```

### Opción B: Usando Git (si tienes repositorio)

```powershell
# Commit y push de los archivos compilados (si los tienes en git)
git add build/web
git commit -m "Build producción"
git push
```

### Opción C: Usando FTP/SFTP

Usa un cliente como FileZilla o WinSCP para subir la carpeta `build/web` completa al servidor.

---

## 🖥️ Paso 3: Configurar el Servidor

### 3.1. Conectarse al Servidor

```bash
ssh usuario@tu-servidor.com
```

### 3.2. Crear Directorio para la Aplicación

```bash
# Crear directorio para la aplicación
sudo mkdir -p /var/www/lauraydaniel-web
sudo chown -R $USER:$USER /var/www/lauraydaniel-web
cd /var/www/lauraydaniel-web
```

### 3.3. Extraer/Subir Archivos

Si usaste SCP:
```bash
# Descomprimir
unzip ~/web-build.zip -d /var/www/lauraydaniel-web/build/web/
```

Si usaste Git:
```bash
git clone tu-repositorio.git .
cd build/web
# Los archivos ya están aquí
```

Si usaste FTP/SFTP:
```bash
# Los archivos ya deberían estar en el servidor
# Asegúrate de que estén en /var/www/lauraydaniel-web/build/web/
```

### 3.4. Crear docker-compose.yml en el Servidor

```bash
cd /var/www/lauraydaniel-web
nano docker-compose.yml
```

Pega el siguiente contenido:

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
      - "127.0.0.1:8043:8043"  # Solo escucha en localhost
    networks:
      - web-network

networks:
  web-network:
    external: true  # Asume que tienes una red Docker externa
    # O elimina esta sección si no usas red externa
```

**Nota:** El puerto `8043` solo escucha en `127.0.0.1` (localhost) porque Nginx hará de proxy inverso.

---

## 🌐 Paso 4: Configurar Nginx (Proxy Reverso)

### 4.1. Crear Configuración de Nginx

```bash
sudo nano /etc/nginx/sites-available/lauraydaniel-web
```

Pega la siguiente configuración:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name lauraydaniel.es www.lauraydaniel.es;

    # Redirigir HTTP a HTTPS (si tienes SSL)
    # return 301 https://$server_name$request_uri;

    # Si no tienes SSL aún, comenta la línea de arriba y usa esto:
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
        
        # Headers para SPA (Single Page Application)
        proxy_set_header Accept-Encoding "";
    }

    # Configuración para archivos estáticos (opcional, mejora rendimiento)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://127.0.0.1:8043;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 4.2. Habilitar el Sitio

```bash
# Crear enlace simbólico
sudo ln -s /etc/nginx/sites-available/lauraydaniel-web /etc/nginx/sites-enabled/

# Verificar configuración de Nginx
sudo nginx -t

# Recargar Nginx
sudo systemctl reload nginx
```

---

## 🐳 Paso 5: Iniciar Docker Compose

```bash
cd /var/www/lauraydaniel-web

# Iniciar el contenedor
docker-compose up -d

# Verificar que está corriendo
docker-compose ps

# Ver logs (opcional)
docker-compose logs -f
```

---

## 🔒 Paso 6: Configurar SSL con Let's Encrypt (Opcional pero Recomendado)

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
   ```

2. **Verificar Nginx:**
   ```bash
   sudo systemctl status nginx
   ```

3. **Probar la aplicación:**
   - Abre `http://tu-servidor.com` o `https://tu-servidor.com` en tu navegador
   - Verifica que la página principal carga correctamente
   - Prueba la ruta `/formulario`
   - Prueba enviar un formulario de prueba

4. **Verificar logs si hay problemas:**
   ```bash
   # Logs de Docker
   docker-compose logs -f lauraydaniel-web
   
   # Logs de Nginx
   sudo tail -f /var/log/nginx/error.log
   ```

---

## 🔄 Paso 8: Actualizar la Aplicación (Futuras Actualizaciones)

Cuando necesites actualizar la aplicación:

1. **En tu máquina local:**
   ```powershell
   cd C:\Users\Maza\Documents\Flutter\lauraydaniel_web
   flutter build web --release `
     --dart-define="APPWRITE_ENDPOINT=https://tu-servidor.com/v1" `
     --dart-define="APPWRITE_PROJECT_ID=tu_project_id" `
     --dart-define="APPWRITE_API_KEY=tu_api_key" `
     --dart-define="APPWRITE_DATABASE_ID=tu_database_id" `
     --dart-define="APPWRITE_RSVP_COLLECTION_ID=tu_rsvp_collection_id" `
     --dart-define="APPWRITE_GALLERY_COLLECTION_ID=tu_gallery_collection_id" `
     --dart-define="APPWRITE_STORAGE_ID=tu_storage_id"
   ```

2. **Subir archivos al servidor** (usando SCP, Git, o FTP)

3. **En el servidor:**
   ```bash
   cd /var/www/lauraydaniel-web
   
   # Detener el contenedor
   docker-compose down
   
   # Actualizar archivos (extraer nuevos archivos o hacer git pull)
   # ...
   
   # Reiniciar el contenedor
   docker-compose up -d
   ```

---

## 🛠️ Solución de Problemas

### Error: Puerto 8043 ya en uso
```bash
# Ver qué proceso usa el puerto
sudo lsof -i :8043

# Cambiar el puerto en docker-compose.yml si es necesario
```

### Error: No se ven los cambios
```bash
# Limpiar caché del navegador (Ctrl+Shift+R)
# O reiniciar Docker
docker-compose restart
```

### Error: Ruta /formulario no funciona
- Verifica que `docker-compose.yml` tenga el flag `-fallback` configurado
- Verifica que Nginx esté configurado correctamente
- Revisa los logs: `docker-compose logs`

### Error: CORS en Appwrite
Asegúrate de que Appwrite tenga configurado CORS para permitir tu dominio:
- Ve al panel de Appwrite
- Settings → Domains
- Añade tu dominio (ej: `lauraydaniel.es`) en la lista de dominios permitidos
- También verifica que las colecciones tengan permisos públicos para crear documentos si es necesario

---

## 📝 Checklist Final

- [ ] Aplicación compilada con variables de entorno correctas
- [ ] Archivos subidos al servidor en `/var/www/lauraydaniel-web/build/web/`
- [ ] `docker-compose.yml` creado y configurado
- [ ] Contenedor Docker corriendo (`docker-compose ps`)
- [ ] Nginx configurado y funcionando (`sudo nginx -t`)
- [ ] Dominio apuntando al servidor (DNS configurado)
- [ ] SSL configurado (opcional pero recomendado)
- [ ] Aplicación accesible en `http://tu-dominio.com`
- [ ] Ruta `/formulario` funciona correctamente
- [ ] Formulario puede enviar datos a Appwrite
- [ ] CORS/Dominios configurados en Appwrite

---

## 🎉 ¡Listo!

Tu aplicación debería estar funcionando en producción. Si encuentras algún problema, revisa los logs y la sección de solución de problemas.

**Nota:** Asegúrate de tener todos los IDs correctos de Appwrite (Project ID, Database ID, Collection IDs, Storage ID) antes de compilar. Puedes encontrarlos en el panel de administración de Appwrite.

