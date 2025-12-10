# 📚 Guía Completa para Novatos: Appwrite + Flutter + Despliegue

Esta guía te llevará paso a paso desde cero hasta tener tu aplicación funcionando en producción.

---

## 📋 Índice

1. [Parte 1: Configurar Appwrite](#parte-1-configurar-appwrite)
2. [Parte 2: Compilar y Probar Localmente](#parte-2-compilar-y-probar-localmente)
3. [Parte 3: Desplegar en el Servidor](#parte-3-desplegar-en-el-servidor)

---

# Parte 1: Configurar Appwrite

## 🎯 Objetivo

Crear en Appwrite todo lo necesario para que tu aplicación pueda guardar datos.

---

## Paso 1.1: Acceder a Appwrite

1. Abre tu navegador
2. Ve a: `https://api.lauraydaniel.es`
3. Deberías ver la pantalla de inicio de sesión de Appwrite

**Si es la primera vez:**
- Haz clic en **"Create Account"** o **"Sign Up"**
- Email: `admin@epicmaker.dev`
- Contraseña: `Appwr1t3_2024!` (o la que configuraste según el PDF)
- Confirma la contraseña
- Haz clic en **"Create Account"**

**Si ya tienes cuenta:**
- Email: `admin@epicmaker.dev`
- Contraseña: `Appwr1t3_2024!`
- Haz clic en **"Sign In"**

---

## Paso 1.2: Crear un Proyecto

1. Una vez dentro, verás el panel de Appwrite
2. En la parte superior izquierda, busca **"Create Project"** o **"New Project"**
3. Haz clic en **"Create Project"**

**Configuración del Proyecto:**

- **Name**: `Laura y Daniel`
- **Project ID**: Déjalo que se genere automáticamente (o pon `lauraydaniel` si te lo permite)
- Haz clic en **"Create"**

**⚠️ IMPORTANTE:** Anota el **Project ID** que aparece. Lo necesitarás después.
Ejemplo: `64a1b2c3d4e5f6g7h8i9j0k`

---

## Paso 1.3: Crear una Base de Datos

1. En el menú lateral izquierdo, busca **"Databases"**
2. Haz clic en **"Databases"**
3. Haz clic en **"Create Database"**

**Configuración:**

- **Name**: `Boda Laura y Daniel`
- **Database ID**: Déjalo que se genere automáticamente (o pon `boda` si te lo permite)
- Haz clic en **"Create"**

**⚠️ IMPORTANTE:** Anota el **Database ID**. Lo necesitarás después.
Ejemplo: `64a1b2c3d4e5f6g7h8i9j0l`

---

## Paso 1.4: Crear la Colección "rsvps" (Confirmaciones)

1. Dentro de tu base de datos, busca la pestaña **"Collections"**
2. Haz clic en **"Create Collection"**

**Configuración básica:**

- **Collection ID**: `rsvps`
- **Name**: `RSVPs - Confirmaciones de Asistencia`
- Haz clic en **"Create"**

### Añadir Atributos (Campos)

Ahora necesitas crear los campos que guardará el formulario. Ve a la pestaña **"Attributes"** y haz clic en **"Create Attribute"** para cada uno:

#### Campo 1: name (Nombre)
- **Type**: `String`
- **Key**: `name`
- **Size**: `255`
- **Required**: ✅ (marca la casilla)
- Haz clic en **"Create"**

#### Campo 2: email
- **Type**: `Email`
- **Key**: `email`
- **Required**: ✅
- Haz clic en **"Create"**

#### Campo 3: phone
- **Type**: `String`
- **Key**: `phone`
- **Size**: `50`
- **Required**: ✅
- Haz clic en **"Create"**

#### Campo 4: asistencia
- **Type**: `String`
- **Key**: `asistencia`
- **Size**: `10`
- **Required**: ✅
- **Default**: `si`
- Haz clic en **"Create"**

#### Campo 5: edad_principal
- **Type**: `String`
- **Key**: `edad_principal`
- **Size**: `20`
- **Required**: ✅
- Haz clic en **"Create"**

#### Campo 6: alergias_principal
- **Type**: `String`
- **Key**: `alergias_principal`
- **Size**: `500`
- **Required**: ❌ (NO marques)
- Haz clic en **"Create"**

#### Campo 7: acompanante
- **Type**: `String`
- **Key**: `acompanante`
- **Size**: `10`
- **Required**: ❌
- Haz clic en **"Create"**

#### Campo 8: num_acompanantes
- **Type**: `Integer`
- **Key**: `num_acompanantes`
- **Required**: ❌
- **Min**: `0`
- **Max**: `9`
- Haz clic en **"Create"**

#### Campo 9: num_adultos
- **Type**: `Integer`
- **Key**: `num_adultos`
- **Required**: ❌
- **Min**: `0`
- Haz clic en **"Create"**

#### Campo 10: num_12_18
- **Type**: `Integer`
- **Key**: `num_12_18`
- **Required**: ❌
- **Min**: `0`
- Haz clic en **"Create"**

#### Campo 11: num_0_12
- **Type**: `Integer`
- **Key**: `num_0_12`
- **Required**: ❌
- **Min**: `0`
- Haz clic en **"Create"**

#### Campo 12: necesita_transporte
- **Type**: `String`
- **Key**: `necesita_transporte`
- **Size**: `10`
- **Required**: ❌
- Haz clic en **"Create"**

#### Campo 13: coche_propio
- **Type**: `String`
- **Key**: `coche_propio`
- **Size**: `10`
- **Required**: ❌
- Haz clic en **"Create"**

#### Campo 14: canciones
- **Type**: `String`
- **Key**: `canciones`
- **Size**: `1000`
- **Required**: ❌
- Haz clic en **"Create"**

#### Campo 15: album_digital
- **Type**: `String`
- **Key**: `album_digital`
- **Size**: `10`
- **Required**: ❌
- Haz clic en **"Create"**

#### Campo 16: mensaje_novios
- **Type**: `String`
- **Key**: `mensaje_novios`
- **Size**: `2000`
- **Required**: ❌
- Haz clic en **"Create"**

#### Campo 17: acompanantes_json
- **Type**: `String`
- **Key**: `acompanantes_json`
- **Size**: `5000`
- **Required**: ❌
- Haz clic en **"Create"**

#### Campo 18: created_at
- **Type**: `DateTime`
- **Key**: `created_at`
- **Required**: ❌
- Haz clic en **"Create"**

#### Campo 19: origen_form
- **Type**: `String`
- **Key**: `origen_form`
- **Size**: `100`
- **Required**: ❌
- Haz clic en **"Create"**

### Configurar Permisos

1. Ve a la pestaña **"Settings"** de la colección `rsvps`
2. Busca la sección **"Permissions"** o **"Access"**
3. Haz clic en **"Add Role"** o **"Create Rule"**
4. Selecciona **"Any"** o **"Users"** (para permitir que cualquiera pueda crear documentos)
5. Permisos:
   - ✅ **Create** (Crear)
   - ❌ **Read** (Solo admin puede leer)
   - ❌ **Update** (Solo admin puede actualizar)
   - ❌ **Delete** (Solo admin puede eliminar)
6. Haz clic en **"Save"**

---

## Paso 1.5: Crear la Colección "gallery_photos" (Galería)

1. Ve a **Databases** → Tu base de datos → **Collections**
2. Haz clic en **"Create Collection"**

**Configuración:**

- **Collection ID**: `gallery_photos`
- **Name**: `Galería de Fotos`
- Haz clic en **"Create"**

### Añadir Atributos

#### Campo 1: fileId
- **Type**: `String`
- **Key**: `fileId`
- **Size**: `255`
- **Required**: ✅
- Haz clic en **"Create"**

#### Campo 2: approved
- **Type**: `Boolean`
- **Key**: `approved`
- **Required**: ❌
- **Default**: `false`
- Haz clic en **"Create"**

#### Campo 3: uploaded_at
- **Type**: `DateTime`
- **Key**: `uploaded_at`
- **Required**: ❌
- Haz clic en **"Create"**

### Configurar Permisos

Igual que antes:
- ✅ **Create** (Cualquiera puede crear)
- ❌ **Read** (Solo admin)
- ❌ **Update** (Solo admin)
- ❌ **Delete** (Solo admin)

---

## Paso 1.6: Crear Storage Bucket (Para Fotos/Videos)

1. En el menú lateral, busca **"Storage"**
2. Haz clic en **"Storage"**
3. Haz clic en **"Create Bucket"**

**Configuración:**

- **Bucket ID**: `gallery`
- **Name**: `Galería de Fotos y Videos`
- Haz clic en **"Create"**

### Configurar Permisos del Bucket

1. Ve a la pestaña **"Settings"** del bucket
2. Busca **"Permissions"** o **"Access"**
3. Añade permisos:
   - ✅ **Create** (Cualquiera puede subir)
   - ✅ **Read** (Cualquiera puede leer/ver)
   - ❌ **Update** (Solo admin)
   - ❌ **Delete** (Solo admin)

### Configurar Límites

1. En **Settings**, busca **"File Size"**
2. **Maximum file size**: `50` MB (o más si quieres permitir videos grandes)
3. **Allowed file extensions**: `jpg,jpeg,png,webp,heic,heif,mp4,mov,avi,mkv`
4. Haz clic en **"Update"**

**⚠️ IMPORTANTE:** Anota el **Bucket ID** (`gallery`). Lo necesitarás después.

---

## Paso 1.7: Crear API Key

1. En el menú lateral, busca **"Settings"**
2. Haz clic en **"Settings"**
3. Busca **"API Keys"** o **"Keys"**
4. Haz clic en **"Create API Key"**

**Configuración:**

- **Name**: `Servidor Producción`
- **Expiration**: `Never` (o una fecha lejana)
- **Scopes** (Permisos):
  - ✅ **databases.read**
  - ✅ **databases.write**
  - ✅ **storage.read**
  - ✅ **storage.write**
5. Haz clic en **"Create"**

**⚠️ MUY IMPORTANTE:** 
- Se mostrará la API Key **SOLO UNA VEZ**
- **CÓPIALA Y GUÁRDALA EN UN LUGAR SEGURO**
- Ejemplo: `abc123xyz789def456ghi012jkl345mno678pqr901stu234vwx567`

---

## Paso 1.8: Configurar Dominios Permitidos

1. En **Settings**, busca **"Domains"** o **"Allowed Domains"**
2. Haz clic en **"Add Domain"** o **"Create Domain"**
3. Añade estos dominios uno por uno:
   - `localhost`
   - `localhost:8080`
   - `lauraydaniel.es`
   - `www.lauraydaniel.es`
   - `api.lauraydaniel.es`
4. Haz clic en **"Save"** después de cada uno

---

## Paso 1.9: Anotar Todos los IDs

Crea un archivo de texto o documento con esta información:

```
APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1
APPWRITE_PROJECT_ID=tu_project_id_aqui
APPWRITE_API_KEY=tu_api_key_aqui
APPWRITE_DATABASE_ID=tu_database_id_aqui
APPWRITE_RSVP_COLLECTION_ID=rsvps
APPWRITE_GALLERY_COLLECTION_ID=gallery_photos
APPWRITE_STORAGE_ID=gallery
```

**Ejemplo real:**
```
APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1
APPWRITE_PROJECT_ID=64a1b2c3d4e5f6g7h8i9j0k
APPWRITE_API_KEY=abc123xyz789def456ghi012jkl345mno678pqr901stu234vwx567
APPWRITE_DATABASE_ID=64a1b2c3d4e5f6g7h8i9j0l
APPWRITE_RSVP_COLLECTION_ID=rsvps
APPWRITE_GALLERY_COLLECTION_ID=gallery_photos
APPWRITE_STORAGE_ID=gallery
```

**Guarda este archivo en un lugar seguro.** Lo necesitarás para compilar la aplicación.

---

# Parte 2: Compilar y Probar Localmente

## 🎯 Objetivo

Compilar la aplicación con las variables de Appwrite y probar que guarda datos correctamente.

---

## Paso 2.1: Abrir PowerShell

1. Presiona `Windows + X`
2. Selecciona **"Windows PowerShell"** o **"Terminal"**
3. Navega al directorio del proyecto:

```powershell
cd C:\Users\Maza\Documents\Flutter\lauraydaniel_web
```

---

## Paso 2.2: Compilar la Aplicación

Copia este comando y **reemplaza los valores** con los que anotaste en el Paso 1.9:

```powershell
flutter build web --release `
  --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1" `
  --dart-define="APPWRITE_PROJECT_ID=TU_PROJECT_ID_AQUI" `
  --dart-define="APPWRITE_API_KEY=TU_API_KEY_AQUI" `
  --dart-define="APPWRITE_DATABASE_ID=TU_DATABASE_ID_AQUI" `
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=rsvps" `
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=gallery_photos" `
  --dart-define="APPWRITE_STORAGE_ID=gallery"
```

**Ejemplo con valores reales:**

```powershell
flutter build web --release `
  --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1" `
  --dart-define="APPWRITE_PROJECT_ID=64a1b2c3d4e5f6g7h8i9j0k" `
  --dart-define="APPWRITE_API_KEY=abc123xyz789def456ghi012jkl345mno678pqr901stu234vwx567" `
  --dart-define="APPWRITE_DATABASE_ID=64a1b2c3d4e5f6g7h8i9j0l" `
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=rsvps" `
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=gallery_photos" `
  --dart-define="APPWRITE_STORAGE_ID=gallery"
```

**Presiona Enter** y espera a que termine (puede tardar 1-2 minutos).

Deberías ver al final: `Built build\web`

---

## Paso 2.3: Ejecutar la Aplicación Localmente

Ejecuta este comando:

```powershell
.\servir.bat
```

O si no funciona:

```powershell
powershell -ExecutionPolicy Bypass -File servir.ps1
```

**Debería:**
1. Abrir una ventana de PowerShell
2. Mostrar: "Servidor iniciado en http://localhost:8080"
3. Abrir automáticamente tu navegador en `http://localhost:8080`

---

## Paso 2.4: Probar el Formulario

### 4.1. Acceder al Formulario

1. En el navegador, ve a: `http://localhost:8080/formulario`
2. Deberías ver el formulario de preinscripción

### 4.2. Llenar el Formulario

Completa con datos de prueba:

- **Nombre**: `Juan Pérez`
- **Email**: `juan@test.com`
- **Teléfono**: `612345678`
- **Asistencia**: Selecciona `Sí`
- **Edad principal**: Selecciona `Adulto`
- **Alergias**: `Ninguna` (opcional)
- **Acompañante**: Selecciona `Sí`
- **Número de acompañantes**: `2`
- **Adultos**: `1`
- **12-18 años**: `1`
- **0-12 años**: `0`
- **Transporte**: `No`
- **Coche propio**: `Sí`
- **Canciones**: `Canción de prueba`
- **Álbum digital**: `Sí`
- **Mensaje**: `Mensaje de prueba para verificar que funciona`

### 4.3. Enviar el Formulario

1. Haz clic en el botón **"Enviar"** o **"Confirmar"**
2. Deberías ver un mensaje verde: **"¡Preinscripción enviada!"**

**Si ves un error:**
- Abre las herramientas de desarrollador (presiona `F12`)
- Ve a la pestaña **Console**
- Busca mensajes en rojo
- Copia el error y revísalo

---

## Paso 2.5: Verificar que se Guardó en Appwrite

### 5.1. Abrir Appwrite

1. Abre otra pestaña del navegador
2. Ve a: `https://api.lauraydaniel.es`
3. Inicia sesión si es necesario

### 5.2. Ver el Registro

1. Ve a **Databases** → Tu base de datos → **Collections** → **rsvps**
2. Haz clic en la pestaña **"Documents"**
3. Deberías ver un nuevo documento con:
   - Nombre: `Juan Pérez`
   - Email: `juan@test.com`
   - Todos los demás campos que llenaste

**✅ Si ves el registro:** ¡Perfecto! La conexión funciona.

**❌ Si NO ves el registro:**
1. Vuelve a la aplicación
2. Presiona `F12` para abrir herramientas de desarrollador
3. Ve a la pestaña **Network** (Red)
4. Busca una petición a `api.lauraydaniel.es`
5. Haz clic en ella
6. Ve a la pestaña **Response** o **Preview**
7. Busca el mensaje de error
8. Revisa la sección de solución de problemas más abajo

---

## Paso 2.6: Probar Subida de Fotos (Opcional)

1. En la página principal (`http://localhost:8080`)
2. Busca el botón de **"Subir fotos"** o **"Galería"**
3. Haz clic y selecciona una imagen de prueba
4. Espera a que se suba
5. Deberías ver: **"¡Archivos subidos correctamente!"**

### Verificar en Appwrite:

1. Ve a **Storage** → Bucket `gallery`
2. Deberías ver el archivo que subiste
3. Ve a **Databases** → Tu base de datos → **Collections** → **gallery_photos**
4. Deberías ver un nuevo documento con el `fileId`

---

# Parte 3: Desplegar en el Servidor

## 🎯 Objetivo

Subir la aplicación compilada al servidor y que funcione en `https://lauraydaniel.es`

---

## Paso 3.1: Preparar los Archivos

Los archivos ya están compilados en `build\web\`. Vamos a comprimirlos:

### Opción A: Usando PowerShell

```powershell
cd C:\Users\Maza\Documents\Flutter\lauraydaniel_web
Compress-Archive -Path .\build\web\* -DestinationPath .\flutter-build.zip -Force
```

Esto creará `flutter-build.zip` en el directorio del proyecto.

### Opción B: Manualmente

1. Abre el explorador de archivos
2. Ve a: `C:\Users\Maza\Documents\Flutter\lauraydaniel_web\build\web`
3. Selecciona todos los archivos (Ctrl+A)
4. Clic derecho → **Enviar a** → **Carpeta comprimida (en zip)**
5. Nómbralo `flutter-build.zip`

---

## Paso 3.2: Subir Archivos al Servidor

### Usando SCP (desde PowerShell)

```powershell
scp .\flutter-build.zip epicmaker@192.168.1.101:/home/epicmaker/
```

Te pedirá la contraseña: `Santander2020@.`

### Usando WinSCP o FileZilla (Más fácil)

1. Descarga **WinSCP** (gratis): https://winscp.net/
2. Instálalo y ábrelo
3. Configura la conexión:
   - **Host name**: `192.168.1.101`
   - **User name**: `epicmaker`
   - **Password**: `Santander2020@.`
   - **Port**: `22`
4. Haz clic en **Login**
5. Arrastra `flutter-build.zip` desde tu PC a la carpeta `/home/epicmaker/` en el servidor

---

## Paso 3.3: Conectarse al Servidor

### Usando PowerShell

```powershell
ssh epicmaker@192.168.1.101
```

Contraseña: `Santander2020@.`

### Usando PuTTY (Más fácil)

1. Descarga **PuTTY** (gratis): https://www.putty.org/
2. Ábrelo
3. Configura:
   - **Host Name**: `192.168.1.101`
   - **Port**: `22`
   - **Connection type**: SSH
4. Haz clic en **Open**
5. Usuario: `epicmaker`
6. Contraseña: `Santander2020@.`

---

## Paso 3.4: Descomprimir Archivos en el Servidor

Una vez conectado al servidor, ejecuta:

```bash
cd /opt/docker/lauraydaniel

# Hacer backup de los archivos antiguos (si existen)
if [ -d "flutter-build" ]; then
    mv flutter-build flutter-build-backup-$(date +%Y%m%d-%H%M%S)
fi

# Crear directorio nuevo
mkdir -p flutter-build

# Descomprimir
unzip ~/flutter-build.zip -d flutter-build/

# Verificar que se descomprimió correctamente
ls -la flutter-build/
```

Deberías ver: `index.html`, `main.dart.js`, `assets/`, etc.

---

## Paso 3.5: Reiniciar el Contenedor

```bash
cd /opt/docker/lauraydaniel
docker compose restart flutter-web
```

O si prefieres recrearlo:

```bash
docker compose up -d --force-recreate flutter-web
```

---

## Paso 3.6: Verificar Logs

```bash
docker compose logs -f flutter-web
```

Presiona `Ctrl+C` para salir de los logs.

---

## Paso 3.7: Probar en Producción

1. Abre tu navegador
2. Ve a: `https://lauraydaniel.es`
3. Deberías ver tu aplicación funcionando
4. Prueba la ruta: `https://lauraydaniel.es/formulario`
5. Llena el formulario y envía
6. Verifica en Appwrite que se guardó

---

## 🐛 Solución de Problemas

### Error: "Backend no configurado"

**Causa:** No compilaste con las variables de entorno.

**Solución:**
1. Vuelve al Paso 2.2
2. Compila de nuevo con todas las variables
3. Vuelve a subir los archivos

### Error: "HTTP 401" o "HTTP 403"

**Causa:** API Key incorrecta o sin permisos.

**Solución:**
1. Verifica que la API Key tiene los permisos correctos (Paso 1.7)
2. Verifica que copiaste la API Key completa (es muy larga)
3. Recompila y vuelve a subir

### Error: "HTTP 404"

**Causa:** Collection ID o Database ID incorrectos.

**Solución:**
1. Verifica los IDs en Appwrite
2. Asegúrate de que los IDs son exactos (sin espacios)
3. Recompila y vuelve a subir

### La aplicación no carga en el servidor

**Verifica:**
1. ¿El contenedor está corriendo?
   ```bash
   docker ps | grep lauraydaniel-web
   ```

2. ¿Los archivos están en el lugar correcto?
   ```bash
   ls -la /opt/docker/lauraydaniel/flutter-build/
   ```

3. ¿Hay errores en los logs?
   ```bash
   docker compose logs flutter-web
   ```

### El formulario no envía datos

**Verifica:**
1. Abre las herramientas de desarrollador (F12)
2. Ve a Console → busca errores en rojo
3. Ve a Network → busca peticiones a `api.lauraydaniel.es`
4. Revisa el código de respuesta:
   - `200` o `201`: Éxito
   - `400`: Error en los datos
   - `401`: Problema de autenticación
   - `404`: Recurso no encontrado

---

## ✅ Checklist Final

### Appwrite
- [ ] Proyecto creado
- [ ] Base de datos creada
- [ ] Colección `rsvps` creada con todos los campos
- [ ] Colección `gallery_photos` creada
- [ ] Storage bucket `gallery` creado
- [ ] API Key creada con permisos correctos
- [ ] Dominios permitidos configurados
- [ ] Todos los IDs anotados

### Compilación Local
- [ ] Aplicación compilada con variables de Appwrite
- [ ] Aplicación ejecutándose en `localhost:8080`
- [ ] Formulario funciona y envía datos
- [ ] Datos aparecen en Appwrite
- [ ] Subida de archivos funciona (opcional)

### Despliegue
- [ ] Archivos comprimidos (`flutter-build.zip`)
- [ ] Archivos subidos al servidor
- [ ] Archivos descomprimidos en `/opt/docker/lauraydaniel/flutter-build/`
- [ ] Contenedor reiniciado
- [ ] Aplicación accesible en `https://lauraydaniel.es`
- [ ] Formulario funciona en producción
- [ ] Datos se guardan correctamente

---

## 🎉 ¡Felicidades!

Si llegaste hasta aquí y todo funciona, ¡has desplegado tu primera aplicación Flutter con Appwrite!

---

## 📞 ¿Necesitas Ayuda?

Si algo no funciona:

1. **Revisa los logs:**
   - En el navegador: F12 → Console
   - En el servidor: `docker compose logs flutter-web`

2. **Verifica los IDs:**
   - Compara los IDs que usaste con los que están en Appwrite

3. **Revisa los permisos:**
   - En Appwrite → Collections → Settings → Permissions
   - En Appwrite → Storage → Settings → Permissions

4. **Prueba paso a paso:**
   - Primero verifica que Appwrite funciona
   - Luego verifica que la compilación local funciona
   - Finalmente verifica el despliegue

---

**¡Buena suerte! 🚀**







