# 🚀 Guía de Despliegue - lauraydaniel.es (Flutter + Appwrite)

## 📋 Resumen

Esta guía te ayudará a desplegar tu aplicación Flutter web con Appwrite en tu servidor Proxmox siguiendo la arquitectura del PDF.

**Arquitectura:**
- Flutter Web → Nginx Alpine (contenedor Docker)
- Appwrite → Contenedores Docker completos
- Nginx Proxy Manager → Gestiona dominios y SSL
- Cloudflare Tunnel → Conexión segura sin abrir puertos

---

## 🔧 Paso 1: Compilar la Aplicación Flutter

En tu máquina local (Windows), ejecuta:

```powershell
cd C:\Users\Maza\Documents\Flutter\lauraydaniel_web

flutter build web --release `
  --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1" `
  --dart-define="APPWRITE_PROJECT_ID=tu_project_id" `
  --dart-define="APPWRITE_API_KEY=tu_api_key" `
  --dart-define="APPWRITE_DATABASE_ID=tu_database_id" `
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=tu_rsvp_collection_id" `
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=tu_gallery_collection_id" `
  --dart-define="APPWRITE_STORAGE_ID=tu_storage_id"
```

**⚠️ IMPORTANTE:**
- Reemplaza `tu_*` con los valores reales de tu Appwrite
- El endpoint debe ser `https://api.lauraydaniel.es/v1` (según tu configuración)
- Esto generará los archivos en `build/web/`

---

## 📦 Paso 2: Subir Archivos al Servidor

### Opción A: Usando SCP (desde PowerShell)

```powershell
# Comprimir la carpeta build/web
Compress-Archive -Path .\build\web\* -DestinationPath .\flutter-build.zip

# Subir al servidor
scp .\flutter-build.zip epicmaker@192.168.1.101:/home/epicmaker/
```

### Opción B: Usando Git

Si tienes Git configurado:

```powershell
git add build/web
git commit -m "Build producción"
git push
```

---

## 🖥️ Paso 3: Configurar en el Servidor

### 3.1. Conectarse al Servidor

```bash
ssh epicmaker@192.168.1.101
```

### 3.2. Navegar al Directorio del Proyecto

```bash
cd /opt/docker/lauraydaniel
```

### 3.3. Extraer/Colocar Archivos de Flutter

Si usaste SCP:
```bash
# Descomprimir en el directorio flutter-build
unzip ~/flutter-build.zip -d flutter-build/
```

Si usaste Git:
```bash
# Clonar o hacer pull del repositorio
# Luego copiar build/web a flutter-build
cp -r /ruta/al/repo/build/web/* flutter-build/
```

**Verificar estructura:**
```bash
ls -la flutter-build/
```

Deberías ver: `index.html`, `main.dart.js`, `assets/`, `canvaskit/`, etc.

---

## 🐳 Paso 4: Verificar Docker Compose

### 4.1. Verificar que docker-compose.yml existe

```bash
cat docker-compose.yml | grep -A 5 "flutter-web"
```

Deberías ver la configuración del servicio `flutter-web`.

### 4.2. Verificar configuración Nginx

```bash
cat nginx-flutter.conf
```

Debería tener:
- `try_files $uri $uri/ /index.html;` (para SPA)
- Configuración de caché para assets

### 4.3. Verificar que los directorios existen

```bash
ls -la
```

Deberías tener:
- `docker-compose.yml`
- `nginx-flutter.conf`
- `flutter-build/` (con tus archivos)
- `appwrite-config/`
- `appwrite-certificates/`
- etc.

---

## 🚀 Paso 5: Levantar los Contenedores

### 5.1. Reiniciar solo el contenedor de Flutter (si ya existe)

```bash
docker compose restart flutter-web
```

O si prefieres recrearlo:

```bash
docker compose up -d --force-recreate flutter-web
```

### 5.2. Si es la primera vez, levantar todo

```bash
docker compose up -d
```

Esto levantará:
- Appwrite (y todos sus servicios)
- MariaDB
- Redis
- Flutter Web (nginx)

### 5.3. Verificar que está corriendo

```bash
docker ps | grep lauraydaniel
```

Deberías ver `lauraydaniel-web` corriendo.

### 5.4. Ver logs si hay problemas

```bash
docker compose logs -f flutter-web
```

---

## 🌐 Paso 6: Verificar Nginx Proxy Manager

### 6.1. Acceder al Panel

Abre en tu navegador:
```
http://192.168.1.101:81
```

O a través de Cloudflare Tunnel:
```
https://panel.epicmaker.dev
```

### 6.2. Verificar Proxy Host para lauraydaniel.es

1. Ve a **Proxy Hosts**
2. Busca `lauraydaniel.es`
3. Verifica que:
   - **Forward Hostname**: `lauraydaniel-web`
   - **Forward Port**: `80`
   - **Websockets Support**: ✓
   - **SSL**: Configurado y activo

### 6.3. Si no existe, crearlo

1. **Proxy Hosts → Add Proxy Host**

**Pestaña Details:**
- **Domain Names**: `lauraydaniel.es`, `www.lauraydaniel.es`
- **Scheme**: http
- **Forward Hostname / IP**: `lauraydaniel-web`
- **Forward Port**: `80`
- **Block Common Exploits**: ✓
- **Websockets Support**: ✓

**Pestaña SSL:**
- **SSL Certificate**: Request a new SSL Certificate
- **Force SSL**: ✓
- **HTTP/2 Support**: ✓
- **Email**: admin@epicmaker.dev

Click **Save**.

---

## ✅ Paso 7: Verificar que Funciona

### 7.1. Probar localmente (desde el servidor)

```bash
curl http://localhost:80 -H "Host: lauraydaniel.es"
```

Deberías ver el HTML de tu aplicación.

### 7.2. Probar desde fuera

Abre en tu navegador:
```
https://lauraydaniel.es
```

Verifica:
- ✅ La página principal carga
- ✅ Los assets (CSS, JS, imágenes) cargan
- ✅ La ruta `/formulario` funciona
- ✅ El formulario puede enviar datos

### 7.3. Verificar Appwrite

Abre:
```
https://api.lauraydaniel.es
```

Deberías ver la respuesta de Appwrite.

---

## 🔄 Paso 8: Actualizar la Aplicación (Futuras Actualizaciones)

Cuando necesites actualizar:

### 8.1. En tu máquina local

```powershell
cd C:\Users\Maza\Documents\Flutter\lauraydaniel_web

# Compilar con las variables de entorno
flutter build web --release `
  --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1" `
  --dart-define="APPWRITE_PROJECT_ID=..." `
  # ... resto de variables
```

### 8.2. Subir archivos al servidor

```powershell
# Comprimir
Compress-Archive -Path .\build\web\* -DestinationPath .\flutter-build.zip

# Subir
scp .\flutter-build.zip epicmaker@192.168.1.101:/home/epicmaker/
```

### 8.3. En el servidor

```bash
cd /opt/docker/lauraydaniel

# Hacer backup (opcional)
cp -r flutter-build flutter-build-backup-$(date +%Y%m%d)

# Descomprimir nuevos archivos
rm -rf flutter-build/*
unzip ~/flutter-build.zip -d flutter-build/

# Reiniciar contenedor
docker compose restart flutter-web

# Verificar logs
docker compose logs -f flutter-web
```

---

## 🛠️ Solución de Problemas

### Error: Contenedor no inicia

```bash
# Ver logs detallados
docker compose logs flutter-web

# Verificar configuración
docker compose config

# Recrear contenedor
docker compose up -d --force-recreate flutter-web
```

### Error: Archivos no se ven

```bash
# Verificar que los archivos están en flutter-build
ls -la flutter-build/

# Verificar permisos
sudo chown -R epicmaker:epicmaker flutter-build/

# Verificar montaje en contenedor
docker exec lauraydaniel-web ls -la /usr/share/nginx/html
```

### Error: Ruta /formulario no funciona

```bash
# Verificar configuración nginx
cat nginx-flutter.conf

# Debe tener: try_files $uri $uri/ /index.html;
# Si no, actualiza el archivo y reinicia:
docker compose restart flutter-web
```

### Error: CORS en Appwrite

1. Accede a Appwrite: `https://api.lauraydaniel.es`
2. Ve a **Settings → Domains**
3. Añade `lauraydaniel.es` y `www.lauraydaniel.es`
4. Verifica permisos de las colecciones

### Error: Variables de entorno no funcionan

**Verifica que compilaste con las variables correctas:**

```bash
# En el servidor, verificar el JavaScript compilado
grep -i "appwrite" flutter-build/main.dart.js | head -5
```

Si no aparecen las URLs de Appwrite, significa que no se compilaron con las variables. Vuelve a compilar.

---

## 📝 Estructura de Archivos Final

```
/opt/docker/lauraydaniel/
├── docker-compose.yml          # Configuración Docker
├── nginx-flutter.conf          # Configuración Nginx para Flutter
├── flutter-build/              # Archivos compilados de Flutter
│   ├── index.html
│   ├── main.dart.js
│   ├── assets/
│   └── canvaskit/
├── appwrite-config/            # Configuración Appwrite
├── appwrite-certificates/      # Certificados Appwrite
├── appwrite-functions/         # Funciones Appwrite
├── redis-data/                 # Datos Redis
└── influxdb-data/             # Datos InfluxDB
```

---

## 🔍 Comandos Útiles

### Ver estado de todos los servicios

```bash
cd /opt/docker/lauraydaniel
docker compose ps
```

### Ver logs de todos los servicios

```bash
docker compose logs -f
```

### Ver logs solo de Flutter

```bash
docker compose logs -f flutter-web
```

### Ver logs solo de Appwrite

```bash
docker compose logs -f appwrite
```

### Reiniciar solo Flutter

```bash
docker compose restart flutter-web
```

### Reiniciar todo

```bash
docker compose restart
```

### Ver uso de recursos

```bash
docker stats lauraydaniel-web
```

### Entrar al contenedor de Flutter

```bash
docker exec -it lauraydaniel-web sh
```

### Verificar configuración Nginx dentro del contenedor

```bash
docker exec lauraydaniel-web cat /etc/nginx/conf.d/default.conf
```

---

## ✅ Checklist Final

- [ ] Aplicación Flutter compilada con variables de Appwrite correctas
- [ ] Archivos subidos a `/opt/docker/lauraydaniel/flutter-build/`
- [ ] Contenedor `lauraydaniel-web` corriendo (`docker ps`)
- [ ] Nginx Proxy Manager configurado para `lauraydaniel.es`
- [ ] SSL configurado en NPM
- [ ] Cloudflare Tunnel funcionando
- [ ] Appwrite accesible en `https://api.lauraydaniel.es`
- [ ] Aplicación accesible en `https://lauraydaniel.es`
- [ ] Ruta `/formulario` funciona correctamente
- [ ] Formulario puede enviar datos a Appwrite
- [ ] CORS configurado en Appwrite para `lauraydaniel.es`

---

## 🎉 ¡Listo!

Tu aplicación debería estar funcionando en producción. Si encuentras algún problema, revisa los logs y la sección de solución de problemas.

**Nota importante:** Según tu configuración, el endpoint de Appwrite debe ser `https://api.lauraydaniel.es/v1` (no `localhost` ni `127.0.0.1`), ya que está accesible a través de Nginx Proxy Manager y Cloudflare Tunnel.







