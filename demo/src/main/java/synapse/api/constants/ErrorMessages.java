package synapse.api.constants;

public class ErrorMessages {
    private ErrorMessages(){
        throw new UnsupportedOperationException("Utility class");
    }
    // Mensajes de error para validacion de usuario
    public static final String USERNAME_ALREADY_EXISTS = "El UserName ya existe.";
    public static final String EMAIL_ALREADY_EXISTS = "El Email ya existe.";
    public static final String USER_NOT_FOUND = "El Usuario no existe";
    public static final String CANNOT_ADD_YOURSELF_TO_FAVORITES = "No te puedes agregar a ti mismo a favoritos";
}
