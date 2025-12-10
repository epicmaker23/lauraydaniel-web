# 🧪 Guía para Probar la Conexión con Appwrite

## 📋 Requisitos Previos

Antes de probar, necesitas tener:

1. ✅ Appwrite funcionando en `https://api.lauraydaniel.es`
2. ✅ Las colecciones creadas (`rsvps` y `gallery_photos`)
3. ✅ Los IDs de tu proyecto Appwrite

---

## 🔧 Paso 1: Obtener los IDs de Appwrite

Si aún no los tienes, sigue la guía `OBTENER_IDS_APPWRITE.md` o:

1. Accede a Appwrite: `https://api.lauraydaniel.es`
2. Inicia sesión con: `admin@epicmaker.dev`
3. Ve a **Settings → General** para obtener:
   - **Project ID**
   - **Database ID**
   - **Collection IDs** (rsvps y gallery_photos)
   - **Storage ID** (bucket de galería)
4. Ve a **Settings → API Keys** para crear/obtener:
   - **API Key** (con permisos de lectura/escritura)

---

## 🚀 Paso 2: Compilar con las Variables de Appwrite

Ejecuta este comando reemplazando los valores con los tuyos:

```powershell
cd C:\Users\Maza\Documents\Flutter\lauraydaniel_web

flutter build web --release `
  --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1" `
  --dart-define="APPWRITE_PROJECT_ID=tu_project_id_aqui" `
  --dart-define="APPWRITE_API_KEY=tu_api_key_aqui" `
  --dart-define="APPWRITE_DATABASE_ID=tu_database_id_aqui" `
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=tu_rsvp_collection_id_aqui" `
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=tu_gallery_collection_id_aqui" `
  --dart-define="APPWRITE_STORAGE_ID=tu_storage_id_aqui"
```

**Ejemplo real:**
```powershell
flutter build web --release `
  --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1" `
  --dart-define="APPWRITE_PROJECT_ID=64a1b2c3d4e5f6g7h8i9j0k" `
  --dart-define="APPWRITE_API_KEY=abc123xyz789..." `
  --dart-define="APPWRITE_DATABASE_ID=64a1b2c3d4e5f6g7h8i9j0l" `
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=64a1b2c3d4e5f6g7h8i9j0m" `
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=64a1b2c3d4e5f6g7h8i9j0n" `
  --dart-define="APPWRITE_STORAGE_ID=64a1b2c3d4e5f6g7h8i9j0o"
```

---

## 🌐 Paso 3: Ejecutar la Aplicación

```powershell
.\servir.bat
```

O ejecuta:
```powershell
powershell -ExecutionPolicy Bypass -File servir.ps1
```

Esto abrirá `http://localhost:8080`

---

## ✅ Paso 4: Probar el Formulario de RSVP

### 4.1. Acceder al Formulario

1. Abre `http://localhost:8080/formulario`
2. Deberías ver el formulario de preinscripción

### 4.2. Llenar el Formulario de Prueba

Completa el formulario con datos de prueba:

- **Nombre**: `Juan Pérez`
- **Email**: `juan@test.com`
- **Teléfono**: `612345678`
- **Asistencia**: `Sí`
- **Edad principal**: `Adulto`
- **Alergias**: `Ninguna`
- **Acompañante**: `Sí`
- **Número de acompañantes**: `2`
- **Adultos**: `1`
- **12-18 años**: `1`
- **0-12 años**: `0`
- **Transporte**: `No`
- **Coche propio**: `Sí`
- **Canciones**: `Canción de prueba`
- **Álbum digital**: `Sí`
- **Mensaje**: `Mensaje de prueba`

### 4.3. Enviar el Formulario

1. Haz clic en **"Enviar"** o **"Confirmar"**
2. Deberías ver un mensaje de éxito: **"¡Preinscripción enviada!"**

### 4.4. Verificar en la Consola del Navegador

1. Abre las **Herramientas de Desarrollador** (F12)
2. Ve a la pestaña **Console**
3. Busca mensajes de error (en rojo)
4. Ve a la pestaña **Network** (Red)
5. Busca una petición a `api.lauraydaniel.es`
6. Verifica que el estado sea `200` o `201` (éxito)

---

## 🔍 Paso 5: Verificar en Appwrite

### 5.1. Acceder a Appwrite

1. Abre `https://api.lauraydaniel.es`
2. Inicia sesión con `admin@epicmaker.dev`

### 5.2. Verificar la Colección de RSVPs

1. Ve a **Databases** → Tu base de datos → **Collections**
2. Selecciona la colección **rsvps**
3. Ve a la pestaña **Documents**
4. Deberías ver el registro que acabas de crear con:
   - Nombre: `Juan Pérez`
   - Email: `juan@test.com`
   - Todos los demás campos que llenaste

### 5.3. Verificar los Datos

Haz clic en el documento para ver todos los campos:
- ✅ `name`: "Juan Pérez"
- ✅ `email`: "juan@test.com"
- ✅ `phone`: "612345678"
- ✅ `asistencia`: "si"
- ✅ `edad_principal`: "adulto"
- ✅ `num_adultos`: 1
- ✅ `num_12_18`: 1
- ✅ `acompanantes_json`: Array con los acompañantes

---

## 📸 Paso 6: Probar Subida de Fotos/Videos

### 6.1. Acceder a la Galería

1. En la página principal (`http://localhost:8080`)
2. Busca el botón o sección de **"Subir fotos"** o **"Galería"**

### 6.2. Subir un Archivo de Prueba

1. Haz clic en **"Subir"** o **"Seleccionar archivos"**
2. Selecciona una imagen de prueba (JPG, PNG)
3. Espera a que se suba
4. Deberías ver un mensaje: **"¡Archivos subidos correctamente!"**

### 6.3. Verificar en Appwrite Storage

1. En Appwrite, ve a **Storage**
2. Selecciona tu bucket de galería
3. Deberías ver el archivo que acabas de subir

### 6.4. Verificar en la Colección de Galería

1. Ve a **Databases** → Tu base de datos → **Collections** → **gallery_photos**
2. Ve a **Documents**
3. Deberías ver un nuevo documento con:
   - `fileId`: ID del archivo en Storage
   - `approved`: `false`
   - `uploaded_at`: Fecha/hora de subida

---

## 🐛 Solución de Problemas

### Error: "Backend no configurado"

**Causa:** Las variables de entorno no se compilaron correctamente.

**Solución:**
1. Verifica que compilaste con `--dart-define` para todas las variables
2. Verifica que los valores no tienen espacios extra
3. Recompila: `flutter build web --release --dart-define=...`

### Error: "HTTP 401" o "HTTP 403"

**Causa:** Problema de autenticación o permisos.

**Solución:**
1. Verifica que la API Key tiene los permisos correctos
2. Verifica que el Project ID es correcto
3. En Appwrite, verifica los permisos de las colecciones (deben permitir creación pública o con API Key)

### Error: "HTTP 404"

**Causa:** Collection ID o Database ID incorrectos.

**Solución:**
1. Verifica los IDs en Appwrite (Settings → General)
2. Asegúrate de copiar los IDs completos sin espacios

### Error: CORS

**Causa:** El dominio no está permitido en Appwrite.

**Solución:**
1. En Appwrite → **Settings → Domains**
2. Añade `localhost` y `localhost:8080`
3. También añade `lauraydaniel.es` y `www.lauraydaniel.es`

### Los datos no aparecen en Appwrite

**Verifica:**
1. Abre la consola del navegador (F12) → Console
2. Busca errores en rojo
3. Ve a Network → busca la petición a Appwrite
4. Verifica el código de respuesta:
   - `200` o `201`: Éxito
   - `400`: Error en los datos enviados
   - `401`: Problema de autenticación
   - `404`: Recurso no encontrado
   - `500`: Error del servidor

---

## ✅ Checklist de Prueba

- [ ] Appwrite accesible en `https://api.lauraydaniel.es`
- [ ] Variables de entorno compiladas correctamente
- [ ] Aplicación ejecutándose en `http://localhost:8080`
- [ ] Formulario `/formulario` carga correctamente
- [ ] Formulario se envía sin errores
- [ ] Mensaje de éxito aparece
- [ ] Datos aparecen en Appwrite → Collections → rsvps
- [ ] Subida de archivos funciona
- [ ] Archivos aparecen en Appwrite → Storage
- [ ] Documentos aparecen en Collections → gallery_photos
- [ ] No hay errores en la consola del navegador

---

## 📝 Notas Importantes

1. **Variables de entorno**: Deben compilarse en tiempo de build. No funcionan si solo las defines en runtime.

2. **CORS**: Para desarrollo local, añade `localhost` y `localhost:8080` en Appwrite → Settings → Domains.

3. **Permisos**: Las colecciones deben tener permisos para crear documentos. En Appwrite, ve a la colección → Settings → Permissions.

4. **API Key**: Debe tener permisos de:
   - Read en Databases
   - Create en Databases
   - Read en Storage
   - Create en Storage

---

## 🎉 ¡Listo!

Si todos los pasos funcionan correctamente, tu aplicación está conectada y guardando datos en Appwrite. Ahora puedes desplegar en producción siguiendo `DESPLIEGUE_LAURAYDANIEL.md`.







