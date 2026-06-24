# Integrantes:
Alesandro Duarte (Backend)

Eloy Prado (Líder Técnico/Integración)

Joaquín Sobarzo (Frontend)

# Planteamiento del Proyecto:
Red para Tutores/Cuidadores de Niños Neurodivergentes

# Nombre de app:
Synapse

# Justificación de Selección:
Se consideró que la red para tutores era la opción más óptima, ya que es un problema cuya solución es carente de competencia y proveerá de una ayuda significativa a los cuidadores que sufren de enorme carga mental y emocional por la naturaleza de sus funciones, de igual manera presentará un apoyo significativo a generar un espacio seguro donde personas que cuidan a neurodivergentes podrán expresar de forma más clara sus ideas sin preocuparse de ser juzgados.

# Stack Tecnológico:
* **Backend:** Java 21 / Spring Boot 4.0.5
* **Base de Datos:** PostgreSQL 
* **Autenticación & Seguridad:** Spring Security / JWT (JSON Web Tokens)
* **Frontend:** Flutter

# Requisitos:
* Java Development Kit (JDK) 21 instalado
* PostgreSQL 14.22 trixie
* Maven 3.8 o superior

# Pasos Para Ejecución:

## PostgreSQL (Base de Datos):
1. Cree su archivo .env en el directorio raíz del proyecto, agregue y guarde:
    DB_PASSWORD=suClaveSecreta
    DB_PORT=puertoDePreferencia
2. Para levantar la base de datos, en una terminal diríjase al directorio raíz del proyecto ingrese lo siguiente: **docker-compose up -d**
3. Conéctese a la base de datos usando el puerto y clave que especificó en el archivo .env

## Spring Boot (Backend):
1. En su terminal cambie al directorio **demo** con **cd demo**
2. Para levantar el servidor debe de ingresar el siguiente comando: **./mvnw spring-boot:run**

## Flutter (Frontend)
Debe tener un emulador de un teléfono Android, una máquina virtual de un teléfono Android o bien su teléfono Android vía USB o WiFi a su computador en modo debug.
1. En una nueva terminal que se encuentre en la carpeta raíz del proyecto cambie al directorio **mobile** con **cd mobile**
2. Una vez ahí ejecute el comando **flutter devices** para ver la lista de dispositivos que tiene disponibles.
3. Para ejecutar la aplicación en el dispositivo de su preferencia ejecute **flutter run -d id_de_su_dispositivo**