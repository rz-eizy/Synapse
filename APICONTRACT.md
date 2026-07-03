# Contrato de API — Synapse Backend

El presente define el contrato formal de la API, detallando las estructuras de datos, URIs, codigos de respuesta y formatos estandarizados entre la applicacion Flutter, Dashboard Web y el servidor backend.

---

## Reglas Generales

| Campo | Valor |
|---|---|
| **Base URL (emulador Android)** | `http://10.0.2.2:8080/api` |
| **Base URL (local / producción)** | `http://localhost:8080/api` |
| **Content-Type** | `application/json; charset=UTF-8` |
| **Autenticación** | JWT Bearer Token en header `Authorization` |
| **Paginación** | Parámetros `page` (default `0`) y `size` (default `20`) |

### Formato estándar de error

```json
{
  "error": "Mensaje descriptivo del error"
}
```

### Roles disponibles
`USER` · `PROFESSIONAL` · `ADMIN`

### Enumeraciones

| Enum | Valores |
|---|---|
| `AccountStatus` | `ACTIVE`, `SUSPENDED`, `BANNED` |
| `ModerationStatus` | `PENDING`, `APPROVED`, `REJECTED` |
| `ReportType` | `DISINFORMATION`, `INAPPROPRIATE`, `BULLYING`, `SPAM`, `HATE`, `OTHER` |
| `RequestStatus` | `PENDING`, `APPROVED`, `REJECTED` |

---

## 1. Autenticación — `/api/auth`
> Rutas públicas, no requieren token.

---

### 1.1 Registrar usuario
`POST /api/auth/register`

**Request Body:**
```json
{
  "name": "eloy_prado",
  "email": "e.prado02@ufromail.cl",
  "password": "PasswordSegura123"
}
```

| Campo | Tipo | Obligatorio | Validaciones |
|---|---|---|---|
| `name` | `String` | `true` | `@NotBlank` |
| `email` | `String` | `true` | `@NotBlank`, `@Email` |
| `password` | `String` | `true` | `@NotBlank` |

**Respuestas:**

`200 OK`
```json
{
  "id": "uuid-del-usuario",
  "name": "eloy_prado",
  "email": "e.prado02@ufromail.cl"
}
```

| Código | Causa |
|---|---|
| `400 Bad Request` | Validación fallida (campo vacío, email inválido) |
| `409 Conflict` | El email o nombre de usuario ya existe |

---

### 1.2 Iniciar sesión
`POST /api/auth/login`

**Request Body:**
```json
{
  "email": "e.prado02@ufromail.cl",
  "password": "PasswordSegura123"
}
```

| Campo | Tipo | Obligatorio | Validaciones |
|---|---|---|---|
| `email` | `String` | `true` | `@Email` |
| `password` | `String` | `true` | `@NotBlank` |

**Respuestas:**

`200 OK`
```json
{
  "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9..."
}
```

| Código | Causa |
|---|---|
| `400 Bad Request` | Validación fallida |
| `401 Unauthorized` | Credenciales incorrectas |

---

### 1.3 Solicitar recuperación de contraseña
`POST /api/auth/forgot-password`

**Request Body:**
```json
{
  "email": "e.prado02@ufromail.cl"
}
```

**Respuestas:**

`200 OK` — Responde `200` siempre (incluso si el email no existe, por seguridad).

---

### 1.4 Confirmar recuperación de contraseña
`POST /api/auth/reset-password`

**Request Body:**
```json
{
  "email": "e.prado02@ufromail.cl",
  "code": "123456",
  "newPassword": "NuevaPassword456"
}
```

| Campo | Tipo | Obligatorio |
|---|---|---|
| `email` | `String` | `true` |
| `code` | `String` | `true` — OTP de 6 dígitos enviado por correo |
| `newPassword` | `String` | `true` |

**Respuestas:**

| Código | Causa |
|---|---|
| `200 OK` | Contraseña actualizada exitosamente |
| `400 Bad Request` | Algún campo nulo, o código OTP inválido/expirado |

---

## 2. Usuarios — `/api/user`
> Todos los endpoints requieren `Authorization: Bearer <token>`.

---

### 2.1 Obtener perfil propio
`GET /api/user/me`

**Respuestas:**

`200 OK`
```json
{
  "username": "eloy_prado",
  "profilePictureUrl": "https://cdn.example.com/foto.jpg",
  "publications": [],
  "favoriteProfessionalIds": [],
  "role": "USER",
  "rejectedRequestId": null,
  "rejectedRequestMotive": null,
  "professionalOnboarded": false,
  "region": "Araucanía",
  "interestedDiagnostics": "TEA, TDAH"
}
```

| Código | Causa |
|---|---|
| `400 Bad Request` | Usuario no encontrado por su token |
| `401 Unauthorized` | Token ausente o inválido |

---

### 2.2 Editar perfil de usuario
`PATCH /api/user/me`

**Request Body:**
```json
{
  "username": "nuevo_nombre",
  "profilePicture": "https://cdn.example.com/nueva-foto.jpg",
  "currentLocation": "Temuco",
  "description": "Descripción personal actualizada."
}
```

| Campo | Tipo | Obligatorio |
|---|---|---|
| `username` | `String` | `false` |
| `profilePicture` | `String` (URL) | `false` |
| `currentLocation` | `String` | `false` |
| `description` | `String` | `false` |

**Respuestas:**

`200 OK` — Objeto `User` completo actualizado.

| Código | Causa |
|---|---|
| `401 Unauthorized` | Token inválido |
| `409 Conflict` | El nuevo username ya está en uso |

---

### 2.3 Actualizar preferencias
`PUT /api/user/preferences`

**Request Body:**
```json
{
  "region": "Araucanía",
  "interestedDiagnostics": "TEA, TDAH, Ansiedad"
}
```

| Campo | Tipo | Obligatorio |
|---|---|---|
| `region` | `String` | `false` |
| `interestedDiagnostics` | `String` | `false` |

**Respuestas:**

`200 OK` — Sin cuerpo de respuesta.

---

### 2.4 Marcar / desmarcar profesional como favorito (toggle)
`PUT /api/user/favorites/{targetUserId}`

| Parámetro | Tipo | Descripción |
|---|---|---|
| `targetUserId` | `UUID` (path) | ID del usuario a agregar/quitar de favoritos |

**Respuestas:**

`200 OK` — Sin cuerpo de respuesta.

| Código | Causa |
|---|---|
| `400 Bad Request` | Se intentó agregarse a sí mismo como favorito |
| `404 Not Found` | El usuario destino no existe |

---

### 2.5 Listar profesionales favoritos
`GET /api/user/favorites/professionals`

| Parámetro | Tipo | Default | Descripción |
|---|---|---|---|
| `page` | `int` (query) | `0` | Número de página |
| `size` | `int` (query) | `20` | Resultados por página |

**Respuestas:**

`200 OK` — `Page<ProfessionalProfileDTO>` (ver estructura en sección 3).

---

### 2.6 Eliminar cuenta propia (soft delete)
`DELETE /api/user/me`

**Respuestas:**

`204 No Content` — Sin cuerpo de respuesta.

---

## 3. Profesionales — `/api/professional`

---

### 3.1 Obtener perfil de un profesional
`GET /api/professional/{idProfessional}`

> Público — no requiere token.

| Parámetro | Tipo | Descripción |
|---|---|---|
| `idProfessional` | `UUID` (path) | ID del profesional |

**Respuestas:**

`200 OK`
```json
{
  "professionalId": "uuid",
  "professionName": "Psicólogo Clínico",
  "institutions": "Universidad de La Frontera",
  "yearsExperience": 5,
  "city": "Temuco",
  "businessHours": "Lunes a Viernes 9:00 - 18:00",
  "modality": "Presencial y Online",
  "professionalDescription": "Especialista en salud mental infantil.",
  "costWork": 35000,
  "username": "dra_perez",
  "profilePictureUrl": "https://cdn.example.com/foto.jpg",
  "averageStars": 4.8,
  "totalReviews": 24,
  "externalContactLink": "https://wa.me/56912345678"
}
```

| Código | Causa |
|---|---|
| `404 Not Found` | No existe un perfil profesional con ese ID |

---

### 3.2 Listar y filtrar profesionales
`GET /api/professional/list`

> Público — no requiere token.

| Parámetro | Tipo | Default | Obligatorio |
|---|---|---|---|
| `profession_name` | `String` (query) | — | `false` |
| `institutions` | `String` (query) | — | `false` |
| `stars` | `Double` (query) | — | `false` — Filtro mínimo de estrellas |
| `page` | `int` (query) | `0` | `false` |
| `size` | `int` (query) | `20` | `false` |

**Respuestas:**

`200 OK` — `Page<ProfessionalProfileDTO>` (ver estructura arriba).

---

### 3.3 Obtener mi perfil profesional
`GET /api/professional/me`

> Requiere token · Requiere rol `PROFESSIONAL`.

**Respuestas:**

`200 OK` — `ProfessionalProfileDTO`.

| Código | Causa |
|---|---|
| `403 Forbidden` | El usuario autenticado no tiene rol `PROFESSIONAL` |

---

### 3.4 Editar mi perfil profesional
`PATCH /api/professional/me`

> Requiere token · Requiere rol `PROFESSIONAL`.

**Request Body:**
```json
{
  "username": "dra_perez_actualizado",
  "profilePicture": "https://cdn.example.com/nueva-foto.jpg",
  "currentLocation": "Temuco",
  "description": "Descripción general actualizada.",
  "professionName": "Neuropsicóloga",
  "institutions": "UFRO, UDP",
  "personalContact": "https://wa.me/56912345678",
  "businessHours": "Lunes a Viernes 9:00 - 18:00",
  "costWork": 40000,
  "yearsExperience": 6,
  "city": "Temuco",
  "workRegion": "Araucanía",
  "modality": "Online",
  "professionalDescription": "Especialista en TEA.",
  "healthCoverage": "Fonasa, Isapre Cruz Blanca",
  "treatedDiagnostics": "TEA, TDAH, Ansiedad"
}
```

| Campo | Tipo | Obligatorio |
|---|---|---|
| `username` | `String` | `false` |
| `profilePicture` | `String` (URL) | `false` |
| `currentLocation` | `String` | `false` |
| `description` | `String` | `false` |
| `professionName` | `String` | `false` |
| `institutions` | `String` | `false` |
| `personalContact` | `String` (URL) | `false` |
| `businessHours` | `String` | `false` |
| `costWork` | `Integer` | `false` |
| `yearsExperience` | `Integer` | `false` |
| `city` | `String` | `false` |
| `workRegion` | `String` | `false` |
| `modality` | `String` | `false` |
| `professionalDescription` | `String` | `false` |
| `healthCoverage` | `String` | `false` |
| `treatedDiagnostics` | `String` | `false` |

**Respuestas:**

`200 OK` — Objeto `Professional` actualizado.

---

### 3.5 Calificar a un profesional
`POST /api/professional/rate/{idProfessional}`

> Requiere token. La calificación se envía como **query param**, no en el body.

| Parámetro | Tipo | Descripción |
|---|---|---|
| `idProfessional` | `UUID` (path) | ID del profesional a calificar |
| `stars` | `double` (query) | Puntuación entre `1.0` y `5.0` |

**Respuestas:**

`200 OK` — Sin cuerpo de respuesta.

| Código | Causa |
|---|---|
| `400 Bad Request` | `stars` está fuera del rango `[1.0 – 5.0]` |
| `404 Not Found` | El profesional no existe |

---

## 4. Solicitudes de Profesionalización — `/api/professional/requests`

---

### 4.1 Enviar solicitud de acreditación
`POST /api/professional/requests`

> Requiere token · Requiere rol `USER`.

| Parámetro | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `imageUrl` | `String` (query) | `true` | URL pública de la imagen de verificación subida previamente a Cloudflare R2 |

**Respuestas:**

`201 Created` — Objeto `ProfessionalRequest`:
```json
{
  "id": "uuid-solicitud",
  "user": { "...": "..." },
  "verificationPictureUrl": "https://cdn.example.com/doc.jpg",
  "status": "PENDING",
  "createdAt": "2026-07-03T10:00:00",
  "adminNotes": null
}
```

| Código | Causa |
|---|---|
| `403 Forbidden` | El usuario tiene rol `ADMIN` (los admins no pueden solicitar) |
| `409 Conflict` | Ya existe una solicitud pendiente para este usuario |

---

### 4.2 Aprobar solicitud y promover a profesional *(Admin)*
`PATCH /api/professional/requests/{idRequest}/approve`

> Requiere token · Requiere rol `ADMIN`.

| Parámetro | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `idRequest` | `UUID` (path) | `true` | ID de la solicitud |
| `professionName` | `String` (query) | `true` | Título profesional asignado |
| `notes` | `String` (query) | `false` | Notas del administrador |

**Respuestas:**

`200 OK` — Objeto `Professional` creado.

| Código | Causa |
|---|---|
| `404 Not Found` | La solicitud no existe |

---

### 4.3 Rechazar solicitud *(Admin)*
`PATCH /api/professional/requests/{idRequest}/reject`

> Requiere token · Requiere rol `ADMIN`.

| Parámetro | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `idRequest` | `UUID` (path) | `true` | ID de la solicitud |
| `notes` | `String` (query) | `false` | Motivo del rechazo |

**Respuestas:**

`200 OK` — Objeto `ProfessionalRequest` con `status: REJECTED`.

| Código | Causa |
|---|---|
| `404 Not Found` | La solicitud no existe |

---

### 4.4 Listar todas las solicitudes *(Admin)*
`GET /api/professional/requests`

> Requiere token · Requiere rol `ADMIN`.

| Parámetro | Tipo | Default |
|---|---|---|
| `page` | `int` (query) | `0` |
| `size` | `int` (query) | `20` |

**Respuestas:**

`200 OK` — `Page<ProfessionalRequest>`.

---

## 5. Publicaciones — `/api/publication`

---

### 5.1 Obtener URL presignada para subir imagen
`GET /api/publication/upload-url`

> Requiere token.

| Parámetro | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `contentType` | `String` (query) | `true` | MIME type del archivo, ej. `image/jpeg` |

**Respuestas:**

`200 OK`
```json
{
  "uploadUrl": "https://r2.cloudflarestorage.com/bucket/uuid.jpg?X-Amz-Signature=...",
  "publicUrl": "https://cdn.example.com/uuid.jpg"
}
```

> El cliente debe hacer un `PUT` directo a `uploadUrl` con el binario de la imagen. El resultado `publicUrl` es el que se incluye luego en el body de creación de publicación.

---

### 5.2 Crear publicación
`POST /api/publication`

> Requiere token.

**Request Body:**
```json
{
  "content": "Comparto este recurso con la comunidad.",
  "regionTag": "Araucanía",
  "imageUrl": "https://cdn.example.com/uuid.jpg"
}
```

| Campo | Tipo | Obligatorio | Validaciones |
|---|---|---|---|
| `content` | `String` | `true` | `@NotBlank`, máx. 1000 caracteres |
| `regionTag` | `String` | `true` | `@NotBlank`, máx. 100 caracteres |
| `imageUrl` | `String` (URL) | `false` | URL pública de Cloudflare R2 |

**Respuestas:**

`201 Created` — Objeto `Publication` completo.

| Código | Causa |
|---|---|
| `400 Bad Request` | Validación fallida (contenido vacío, regionTag faltante) |
| `401 Unauthorized` | Token inválido |

---

### 5.3 Obtener una publicación por ID
`GET /api/publication/{idPublication}`

> Público — no requiere token.

| Parámetro | Tipo | Descripción |
|---|---|---|
| `idPublication` | `UUID` (path) | ID de la publicación |

**Respuestas:**

`200 OK` — Objeto `Publication`:
```json
{
  "id": "uuid",
  "content": "Texto de la publicación.",
  "imageUrl": "https://cdn.example.com/imagen.jpg",
  "regionTag": "Araucanía",
  "createdAt": "2026-07-03T10:00:00",
  "likes": 14,
  "commentsCount": 3,
  "moderationStatus": "APPROVED",
  "author": { "id": "uuid-autor", "username": "dra_perez", "...": "..." }
}
```

| Código | Causa |
|---|---|
| `404 Not Found` | La publicación no existe o su `moderationStatus` no es `APPROVED` |

---

### 5.4 Dar o quitar like a una publicación
`POST /api/publication/{idPublication}/like`

> Requiere token.

| Parámetro | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `idPublication` | `UUID` (path) | `true` | ID de la publicación |
| `isLike` | `boolean` (query) | `true` | `true` para dar like, `false` para quitarlo |

**Respuestas:**

`200 OK` — Sin cuerpo de respuesta.

| Código | Causa |
|---|---|
| `404 Not Found` | La publicación no existe |

---

### 5.5 Obtener feed de publicaciones (paginado)
`GET /api/publication/feed`

> Requiere token. El backend filtra automáticamente por la **región del usuario autenticado**.

| Parámetro | Tipo | Default | Obligatorio | Descripción |
|---|---|---|---|---|
| `authorId` | `UUID` (query) | — | `false` | Filtrar por autor |
| `hasPhoto` | `Boolean` (query) | — | `false` | `true` = solo con imagen |
| `page` | `int` (query) | `0` | `false` | |
| `size` | `int` (query) | `20` | `false` | |

**Respuestas:**

`200 OK` — `Page<Publication>`.

| Código | Causa |
|---|---|
| `400 Bad Request` | El usuario autenticado no tiene `region` configurada |

---

## 6. Comentarios — `/api/comment`
> Todos los endpoints requieren token.

---

### 6.1 Publicar un comentario
`POST /api/comment/{idPublication}`

> ⚠️ El contenido del comentario se envía como **query param**, no como JSON body.

| Parámetro | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `idPublication` | `UUID` (path) | `true` | ID de la publicación |
| `content` | `String` (query) | `true` | Texto del comentario |

**Respuestas:**

`201 Created` — Objeto `Comment`:
```json
{
  "id": "uuid-comentario",
  "content": "Muchas gracias por la información.",
  "moderationStatus": "APPROVED",
  "createdAt": "2026-07-03T10:30:00",
  "author": { "id": "uuid-autor", "username": "eloy_prado" }
}
```

| Código | Causa |
|---|---|
| `400 Bad Request` | `content` vacío, o error de autenticación al extraer el ID del usuario |
| `404 Not Found` | La publicación no existe |

---

### 6.2 Obtener comentarios de una publicación
`GET /api/comment/{idPublication}`

> No requiere token.

| Parámetro | Tipo | Default | Descripción |
|---|---|---|---|
| `idPublication` | `UUID` (path) | — | ID de la publicación |
| `page` | `int` (query) | `0` | |
| `size` | `int` (query) | `20` | |

**Respuestas:**

`200 OK` — `Page<Comment>` (ver estructura arriba).

| Código | Causa |
|---|---|
| `400 Bad Request` | `idPublication` nulo o inválido |

---

## 7. Reportes — `/api/report`
> Requiere token.

---

### 7.1 Crear un reporte
`POST /api/report`

**Request Body:**
```json
{
  "type": "INAPPROPRIATE",
  "description": "Contenido difamatorio hacia un profesional.",
  "idReportedUser": "uuid-usuario-reportado",
  "idComment": null,
  "idPublication": null
}
```

| Campo | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `type` | `ReportType` (enum) | `true` | Ver valores en tabla de enumeraciones |
| `description` | `String` | `false` | Descripción adicional del reporte |
| `idReportedUser` | `UUID` | `false` | Mutuamente excluyente con los demás IDs |
| `idComment` | `UUID` | `false` | Mutuamente excluyente |
| `idPublication` | `UUID` | `false` | Mutuamente excluyente |

> Exactamente uno de `idReportedUser`, `idComment` o `idPublication` debe ser proporcionado.

**Respuestas:**

`201 Created` — Objeto `Report`:
```json
{
  "id": "uuid-reporte",
  "type": "INAPPROPRIATE",
  "description": "Contenido difamatorio.",
  "resolved": false,
  "createdAt": "2026-07-03T10:00:00",
  "resolvedAt": null
}
```

| Código | Causa |
|---|---|
| `400 Bad Request` | `type` nulo, o ID referenciado no existe |
| `404 Not Found` | El usuario, comentario o publicación reportado no existe |

---

## 8. Administración de Cuentas — `/api/admin/accounts`
> Todos los endpoints requieren token · Requieren rol `ADMIN`.

---

### 8.1 Listar cuentas
`GET /api/admin/accounts`

| Parámetro | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `status` | `AccountStatus` (query) | `false` | Filtrar por estado |
| `type` | `String` (query) | `false` | Filtrar por rol/tipo de cuenta |
| `page` | `int` (query) | `false` | Default `0` |
| `limit` | `int` (query) | `false` | Default `20` |

**Respuestas:**

`200 OK` — `Page<User>`.

---

### 8.2 Obtener detalle de cuenta
`GET /api/admin/accounts/{id}`

| Parámetro | Tipo | Descripción |
|---|---|---|
| `id` | `UUID` (path) | ID del usuario |

**Respuestas:**

`200 OK`
```json
{
  "id": "uuid",
  "username": "eloy_prado",
  "email": "e.prado02@ufromail.cl",
  "role": "USER",
  "accountStatus": "ACTIVE",
  "suspendedUntil": null,
  "statusReason": null,
  "createdAt": "2026-03-01T10:00:00",
  "reportCount": 2
}
```

| Código | Causa |
|---|---|
| `404 Not Found` | El usuario no existe |

---

### 8.3 Actualizar estado de cuenta
`PATCH /api/admin/accounts/{id}/status`

| Parámetro | Tipo | Descripción |
|---|---|---|
| `id` | `UUID` (path) | ID del usuario objetivo |

**Request Body:**
```json
{
  "status": "SUSPENDED",
  "reason": "Comportamiento reiterado inadecuado en comentarios.",
  "suspendedUntil": "2026-07-10T00:00:00"
}
```

| Campo | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `status` | `AccountStatus` | `true` | Nuevo estado de la cuenta |
| `reason` | `String` | `false` | Motivo del cambio |
| `suspendedUntil` | `LocalDateTime` | `false` | Obligatorio si `status` es `SUSPENDED` |

**Respuestas:**

`200 OK` — Objeto `User` actualizado.

| Código | Causa |
|---|---|
| `400 Bad Request` | `status` nulo |
| `404 Not Found` | Usuario no encontrado |
| `409 Conflict` | El admin intentó modificar su propia cuenta |

---

### 8.4 Historial de moderación de una cuenta
`GET /api/admin/accounts/{id}/history`

| Parámetro | Tipo | Descripción |
|---|---|---|
| `id` | `UUID` (path) | ID del usuario |
| `page` | `int` (query) | Default `0` |
| `limit` | `int` (query) | Default `20` |

**Respuestas:**

`200 OK` — `Page<AccountModerationLog>`:
```json
{
  "content": [
    {
      "id": "uuid-log",
      "targetUser": { "...": "..." },
      "admin": { "...": "..." },
      "previousStatus": "ACTIVE",
      "newStatus": "SUSPENDED",
      "reason": "Spam reiterado.",
      "suspendedUntil": "2026-07-10T00:00:00",
      "createdAt": "2026-07-03T10:00:00"
    }
  ]
}
```

---

## 9. Moderación de Contenido — `/api/admin`
> Todos los endpoints requieren token · Requieren rol `ADMIN`.

---

### 9.1 Listar publicaciones para moderación
`GET /api/admin/posts`

| Parámetro | Tipo | Default | Descripción |
|---|---|---|---|
| `status` | `ModerationStatus` (query) | — | Filtrar por estado de moderación |
| `type` | `ReportType` (query) | — | Filtrar por tipo de reporte asociado |
| `sort` | `String` (query) | `createdAt,desc` | Campos válidos: `createdAt`, `likes` |
| `page` | `int` (query) | `0` | |
| `limit` | `int` (query) | `20` | |

**Respuestas:**

`200 OK` — `Page<Publication>`.

---

### 9.2 Obtener detalle de publicación para moderación
`GET /api/admin/posts/{id}`

**Respuestas:**

`200 OK` — Objeto `Publication` completo.

| Código | Causa |
|---|---|
| `404 Not Found` | Publicación no existe |

---

### 9.3 Moderar una publicación
`PATCH /api/admin/posts/{id}/moderate`

**Request Body:**
```json
{
  "status": "REJECTED",
  "reason": "El contenido viola las políticas de la comunidad."
}
```

| Campo | Tipo | Obligatorio |
|---|---|---|
| `status` | `ModerationStatus` | `true` |
| `reason` | `String` | `false` |

**Respuestas:**

`200 OK` — Objeto `Publication` con `moderationStatus` actualizado.

| Código | Causa |
|---|---|
| `400 Bad Request` | `status` nulo |
| `404 Not Found` | Publicación no existe |

---

### 9.4 Obtener reportes de una publicación
`GET /api/admin/posts/{id}/reports`

**Respuestas:**

`200 OK` — `List<ReportDetailDTO>`:
```json
[
  {
    "id": "uuid-reporte",
    "type": "INAPPROPRIATE",
    "description": "Contenido difamatorio.",
    "createdAt": "2026-07-01T14:00:00",
    "reporterUsername": "eloy_prado",
    "resolved": false
  }
]
```

---

### 9.5 Listar comentarios para moderación
`GET /api/admin/comments`

Mismos parámetros que `GET /api/admin/posts` (ver 9.1).

**Respuestas:**

`200 OK` — `Page<Comment>`.

---

### 9.6 Moderar un comentario
`PATCH /api/admin/comments/{id}/moderate`

Mismo body que `PATCH /api/admin/posts/{id}/moderate` (ver 9.3).

**Respuestas:**

`200 OK` — Objeto `Comment` con `moderationStatus` actualizado.

---

### 9.7 Obtener reportes de un comentario
`GET /api/admin/comments/{id}/reports`

**Respuestas:**

`200 OK` — `List<ReportDetailDTO>` (ver estructura en 9.4).

---

## 10. Dashboard Administrativo — `/api/admin/dashboard`
> Requiere token · Requiere rol `ADMIN`.

---

### 10.1 Estadísticas generales
`GET /api/admin/dashboard/stats`

**Respuestas:**

`200 OK`
```json
{
  "pendingPosts": 12,
  "pendingComments": 5,
  "pendingAccounts": 3,
  "resolvedToday": 8,
  "totalReports": 47,
  "approvalRate": 0.82
}
```

---

## Resumen de Endpoints

| # | Método | URI | Rol requerido | Descripción |
|---|---|---|---|---|
| 1.1 | `POST` | `/api/auth/register` | Público | Registrar usuario |
| 1.2 | `POST` | `/api/auth/login` | Público | Iniciar sesión |
| 1.3 | `POST` | `/api/auth/forgot-password` | Público | Solicitar reset de contraseña |
| 1.4 | `POST` | `/api/auth/reset-password` | Público | Confirmar reset de contraseña |
| 2.1 | `GET` | `/api/user/me` | Autenticado | Ver perfil propio |
| 2.2 | `PATCH` | `/api/user/me` | Autenticado | Editar perfil de usuario |
| 2.3 | `PUT` | `/api/user/preferences` | Autenticado | Actualizar región e intereses |
| 2.4 | `PUT` | `/api/user/favorites/{targetUserId}` | Autenticado | Toggle favorito |
| 2.5 | `GET` | `/api/user/favorites/professionals` | Autenticado | Listar profesionales favoritos |
| 2.6 | `DELETE` | `/api/user/me` | Autenticado | Eliminar cuenta propia |
| 3.1 | `GET` | `/api/professional/{idProfessional}` | Público | Ver perfil de profesional |
| 3.2 | `GET` | `/api/professional/list` | Público | Listar/filtrar profesionales |
| 3.3 | `GET` | `/api/professional/me` | `PROFESSIONAL` | Ver mi perfil profesional |
| 3.4 | `PATCH` | `/api/professional/me` | `PROFESSIONAL` | Editar mi perfil profesional |
| 3.5 | `POST` | `/api/professional/rate/{idProfessional}` | Autenticado | Calificar a un profesional |
| 4.1 | `POST` | `/api/professional/requests` | `USER` | Enviar solicitud de acreditación |
| 4.2 | `PATCH` | `/api/professional/requests/{idRequest}/approve` | `ADMIN` | Aprobar solicitud |
| 4.3 | `PATCH` | `/api/professional/requests/{idRequest}/reject` | `ADMIN` | Rechazar solicitud |
| 4.4 | `GET` | `/api/professional/requests` | `ADMIN` | Listar solicitudes |
| 5.1 | `GET` | `/api/publication/upload-url` | Autenticado | Obtener URL de subida a Cloudflare R2 |
| 5.2 | `POST` | `/api/publication` | Autenticado | Crear publicación |
| 5.3 | `GET` | `/api/publication/{idPublication}` | Público | Ver publicación |
| 5.4 | `POST` | `/api/publication/{idPublication}/like` | Autenticado | Toggle like |
| 5.5 | `GET` | `/api/publication/feed` | Autenticado | Feed paginado y filtrado |
| 6.1 | `POST` | `/api/comment/{idPublication}` | Autenticado | Publicar comentario |
| 6.2 | `GET` | `/api/comment/{idPublication}` | Autenticado | Listar comentarios |
| 7.1 | `POST` | `/api/report` | Autenticado | Crear reporte |
| 8.1 | `GET` | `/api/admin/accounts` | `ADMIN` | Listar cuentas |
| 8.2 | `GET` | `/api/admin/accounts/{id}` | `ADMIN` | Detalle de cuenta |
| 8.3 | `PATCH` | `/api/admin/accounts/{id}/status` | `ADMIN` | Actualizar estado de cuenta |
| 8.4 | `GET` | `/api/admin/accounts/{id}/history` | `ADMIN` | Historial de moderación |
| 9.1 | `GET` | `/api/admin/posts` | `ADMIN` | Listar publicaciones |
| 9.2 | `GET` | `/api/admin/posts/{id}` | `ADMIN` | Detalle de publicación |
| 9.3 | `PATCH` | `/api/admin/posts/{id}/moderate` | `ADMIN` | Moderar publicación |
| 9.4 | `GET` | `/api/admin/posts/{id}/reports` | `ADMIN` | Reportes de una publicación |
| 9.5 | `GET` | `/api/admin/comments` | `ADMIN` | Listar comentarios |
| 9.6 | `PATCH` | `/api/admin/comments/{id}/moderate` | `ADMIN` | Moderar comentario |
| 9.7 | `GET` | `/api/admin/comments/{id}/reports` | `ADMIN` | Reportes de un comentario |
| 10.1 | `GET` | `/api/admin/dashboard/stats` | `ADMIN` | Estadísticas del dashboard |
