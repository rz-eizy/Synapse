package synapse.api.exeption;

import synapse.api.constants.ErrorMessages;

public class PublicationNotFound extends RuntimeException {
    public PublicationNotFound(){
        super(ErrorMessages.PUBLICATION_NOT_FOUND);
    }
}
