# 🧪 Guía Rápida: Probar la Conexión con Appwrite

## ✅ Compilación Completada

Tu aplicación ya está compilada con los IDs de Appwrite correctos.

---

## 🌐 Paso 1: Abrir la Aplicación

El servidor debería haberse iniciado automáticamente. Si no, abre manualmente:

```
http://localhost:8080
```

---

## 📝 Paso 2: Probar el Formulario

### 2.1. Acceder al Formulario

1. Ve a: `http://localhost:8080/formulario`
2. Deberías ver el formulario de preinscripción

### 2.2. Llenar con Datos de Prueba

Completa el formulario:

- **Nombre**: `Juan Pérez`
- **Email**: `juan@test.com`
- **Teléfono**: `612345678`
- **Asistencia**: `Sí`
- **Edad principal**: `Adulto`
- **Alergias**: `Ninguna` (opcional)
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

### 2.3. Enviar

1. Haz clic en **"Enviar"** o **"Confirmar"**
2. Deberías ver: **"¡Preinscripción enviada!"** ✅

---

## 🔍 Paso 3: Verificar en Appwrite

### 3.1. Abrir Appwrite

1. Abre otra pestaña del navegador
2. Ve a: `https://api.lauraydaniel.es`
3. Inicia sesión con: `admin@epicmaker.dev`

### 3.2. Ver el Registro

1. Ve a **Databases** → Base de datos `boda` → **Collections** → **rsvps**
2. Haz clic en la pestaña **"Documents"**
3. Deberías ver un nuevo documento con:
   - Nombre: `Juan Pérez`
   - Email: `juan@test.com`
   - Todos los demás campos

**✅ Si ves el registro:** ¡Perfecto! La conexión funciona correctamente.

---

## 🐛 Si Hay Errores

### Abrir Herramientas de Desarrollador

1. Presiona `F12` en el navegador
2. Ve a la pestaña **Console**
3. Busca mensajes en rojo
4. Copia el error completo

### Ver Peticiones HTTP

1. En las herramientas de desarrollador, ve a la pestaña **Network** (Red)
2. Busca una petición a `api.lauraydaniel.es`
3. Haz clic en ella
4. Ve a **Response** o **Preview**
5. Verifica el código de estado:
   - `200` o `201`: ✅ Éxito
   - `400`: ❌ Error en los datos enviados
   - `401`: ❌ Problema de autenticación (API Key)
   - `404`: ❌ Recurso no encontrado (IDs incorrectos)
   - `500`: ❌ Error del servidor

---

## ✅ Checklist de Prueba

- [ ] Aplicación carga en `http://localhost:8080`
- [ ] Formulario carga en `http://localhost:8080/formulario`
- [ ] Puedo llenar el formulario
- [ ] Al enviar, veo mensaje de éxito
- [ ] No hay errores en la consola (F12 → Console)
- [ ] El registro aparece en Appwrite → Databases → boda → Collections → rsvps → Documents

---

## 🎉 Si Todo Funciona

¡Perfecto! Tu aplicación está lista para desplegar. Sigue la **Parte 3** de `GUIA_COMPLETA_NOVATOS.md` para subirla al servidor.

---

## 📸 Probar Subida de Fotos (Opcional)

1. En la página principal, busca el botón de **"Subir fotos"**
2. Selecciona una imagen
3. Espera a que se suba
4. Verifica en Appwrite → **Storage** → Bucket `6938b171003af1f91b94`
5. Verifica en **Databases** → `boda` → **Collections** → `gallery_photos` → **Documents**

---

**¡Buena suerte! 🚀**







