# Contrato de API

El presente define el contrato formal de la API, detallando las estructuras de datos, URIs, codigos de respuesta y formatos estandarizados entre la applicacion Flutter y el servidor backend.

## 1. Reglas Generales
* **Base URL Emulador:** `http://10.0.2.2:8080/api`
* **Base URL Producción/Local:** `http://localhost:8080/api`
* **Content-Type:** `application/json; charset=UTF-8`

## 2. Formato Estandar de Error
Todas las respuestas de error que no devuelvan un estado `200` o `201` seguirán de manera estricta la siguiente estructura JSON:
```json
{
  "timestamp": "2026-05-24T18:00:00.000Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Mensaje detallado del error."
}
```
## 3. Endpoints de Autenticación y Registro
### 3.1. Registrar Nuevo Usuario:
* Método: POST
* URI: /auth/register
* Cuerpo de la Petición (Request Body):
```json
{
  "username": "eloy_prado",
  "email": "e.prado02@ufromail.cl",
  "password": "PasswordSegura123",
  "role": "REGULAR", 
  "termsAccepted": true,
  "medicalDataConsent": false
}
```

* Respuestas esperadas:<br>
201(Created):
```json
{
  "message": "Cuenta creada con éxito",
  "userId": 45
}
```
400(Bad Request):
```json
{
  "timestamp": "2026-05-22T20:32:00Z",
  "status": 400,
  "error": "Validation Error",
  "message": "El correo electrónico debe ser una dirección con formato correcto."
}
```
409 (Conflict): En caso de que el correo este usado por otro usuario.

### 3.2. Iniciar Sesión:
* Método: POST
* URI: /auth/login
* Cuerpo de la Petición (Request Body):
```json
{
  "email": "e.prado02@ufromail.cl",
  "password": "PasswordSegura123"
}
```
* Respuestas Esperadas:<br>
200 (Ok):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "eloy_prado",
  "role": "REGULAR"
}
```
401 (Unauthorized):
```json
{
  "timestamp": "2026-05-22T20:35:00Z",
  "status": 401,
  "error": "Unauthorized",
  "message": "Contraseña o correo electrónico incorrectos."
}
```
## 4. Endpoints de Publicaciones (Feed y Comunidad)
### 4.1. Obtener Publicaciones:
* Método: GET
* URI: /publications
* Parámetros de Consulta (Query Params):
* * tab: PROFESSIONALS
* * page: Número_de_página
* Encabezados (Headers):
* * Authorization: Bearer <JWT_TOKEN>
* Respuestas Esperadas:<br>
200 (Ok):
```json
[
  {
    "id": 102,
    "authorName": "Dr. Juan Pérez",
    "authorRole": "PROFESSIONAL",
    "content": "Estrategias de regulación sensorial en el aula.",
    "imageUrl": "http://localhost:8080/uploads/img12.jpg",
    "likesCount": 14,
    "region": "Araucanía",
    "createdAt": "2026-05-24T12:00:00Z"
  }
]
```

### 4.2. Crear Publicación:
* Método: POST
* URI: /publications
* Encabezados (Headers):
* * Authorization: Bearer <JWT_TOKEN>
* Cuerpo de la Petición (Request Body):
```json
{
  "content": "Comparto este texto con la comunidad de Temuco.",
  "imageUrl": null 
}
```
* Respuestas Esperadas:<br>
210 (Created)<br>
403 (Forbidden)
```json
{
  "status": 403,
  "error": "Forbidden",
  "message": "Los usuarios regulares no tienen permisos para adjuntar imágenes a las publicaciones."
}
```


# 5. Endpoints de Comentarios e Interacción
### 5.1. Comentar una Publicación:
* Método: POST
* URI: /publications/{publicationId}/comments
* Encabezados (Headers):
* * Authorization: Bearer <JWT_TOKEN>
* Cuerpo de la Petición (Request Body):
```json
{
  "content": "Muchas gracias por la información, es de gran utilidad para el día a día."
}
```
* Respuestas Esperadas:<br>
210 (Created)
```json
{
  "commentId": 501,
  "message": "Comentario añadido exitosamente."
}
```
404 (Not found): La publicación no existe

### 5.2. Dar "Me gusta" a Publicaciones o Comentarios:
* Método: POST
* URI: /interactions/like
* Encabezados (Headers):
* * Authorization: Bearer <JWT_TOKEN>
* Cuerpo de la Petición (Request Body):
```json
{
  "targetId": 102,
  "targetType": "PUBLICATION" 
}
```
***Notar que targetType*** solo puede ser **PUBLICATION** o **COMMENT**.<br>

* Respuestas Esperadas:<br>
200 (Ok):
```json
{
  "liked": true,
  "currentLikes": 15
}
```

# 6. Endpoints de Perfiles Perfiles, Favoritos y Calificaciones
### 6.1. Marcar/Desmarcar Usuario Favorito:
* Método: POST
* URI: /users/favorites/{profileId}
* Encabezados (Headers):
* * Authorization: Bearer <JWT_TOKEN>
* Respuestas Esperadas:<br>
200 (Ok):
```json
{
  "isFavorite": true,
  "message": "Usuario agregado a tus favoritos de forma exitosa."
}
```
404 (Not found): El perfil no existe

### 6.2. Calificar a un Profesional:
* Método: POST
* URI: /professionals/{professionalId}/ratings
* Encabezados (Headers):
* * Authorization: Bearer <JWT_TOKEN>
* Cuerpo de la Petición (Request Body):

```json
{
  "stars": 5
}
```

* Respuestas Esperadas:<br>
200 (Ok):
```json
{
  "message": "Calificación registrada.",
  "newAverage": 4.8
}
```
404 (Not found): El profesional no existe

400 (Bad Request): Si el numero esta fuera del rango aceptable.


### 6.3. Actualizar Datos de Perfil:
* Método: PUT
* URI: /users/profile
* Encabezados (Headers):
* * Authorization: Bearer <JWT_TOKEN>
* Cuerpo de la Petición (Request Body):

```json
{
  "fullName": "Estefanie Luchsinger",
  "bio": "Psicologa especializada en menores de edad.",
  "professionalData": { 
    "yearsOfExperience": 2,
    "graduationUniversity": "Universidad de La Frontera",
    "sessionCost": 35000
  }
}
```

* Respuestas Esperadas:<br>
200 (Ok)

# 7. Endpoints de Moderación y Administración
### 7.1 Reportar Contenido:

* Método: POST
* URI: /moderation/reports
* Encabezados (Headers):
* * Authorization: Bearer <JWT_TOKEN>
* Cuerpo de la Petición (Request Body):

```json
{
  "contentId": 102,
  "contentType": "PUBLICATION",
  "reason": "Uso de la plataforma para difamación / funa."
}
```
***Notar que contentType*** solo puede ser **PUBLICATION** o **COMMENT**.<br>

* Respuestas Esperadas:<br>
200 (Ok):
```json
{
  "message": "El contenido ha sido reportado!"
}
```

404 (Not found): La id no corresponde a nada.<br>
400 (Bad Request): El contenido no es de un tipo valido.

### 7.2 Bloqueo de Cuenta (Solo un Administrador Puede Realizar Esta Acción):

* Método: PATCH
* URI: /admin/users/{userId}/block
* Encabezados (Headers):
* * Authorization: Bearer <JWT_TOKEN>
* Cuerpo de la Petición (Request Body):

```json
{
  "isPermanent": false,
  "durationDays": 7,
  "reason": "Comportamiento inadecuado reiterado en la sección de comentarios."
}
```
***Notar que contentType*** solo puede ser **PUBLICATION** o **COMMENT**.<br>

* Respuestas Esperadas:<br>
200 (Ok)

# 8. Endpoint Validación Externa
### 8.1 Acreditación de Profesional mediante RUT:

* Método: POST
* URI: /professionals/verify-rut
* Encabezados (Headers):
* * Authorization: Bearer <JWT_TOKEN>
* Cuerpo de la Petición (Request Body):

```json
{
  "rut": "12345678-9"
}
```
***Notar que contentType*** solo puede ser **PUBLICATION** o **COMMENT**.<br>

* Respuestas Esperadas:<br>
200 (Ok):
```json
{
  "verified": true,
  "profession": "Psicólogo Clínico",
  "registrationNumber": "43210",
  "message": "Etiqueta de acreditación otorgada automáticamente."
}
```

422 (Unprocessable Entity): El RUT no esta en los registros del gobierno
503 (Service Unavailable): Fallo de conexión o latencia crítica con la API externa gubernamental.