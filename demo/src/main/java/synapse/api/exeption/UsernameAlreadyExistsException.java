package synapse.api.exeption;

import synapse.api.constants.ErrorMessages;

public class UsernameAlreadyExistsException extends RuntimeException{
    public UsernameAlreadyExistsException(){
        super(ErrorMessages.USERNAME_ALREADY_EXISTS);
    }
}