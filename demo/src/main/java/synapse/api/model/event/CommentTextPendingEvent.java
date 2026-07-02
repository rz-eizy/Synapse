package synapse.api.model.event;

import java.util.UUID;

public record CommentTextPendingEvent(UUID commentId, String content) {}
