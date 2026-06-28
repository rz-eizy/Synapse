package synapse.api.exeption;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

@RestControllerAdvice
public class GlobalExceptionHandler {
    private String er = "error";
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<Map<String, String>> handleMaxUploadSizeExceeded(MaxUploadSizeExceededException exc){
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(Map.of("Error", "El archivo subido excede el maximo permitido"));
    }

    @ExceptionHandler({UserNotFound.class, PublicationNotFound.class, CommentNotFound.class,
                    ProfessionalNotFound.class, ReportNotFound.class})
    public ResponseEntity<Map<String, String>> handleNotFound(RuntimeException exc){
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(er, exc.getMessage()));
    }

    @ExceptionHandler({EmailAlreadyExistsException.class, UsernameAlreadyExistsException.class, IllegalStateException.class})
    public ResponseEntity<Map<String, String>> handleConflict(RuntimeException exc){
        return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(er, exc.getMessage()));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleBadRequest(IllegalArgumentException exc){
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(er, exc.getMessage()));
    }
}
