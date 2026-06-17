package synapse.api.exeption;

import synapse.api.constants.ErrorMessages;

public class ReportNotFound extends RuntimeException{
    public ReportNotFound(){
        super(ErrorMessages.REPORT_NOT_FOUND);
    }
}
