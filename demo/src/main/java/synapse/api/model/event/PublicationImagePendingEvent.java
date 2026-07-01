package synapse.api.model.event;

import java.util.UUID;

public record PublicationImagePendingEvent(UUID publicationId, String imageUrl) {}