# Guía Paso a Paso: Crear Colecciones en PocketBase

## 📋 Colección 1: `rsvps` (Confirmaciones de Asistencia)

### Paso 1: Crear la colección
1. En el panel de PocketBase, haz clic en **"Collections"** en el menú izquierdo (o busca el icono de base de datos)
2. Haz clic en el botón **"+ New Collection"** o **"New"** (arriba a la derecha)
3. En el campo **"Name"**, escribe exactamente: `rsvps`
4. Haz clic en **"Create"** o **"Save"**

### Paso 2: Añadir campos básicos (obligatorios)

Haz clic en **"New Field"** para cada campo:

#### Campo 1: `name`
- **Name**: `name`
- **Type**: Selecciona **"Text"**
- **Required**: ✅ Marca la casilla (obligatorio)
- Haz clic en **"Save"** o **"Create"**

#### Campo 2: `email`
- **Name**: `email`
- **Type**: Selecciona **"Email"**
- **Required**: ✅ Marca la casilla (obligatorio)
- Haz clic en **"Save"**

#### Campo 3: `phone`
- **Name**: `phone`
- **Type**: Selecciona **"Text"**
- **Required**: ✅ Marca la casilla (obligatorio)
- Haz clic en **"Save"**

#### Campo 4: `asistencia`
- **Name**: `asistencia`
- **Type**: Selecciona **"Select"**
- **Required**: ✅ Marca la casilla (obligatorio)
- **Options**: En el campo de opciones, escribe cada opción en una línea:
  ```
  si
  no
  ```
- Haz clic en **"Save"**

#### Campo 5: `edad_principal`
- **Name**: `edad_principal`
- **Type**: Selecciona **"Select"**
- **Required**: ✅ Marca la casilla (obligatorio)
- **Options**: Escribe cada opción en una línea:
  ```
  adulto
  12-18
  0-12
  ```
- Haz clic en **"Save"**

### Paso 3: Añadir campos opcionales

#### Campo 6: `alergias_principal`
- **Name**: `alergias_principal`
- **Type**: Selecciona **"Text"**
- **Required**: ❌ NO marques (opcional)
- Haz clic en **"Save"**

#### Campo 7: `acompanante`
- **Name**: `acompanante`
- **Type**: Selecciona **"Select"**
- **Required**: ❌ NO marques (opcional)
- **Options**:
  ```
  si
  no
  ```
- Haz clic en **"Save"**

#### Campo 8: `num_acompanantes`
- **Name**: `num_acompanantes`
- **Type**: Selecciona **"Number"**
- **Required**: ❌ NO marques (opcional)
- **Min**: `0`
- **Max**: `9`
- Haz clic en **"Save"**

#### Campo 9: `num_adultos`
- **Name**: `num_adultos`
- **Type**: Selecciona **"Number"**
- **Required**: ❌ NO marques (opcional)
- **Min**: `0`
- Haz clic en **"Save"**

#### Campo 10: `num_12_18`
- **Name**: `num_12_18`
- **Type**: Selecciona **"Number"**
- **Required**: ❌ NO marques (opcional)
- **Min**: `0`
- Haz clic en **"Save"**

#### Campo 11: `num_0_12`
- **Name**: `num_0_12`
- **Type**: Selecciona **"Number"**
- **Required**: ❌ NO marques (opcional)
- **Min**: `0`
- Haz clic en **"Save"**

#### Campo 12: `necesita_transporte`
- **Name**: `necesita_transporte`
- **Type**: Selecciona **"Select"**
- **Required**: ❌ NO marques (opcional)
- **Options**:
  ```
  si
  no
  ```
- Haz clic en **"Save"**

#### Campo 13: `coche_propio`
- **Name**: `coche_propio`
- **Type**: Selecciona **"Select"**
- **Required**: ❌ NO marques (opcional)
- **Options**:
  ```
  si
  no
  ```
- Haz clic en **"Save"**

#### Campo 14: `canciones`
- **Name**: `canciones`
- **Type**: Selecciona **"Text"**
- **Required**: ❌ NO marques (opcional)
- Haz clic en **"Save"**

#### Campo 15: `album_digital`
- **Name**: `album_digital`
- **Type**: Selecciona **"Select"**
- **Required**: ❌ NO marques (opcional)
- **Options**:
  ```
  si
  no
  ```
- Haz clic en **"Save"**

#### Campo 16: `mensaje_novios`
- **Name**: `mensaje_novios`
- **Type**: Selecciona **"Text"**
- **Required**: ❌ NO marques (opcional)
- Haz clic en **"Save"**

#### Campo 17: `acompanantes_json`
- **Name**: `acompanantes_json`
- **Type**: Selecciona **"JSON"**
- **Required**: ❌ NO marques (opcional)
- Haz clic en **"Save"**

#### Campo 18: `created_at`
- **Name**: `created_at`
- **Type**: Selecciona **"Date"**
- **Required**: ❌ NO marques (opcional)
- Haz clic en **"Save"**

#### Campo 19: `origen_form`
- **Name**: `origen_form`
- **Type**: Selecciona **"Text"**
- **Required**: ❌ NO marques (opcional)
- Haz clic en **"Save"**

### Paso 4: Configurar permisos (API Rules)

1. En la colección `rsvps`, busca la pestaña **"API Rules"** o **"Rules"**
2. Haz clic en **"Create rule"** o **"New rule"**
3. Configura la regla para permitir crear registros públicamente:
   - **Rule type** o **Expression**: Deja vacío O escribe: `@request.auth.id != "" || @request.auth.id = ""`
   - **Action**: Selecciona **"create"**
   - Haz clic en **"Save"**

**Nota:** Si no ves la opción de dejar vacío, busca una opción que diga "Allow public access" o "Anyone can create".

---

## 📸 Colección 2: `gallery_photos` (Galería de Fotos)

### Paso 1: Crear la colección
1. Haz clic en **"+ New Collection"** nuevamente
2. En el campo **"Name"**, escribe exactamente: `gallery_photos`
3. Haz clic en **"Create"**

### Paso 2: Añadir campos

#### Campo 1: `file`
- **Name**: `file`
- **Type**: Selecciona **"File"**
- **Required**: ✅ Marca la casilla (obligatorio)
- **Options** (si aparecen):
  - **Max select**: `1`
  - **Max size**: `50` MB (o más si quieres permitir videos grandes)
  - **MIME types**: `image/*,video/*` (para permitir imágenes y videos)
- Haz clic en **"Save"**

#### Campo 2: `approved`
- **Name**: `approved`
- **Type**: Selecciona **"Bool"** o **"Boolean"**
- **Required**: ❌ NO marques (opcional)
- **Default**: `false` (si hay opción de valor por defecto)
- Haz clic en **"Save"**

#### Campo 3: `uploaded_at`
- **Name**: `uploaded_at`
- **Type**: Selecciona **"Date"**
- **Required**: ❌ NO marques (opcional)
- Haz clic en **"Save"**

### Paso 3: Configurar permisos (API Rules)

1. En la colección `gallery_photos`, ve a la pestaña **"API Rules"**
2. Haz clic en **"Create rule"**
3. Configura igual que `rsvps`:
   - Permite crear a todos (público)
   - **Action**: **"create"**
   - Haz clic en **"Save"**

---

## ✅ Verificación Final

Después de crear ambas colecciones, deberías ver:
- ✅ Colección `rsvps` con 19 campos
- ✅ Colección `gallery_photos` con 3 campos
- ✅ Ambas con permisos de creación públicos

## 🧪 Probar que funciona

Puedes probar creando un registro de prueba desde la interfaz de PocketBase:
1. Ve a la colección `rsvps`
2. Haz clic en **"+ New record"** o **"New"**
3. Llena algunos campos de prueba
4. Guarda el registro

Si se guarda correctamente, ¡todo está bien configurado! 🎉

---

## 📝 Notas Importantes

- **Nombres de campos**: Deben ser EXACTAMENTE como se muestra (con guiones bajos, sin espacios)
- **Tipos de campo**: Asegúrate de seleccionar el tipo correcto (Text, Email, Select, Number, etc.)
- **Opciones Select**: Cada opción debe ir en una línea separada
- **Permisos**: Si no configuras los permisos públicos, la app Flutter no podrá crear registros



