# 📋 Cómo Obtener los IDs de Appwrite

Esta guía te ayudará a obtener todos los IDs necesarios para configurar tu aplicación Flutter con Appwrite.

## 🔑 Variables Necesarias

Necesitas obtener estos valores de tu panel de Appwrite:

1. `APPWRITE_ENDPOINT` - URL del servidor Appwrite
2. `APPWRITE_PROJECT_ID` - ID del proyecto
3. `APPWRITE_API_KEY` - Clave API
4. `APPWRITE_DATABASE_ID` - ID de la base de datos
5. `APPWRITE_RSVP_COLLECTION_ID` - ID de la colección de RSVPs
6. `APPWRITE_GALLERY_COLLECTION_ID` - ID de la colección de galería
7. `APPWRITE_STORAGE_ID` - ID del bucket de almacenamiento

---

## 1️⃣ APPWRITE_ENDPOINT

**Ubicación:** Configuración del servidor

- Si Appwrite está en `https://appwrite.tu-dominio.com`, el endpoint es: `https://appwrite.tu-dominio.com/v1`
- Si Appwrite está en `http://tu-servidor:80`, el endpoint es: `http://tu-servidor/v1`
- **IMPORTANTE:** Debe terminar en `/v1`

**Ejemplo:** `https://appwrite.lauraydaniel.es/v1`

---

## 2️⃣ APPWRITE_PROJECT_ID

**Ubicación:** Panel de Appwrite → Proyecto → Settings → General

1. Inicia sesión en tu panel de Appwrite
2. Selecciona tu proyecto
3. Ve a **Settings** → **General**
4. Busca **Project ID** (es un string largo como `64a1b2c3d4e5f6g7h8i9j0k`)

**Ejemplo:** `64a1b2c3d4e5f6g7h8i9j0k`

---

## 3️⃣ APPWRITE_API_KEY

**Ubicación:** Panel de Appwrite → Settings → API Keys

1. En el panel de Appwrite, ve a **Settings** → **API Keys**
2. Si no tienes una API Key, haz clic en **Create API Key**
3. Configura los permisos:
   - ✅ **Read** en Databases
   - ✅ **Create** en Databases
   - ✅ **Read** en Storage
   - ✅ **Create** en Storage
   - ✅ **Update** en Storage (opcional, para aprobar fotos)
4. Copia la **API Key** (solo se muestra una vez, guárdala bien)

**Ejemplo:** `abc123xyz789def456ghi012jkl345mno678pqr901stu234vwx567`

---

## 4️⃣ APPWRITE_DATABASE_ID

**Ubicación:** Panel de Appwrite → Databases

1. En el panel de Appwrite, ve a **Databases**
2. Selecciona tu base de datos (o créala si no existe)
3. Ve a **Settings** → **General**
4. Busca **Database ID** (es un string largo)

**Ejemplo:** `64a1b2c3d4e5f6g7h8i9j0l`

---

## 5️⃣ APPWRITE_RSVP_COLLECTION_ID

**Ubicación:** Panel de Appwrite → Databases → Tu Base de Datos → Collections

1. En **Databases**, selecciona tu base de datos
2. Ve a la pestaña **Collections**
3. Selecciona la colección de RSVPs (o créala si no existe)
4. Ve a **Settings** → **General**
5. Busca **Collection ID**

**Ejemplo:** `64a1b2c3d4e5f6g7h8i9j0m`

---

## 6️⃣ APPWRITE_GALLERY_COLLECTION_ID

**Ubicación:** Panel de Appwrite → Databases → Tu Base de Datos → Collections

1. En **Databases**, selecciona tu base de datos
2. Ve a la pestaña **Collections**
3. Selecciona la colección de Galería (o créala si no existe)
4. Ve a **Settings** → **General**
5. Busca **Collection ID**

**Ejemplo:** `64a1b2c3d4e5f6g7h8i9j0n`

---

## 7️⃣ APPWRITE_STORAGE_ID

**Ubicación:** Panel de Appwrite → Storage

1. En el panel de Appwrite, ve a **Storage**
2. Selecciona tu bucket de almacenamiento (o créalo si no existe)
3. Ve a **Settings** → **General**
4. Busca **Bucket ID**

**Ejemplo:** `64a1b2c3d4e5f6g7h8i9j0o`

---

## 📝 Crear Colecciones y Storage (Si No Existen)

### Crear Base de Datos

1. Ve a **Databases** → **Create Database**
2. Nombre: `boda` (o el que prefieras)
3. Anota el **Database ID**

### Crear Colección: RSVPs

1. En tu base de datos, ve a **Collections** → **Create Collection**
2. Collection ID: `rsvps` (o déjalo que se genere automáticamente)
3. Nombre: `RSVPs`
4. **Permisos:** Configura para permitir creación pública si es necesario
5. **Atributos:** Añade los campos necesarios:
   - `name` (String, required)
   - `email` (Email, required)
   - `phone` (String, required)
   - `asistencia` (String, required)
   - `edad_principal` (String, required)
   - `alergias_principal` (String, optional)
   - `acompanante` (String, optional)
   - `num_acompanantes` (Integer, optional)
   - `num_adultos` (Integer, optional)
   - `num_12_18` (Integer, optional)
   - `num_0_12` (Integer, optional)
   - `necesita_transporte` (String, optional)
   - `coche_propio` (String, optional)
   - `canciones` (String, optional)
   - `album_digital` (String, optional)
   - `mensaje_novios` (String, optional)
   - `acompanantes_json` (String, optional) - JSON como texto
   - `created_at` (DateTime, optional)
   - `origen_form` (String, optional)

### Crear Colección: Galería

1. En tu base de datos, ve a **Collections** → **Create Collection**
2. Collection ID: `gallery_photos` (o déjalo que se genere automáticamente)
3. Nombre: `Galería de Fotos`
4. **Permisos:** Configura para permitir creación pública si es necesario
5. **Atributos:**
   - `fileId` (String, required) - ID del archivo en Storage
   - `approved` (Boolean, default: false)
   - `uploaded_at` (DateTime, optional)

### Crear Storage Bucket

1. Ve a **Storage** → **Create Bucket**
2. Bucket ID: `gallery` (o déjalo que se genere automáticamente)
3. Nombre: `Galería`
4. **Permisos:** Configura para permitir lectura/escritura pública si es necesario
5. **File Size:** Configura el tamaño máximo (ej: 50MB)
6. **Allowed File Extensions:** `jpg,jpeg,png,webp,heic,heif,mp4,mov,avi,mkv`

---

## ✅ Verificar Configuración

Una vez que tengas todos los IDs, compila la aplicación con:

```powershell
flutter build web --release `
  --dart-define="APPWRITE_ENDPOINT=https://tu-servidor.com/v1" `
  --dart-define="APPWRITE_PROJECT_ID=tu_project_id" `
  --dart-define="APPWRITE_API_KEY=tu_api_key" `
  --dart-define="APPWRITE_DATABASE_ID=tu_database_id" `
  --dart-define="APPWRITE_RSVP_COLLECTION_ID=tu_rsvp_collection_id" `
  --dart-define="APPWRITE_GALLERY_COLLECTION_ID=tu_gallery_collection_id" `
  --dart-define="APPWRITE_STORAGE_ID=tu_storage_id"
```

---

## 🔒 Configurar Dominios Permitidos

Para que tu aplicación web pueda comunicarse con Appwrite:

1. Ve a **Settings** → **Domains**
2. Añade tu dominio (ej: `lauraydaniel.es`)
3. También añade `localhost` si vas a probar localmente

---

## 📚 Recursos Adicionales

- [Documentación de Appwrite](https://appwrite.io/docs)
- [API REST de Appwrite](https://appwrite.io/docs/references/cloud/server-web)
- [Guía de Despliegue](./GUIA_DESPLIEGUE_PRODUCCION.md)







