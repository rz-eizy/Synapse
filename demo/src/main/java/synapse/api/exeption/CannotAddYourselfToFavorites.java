package synapse.api.exeption;

import synapse.api.constants.ErrorMessages;

public class CannotAddYourselfToFavorites extends RuntimeException{
    public CannotAddYourselfToFavorites(){
        super(ErrorMessages.CANNOT_ADD_YOURSELF_TO_FAVORITES);
    }
}
