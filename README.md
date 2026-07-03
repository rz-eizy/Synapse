# Appoyo (por Equipo Synapse)

## Descripción del Proyecto
**Appoyo** es una red dedicada a Tutores y Cuidadores de Niños Neurodivergentes. 

**Justificación:** Se consideró que una red para tutores era la opción más óptima, ya que es un problema cuya solución carece de competencia y proveerá una ayuda significativa a los cuidadores, quienes suelen sufrir de una enorme carga mental y emocional por la naturaleza de sus funciones. Este proyecto genera un espacio seguro donde las personas que cuidan a neurodivergentes podrán expresar de forma clara sus ideas y necesidades sin preocuparse de ser juzgados.

## Equipo de Desarrollo
* **Alesandro Duarte:** Backend
* **Eloy Prado:** Líder Técnico / Integración
* **Joaquín Sobarzo:** Frontend

---

## Stack Tecnológico
* **Backend:** Java 21 / Spring Boot 4.0.5
* **Base de Datos:** PostgreSQL 14.22 (trixie)
* **Autenticación y Seguridad:** Spring Security / JWT (JSON Web Tokens)
* **Frontend Móvil:** Flutter (Dart)
* **Frontend Web (Admin):** React + TypeScript

---

## Requisitos Previos
Para ejecutar este proyecto en su entorno local, asegúrese de tener instalado lo siguiente:
* [Java Development Kit (JDK) 21](https://www.oracle.com/java/technologies/javase/jdk21-archive-downloads.html)
* [PostgreSQL](https://www.postgresql.org/) (o [Docker](https://docs.docker.com/get-docker/) para usar la versión en contenedor)
* [Maven 3.8 o superior](https://maven.apache.org/download.cgi)
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Node.js y npm](https://nodejs.org/)
* En el **directorio raíz** del proyecto, cree un archivo llamado `.env`.
* Agregue y guarde las siguientes variables (reemplace con sus datos):
   ```env
   MAIL_USERNAME=suUsuario
   MAIL_PASSWORD=suClaveSecreta
   SPRING_DATASOURCE_URL=suUrlPotgres
   SPRING_DATASOURCE_USERNAME=suUsuario
   SPRING_DATASOURCE_PASSWORD=suClaveSecreta
   JWT_SECRET_KEY=suClaveSecreta
   JWT_ALGORITHM=suAlgoritmoSecreto
   JWT_EXPIRATION=suFechaExpiración
   JWT_REFRESH_EXPIRATION=suFechaRefrescoExpiración
   CLOUDFLARE_ACOUNT=suCuentaCloudflare
   CLOUDFLARE_ACCESS_KEY=suKeySecreta
   CLOUDFLARE_SECRET_KEY=suKeySecreta
   CLOUDFLARE_BUCKET_NAME=suNombreBucket
   CLOUDFLARE_PUBLIC_ID=suIdPublicaSecreta
   ```
---

## Pasos para Ejecución Local

### 1. Base de Datos (PostgreSQL vía Docker)
> **Documentación oficial:** [Referencia de Docker Compose](https://docs.docker.com/compose/)

1. Levante la base de datos en segundo plano ejecutando:
    ``` bash
    docker-compose up -d
    ```
2. Conéctese a la base de datos usando el puerto y la clave que especificó para validar su funcionamiento.

### 2. Backend (Spring Boot)
1. Diríjase al directorio del backend:
    ``` bash
    cd demo
    ```
2. **IMPORTANTE - Primera ejecución:** Si es la primera vez que va a ejecutar el código, debe dirigirse al archivo `application-prod.properties` y cambiar el valor de `spring.jpa.hibernate.ddl-auto` de `validate` a `update`. Esto permitirá que la base de datos genere las tablas necesarias.
3. Levante el servidor ejecutando:
    ``` bash
    ./mvnw spring-boot:run
    ```

### 3. Frontend Web (Panel de Administración)
> **Documentación oficial:** [React](https://react.dev/learn/installation) | [npm](https://docs.npmjs.com/)
1. Abra una nueva terminal y diríjase al directorio del panel de administración:
    ``` bash
    cd frontend-admin
    ```
2. Instale las dependencias del proyecto (solo es necesario la primera vez o si el package.json sufre cambios):
    ``` bash
    npm install
    ```
3. Inicie el servidor de desarrollo local:
    ``` bash
    npm run dev
    ```

### 4. Frontend Móvil (Flutter)
> **Documentación oficial:** [Instalación de Flutter](https://docs.flutter.dev/get-started/install) | [Guía de inicio rápido](https://docs.flutter.dev/get-started/test-drive)
**Nota:** Debe tener un emulador Android abierto, o un dispositivo Android físico conectado a su PC mediante USB o WiFi en modo depuración (Debug).
1. Abra una nueva terminal y navegue a la carpeta de la aplicación móvil:
    ``` bash
    cd mobile
    ```
2. Verifique la lista de dispositivos disponibles ejecutando:
    ``` bash
    flutter devices
    ```
3. Identifique el ID (o Tag) de su dispositivo o emulador (ej. emulator-5554) y ejecute la aplicación reemplazando id_de_su_dispositivo:
    ``` bash
    flutter run -d id_de_su_dispositivo
    ```
---