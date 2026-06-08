package synapse.api.exeption;

import synapse.api.constants.ErrorMessages;

public class UserNotFound extends RuntimeException{
    public UserNotFound(){
        super(ErrorMessages.USER_NOT_FOUND);
    }
}
