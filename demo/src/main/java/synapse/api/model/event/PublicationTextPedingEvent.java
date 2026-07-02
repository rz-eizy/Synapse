package synapse.api.model.event;

import java.util.UUID;

public record PublicationTextPedingEvent(UUID publicationId, String content) {} 
