package synapse.api.exeption;

import synapse.api.constants.ErrorMessages;

public class ProfessionalNotFound extends RuntimeException {
    public ProfessionalNotFound(){
        super(ErrorMessages.PROFESSIONAL_NOT_FOUND);
    }
}
