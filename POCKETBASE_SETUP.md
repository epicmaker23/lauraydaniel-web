# Guía de Configuración de PocketBase para la App de Boda

## 1. Instalación de PocketBase en Ubuntu 24.04

### Opción A: Descarga directa (recomendado)

```bash
# Crear directorio para PocketBase
sudo mkdir -p /opt/pocketbase
cd /opt/pocketbase

# Descargar PocketBase (reemplaza la versión por la más reciente)
wget https://github.com/pocketbase/pocketbase/releases/download/v0.22.0/pocketbase_0.22.0_linux_amd64.zip

# Descomprimir
unzip pocketbase_0.22.0_linux_amd64.zip

# Dar permisos de ejecución
chmod +x pocketbase

# Crear usuario para PocketBase (opcional pero recomendado)
sudo useradd -r -s /bin/false pocketbase
sudo chown -R pocketbase:pocketbase /opt/pocketbase
```

### Opción B: Usar systemd para ejecutar como servicio

```bash
# Crear archivo de servicio
sudo nano /etc/systemd/system/pocketbase.service
```

Contenido del archivo:

```ini
[Unit]
Description=PocketBase Server
After=network.target

[Service]
Type=simple
User=pocketbase
Group=pocketbase
ExecStart=/opt/pocketbase/pocketbase serve --http=0.0.0.0:8090
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Activar y iniciar el servicio:

```bash
sudo systemctl daemon-reload
sudo systemctl enable pocketbase
sudo systemctl start pocketbase
sudo systemctl status pocketbase
```

### Verificar que funciona

Abre en tu navegador: `http://tu-servidor:8090/_/` (deberías ver el panel de administración)

## 2. Configuración Inicial de PocketBase

### 2.1. Crear cuenta de administrador

1. Ve a `http://tu-servidor:8090/_/`
2. Crea tu primera cuenta de administrador
3. Guarda las credenciales de forma segura

### 2.2. Configurar CORS (si la app web está en otro dominio)

**Nota:** En algunas versiones de PocketBase, la configuración de CORS puede estar en diferentes ubicaciones:

**Opción A:** En el panel de administración:
- Settings → API → CORS Origins
- Añade los orígenes permitidos:
  - `http://localhost:3001` (para desarrollo local)
  - `https://lauraydaniel.es` (tu dominio de producción)
  - O usa `*` para permitir todos (solo para desarrollo)

**Opción B:** Si no encuentras la sección API:
- Puede que tu versión de PocketBase tenga la configuración en otro lugar
- Busca en Settings → Application o Settings → Token options
- O simplemente continúa con la creación de colecciones y configura CORS más tarde si aparece un error

**Importante:** Si vas a probar localmente primero (`localhost:3001` → `localhost:8090`), NO necesitas configurar CORS todavía. Solo será necesario cuando despliegues en producción con diferentes dominios.

## 3. Crear Colección: `rsvps`

### 3.1. Crear la colección

1. En el panel de administración, ve a **Collections**
2. Click en **New Collection**
3. Nombre: `rsvps`
4. Click en **Create**

### 3.2. Añadir campos

Añade los siguientes campos (click en **New Field** para cada uno):

| Nombre | Tipo | Opciones | Requerido |
|--------|------|----------|-----------|
| `name` | Text | - | ✅ Sí |
| `email` | Email | - | ✅ Sí |
| `phone` | Text | - | ✅ Sí |
| `asistencia` | Select | Opciones: `si`, `no` | ✅ Sí |
| `edad_principal` | Select | Opciones: `adulto`, `12-18`, `0-12` | ✅ Sí |
| `alergias_principal` | Text | - | ❌ No |
| `acompanante` | Select | Opciones: `si`, `no` | ❌ No |
| `num_acompanantes` | Number | Min: 0, Max: 9 | ❌ No |
| `num_adultos` | Number | Min: 0 | ❌ No |
| `num_12_18` | Number | Min: 0 | ❌ No |
| `num_0_12` | Number | Min: 0 | ❌ No |
| `necesita_transporte` | Select | Opciones: `si`, `no` | ❌ No |
| `coche_propio` | Select | Opciones: `si`, `no` | ❌ No |
| `canciones` | Text | - | ❌ No |
| `album_digital` | Select | Opciones: `si`, `no` | ❌ No |
| `mensaje_novios` | Text | - | ❌ No |
| `acompanantes_json` | JSON | - | ❌ No |
| `created_at` | Date | - | ❌ No |
| `origen_form` | Text | - | ❌ No |

**Nota importante para campos Select:**
- Cuando crees un campo Select, en la sección **Options**, añade cada opción en una línea separada:
  - Para `asistencia`: `si` (línea 1), `no` (línea 2)
  - Para `edad_principal`: `adulto` (línea 1), `12-18` (línea 2), `0-12` (línea 3)
  - Y así sucesivamente

### 3.3. Configurar permisos

1. Ve a la pestaña **API Rules** de la colección `rsvps`
2. En **Create rule**, selecciona:
   - **Rule type**: `@request.auth.id != "" || @request.auth.id = ""`
   - O simplemente deja el campo vacío para permitir a todos
   - **Action**: `create`
   - Click en **Save**

Esto permite que cualquier usuario (incluso anónimo) pueda crear registros.

## 4. Crear Colección: `gallery_photos`

### 4.1. Crear la colección

1. Click en **New Collection**
2. Nombre: `gallery_photos`
3. Click en **Create**

### 4.2. Añadir campos

| Nombre | Tipo | Opciones | Requerido |
|--------|------|----------|-----------|
| `file` | File | Max size: 50MB (o el que prefieras) | ✅ Sí |
| `approved` | Bool | Default: `false` | ❌ No |
| `uploaded_at` | Date | - | ❌ No |

**Nota para el campo File:**
- En **Options**, puedes configurar:
  - **Max select**: 1
  - **Max size**: 50MB (o más si quieres permitir videos grandes)
  - **MIME types**: `image/*,video/*` (para permitir imágenes y videos)

### 4.3. Configurar permisos

1. Ve a la pestaña **API Rules** de la colección `gallery_photos`
2. En **Create rule**, configura igual que `rsvps`:
   - Permite crear a todos (público)

## 5. Obtener Token de Admin (Opcional)

Si quieres usar autenticación para las operaciones:

**Opción A:** En Settings → API → Admin API Token
1. Ve a **Settings** → **API**
2. En la sección **Admin API Token**, click en **Generate new token**
3. Copia el token generado (guárdalo de forma segura, no se mostrará de nuevo)

**Opción B:** Si no encuentras Settings → API:
1. Ve a **Settings** → **Token options**
2. Busca la opción para generar tokens de admin
3. O simplemente omite este paso si las colecciones son públicas

**Nota**: Si configuraste las colecciones como públicas (sin autenticación), NO necesitas este token.

## 6. Configurar Nginx como Proxy Reverso (Opcional pero recomendado)

Si quieres usar HTTPS y un dominio personalizado:

```bash
sudo nano /etc/nginx/sites-available/pocketbase
```

Contenido:

```nginx
server {
    listen 80;
    server_name pocketbase.tu-dominio.com;

    location / {
        proxy_pass http://localhost:8090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Activar:

```bash
sudo ln -s /etc/nginx/sites-available/pocketbase /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Luego configura SSL con Let's Encrypt:

```bash
sudo certbot --nginx -d pocketbase.tu-dominio.com
```

## 7. Verificar la Configuración

### Probar creación de RSVP:

```bash
curl -X POST http://tu-servidor:8090/api/collections/rsvps/records \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Usuario",
    "email": "test@example.com",
    "phone": "123456789",
    "asistencia": "si",
    "edad_principal": "adulto"
  }'
```

Deberías recibir una respuesta con el registro creado.

### Probar subida de archivo:

```bash
curl -X POST http://tu-servidor:8090/api/collections/gallery_photos/records \
  -F "file=@/ruta/a/tu/imagen.jpg" \
  -F "approved=false"
```

## 8. Variables para Compilar la App Flutter

Una vez configurado PocketBase, compila la app con:

```powershell
flutter build web --dart-define="POCKETBASE_URL=http://tu-servidor:8090" --dart-define="POCKETBASE_ADMIN_TOKEN=tu_token_si_lo_necesitas" --dart-define="POCKETBASE_RSVP_COLLECTION=rsvps" --dart-define="POCKETBASE_GALLERY_COLLECTION=gallery_photos"
```

**Ejemplo con dominio:**
```powershell
flutter build web --dart-define="POCKETBASE_URL=https://pocketbase.tu-dominio.com"
```

## 9. Solución de Problemas

### Error de CORS
- Asegúrate de haber configurado los orígenes permitidos en Settings → API → CORS Origins

### Error 404 al crear registro
- Verifica que el nombre de la colección sea exactamente `rsvps` o `gallery_photos`
- Verifica que los permisos estén configurados correctamente

### Error de autenticación
- Si usas token, verifica que el formato sea correcto: `Bearer tu_token`
- Si no usas token, asegúrate de que las colecciones sean públicas

### Archivos no se suben
- Verifica el tamaño máximo del campo File
- Verifica los tipos MIME permitidos
- Revisa los logs de PocketBase: `sudo journalctl -u pocketbase -f`

## 10. Backup de PocketBase

PocketBase guarda todo en un archivo SQLite. Para hacer backup:

```bash
# Detener PocketBase
sudo systemctl stop pocketbase

# Copiar el archivo de base de datos
sudo cp /opt/pocketbase/pb_data/data.db /backup/pocketbase-$(date +%Y%m%d).db

# Reiniciar PocketBase
sudo systemctl start pocketbase
```

O configura un backup automático con cron:

```bash
sudo crontab -e
```

Añade:
```
0 2 * * * systemctl stop pocketbase && cp /opt/pocketbase/pb_data/data.db /backup/pocketbase-$(date +\%Y\%m\%d).db && systemctl start pocketbase
```

Esto hará backup cada día a las 2 AM.

