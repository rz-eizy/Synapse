package synapse.api.constants;

public class ErrorMessages {
    private ErrorMessages(){
        throw new UnsupportedOperationException("Utility class");
    }
    // Mensajes de error para validacion de usuario
    public static final String USERNAME_ALREADY_EXISTS = "El UserName ya existe.";
    public static final String EMAIL_ALREADY_EXISTS = "El Email ya existe.";
    public static final String CANNOT_ADD_YOURSELF_TO_FAVORITES = "No te puedes agregar a ti mismo a favoritos";

    // Entidades
    public static final String PHOTO_UPLOAD_NOT_ALLOWED = "Solo los usuarios profesionales pueden adjuntar fotos en sus publicaciones";
    public static final String CANNOT_MODIFY_OWN_ACCOUNT = "Un administrador no puede modificar el estado de su propia cuenta";
    public static final String PROFESSIONAL_NOT_FOUND = "El profesional no existe";
    public static final String PUBLICATION_NOT_FOUND = "La publicacion no existe";
    public static final String COMMENT_NOT_FOUND = "El comentario no existe";
    public static final String REPORT_NOT_FOUND = "El reporte no existe";
    public static final String USER_NOT_FOUND = "El Usuario no existe";
}
