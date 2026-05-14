package synapse.api.constants;

public class ErrorMessages {
    private ErrorMessages(){
        throw new UnsupportedOperationException("Utility class");
    }
    // Mensajes de error para validacion de usuario
    public static final String USERNAME_ALREADY_EXISTS = "El UserName ya existe.";
    public static final String EMAIL_ALREADY_EXISTS = "El Email ya existe.";

}
