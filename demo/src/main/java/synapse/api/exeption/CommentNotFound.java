package synapse.api.exeption;

import synapse.api.constants.ErrorMessages;

public class CommentNotFound extends RuntimeException {
    public CommentNotFound(){
        super(ErrorMessages.COMMENT_NOT_FOUND);
    }
}
