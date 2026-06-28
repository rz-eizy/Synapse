package synapse.api.exeption;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

import synapse.api.constants.ErrorMessages;

@ResponseStatus(HttpStatus.FORBIDDEN)
public class CannotModifyOwnAccountException extends RuntimeException {
    public CannotModifyOwnAccountException() {
        super(ErrorMessages.CANNOT_MODIFY_OWN_ACCOUNT);
    }
}