package synapse.api.service.external;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.web.client.RestClient;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import synapse.api.model.enums.ModerationStatus;
import synapse.api.model.event.CommentTextPendingEvent;
import synapse.api.model.event.PublicationTextPedingEvent;
import synapse.api.repository.CommentRepository;
import synapse.api.repository.PublicationRepository;

import java.util.List;
import java.util.Map;

@Service
public class TextModerationService {
    private static final Logger log = LoggerFactory.getLogger(TextModerationService.class);

    private final PublicationRepository publicationRepository;
    private final CommentRepository commentRepository;
    private final RestClient restClient;

    public TextModerationService(PublicationRepository publicationRepository,
                                 CommentRepository commentRepository,
                                 @Value("${openai.api.key}") String apiKey) {
        this.publicationRepository = publicationRepository;
        this.commentRepository = commentRepository;
        
        this.restClient = RestClient.builder()
                .baseUrl("https://api.openai.com/v1/moderations")
                .defaultHeader("Authorization", "Bearer " + apiKey)
                .build();
    }

    @Async("safeSearchExecutor")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onPublicationCreated(PublicationTextPedingEvent event) {
        log.info("[TextMod] Analizando publicación {}", event.publicationId());
        try {
            ModerationStatus result = analyze(event.content());
            publicationRepository.updateModerationStatus(event.publicationId(), result);
            log.info("[TextMod] Publicación {} → {}", event.publicationId(), result);
        } catch (Exception e) {
            log.error("[TextMod] Fallo al moderar publicación {}. Causa: {}", event.publicationId(), e.getMessage());
        }
    }

    @Async("safeSearchExecutor")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onCommentCreated(CommentTextPendingEvent event) {
        log.info("[TextMod] Analizando comentario {}", event.commentId());
        try {
            ModerationStatus result = analyze(event.content());
            commentRepository.updateModerationStatus(event.commentId(), result);
            log.info("[TextMod] Comentario {} → {}", event.commentId(), result);
        } catch (Exception e) {
            log.error("[TextMod] Fallo al moderar comentario {}. Causa: {}", event.commentId(), e.getMessage());
        }
    }

    private ModerationStatus analyze(String text) {
        if (text == null || text.trim().isEmpty()) {
            return ModerationStatus.APPROVED;
        }

        OpenAiModerationResponse response = restClient.post()
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("input", text))
                .retrieve()
                .body(OpenAiModerationResponse.class);

        if (response == null || response.results() == null || response.results().isEmpty()) {
            return ModerationStatus.APPROVED;
        }

        ModerationResult result = response.results().get(0);

        if (result.flagged()) {
            Categories cats = result.categories();
            if (cats.sexual() || cats.violence() || cats.hate()) {
                return ModerationStatus.REJECTED;
            }
            return ModerationStatus.PENDING;
        }
        
        return ModerationStatus.APPROVED;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record OpenAiModerationResponse(List<ModerationResult> results) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ModerationResult(boolean flagged, Categories categories) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Categories(boolean sexual, boolean violence, boolean hate) {}
}