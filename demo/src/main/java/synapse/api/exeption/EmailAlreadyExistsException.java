package synapse.api.exeption;

import synapse.api.constants.ErrorMessages;

public class EmailAlreadyExistsException extends RuntimeException{
    public EmailAlreadyExistsException(){
        super(ErrorMessages.EMAIL_ALREADY_EXISTS);
    }
}
