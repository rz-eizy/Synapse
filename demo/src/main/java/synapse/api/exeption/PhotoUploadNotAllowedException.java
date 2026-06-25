package synapse.api.exeption;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

import synapse.api.constants.ErrorMessages;

@ResponseStatus(HttpStatus.FORBIDDEN)
public class PhotoUploadNotAllowedException extends RuntimeException {
    public PhotoUploadNotAllowedException(){
        super(ErrorMessages.PHOTO_UPLOAD_NOT_ALLOWED);
    }
}