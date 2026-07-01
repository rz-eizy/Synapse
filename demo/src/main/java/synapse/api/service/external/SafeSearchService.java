package synapse.api.service.external;

import com.google.cloud.vision.v1.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;
import synapse.api.config.SafeSearchProperties;
import synapse.api.model.enums.ModerationStatus;
import synapse.api.model.event.PublicationImagePendingEvent;
import synapse.api.repository.PublicationRepository;

import java.util.List;

@Service
public class SafeSearchService {
    private static final Logger log = LoggerFactory.getLogger(SafeSearchService.class);
    private final ImageAnnotatorClient visionClient;
    private final PublicationRepository publicationRepository;
    private final SafeSearchProperties properties;

    public SafeSearchService(
            ImageAnnotatorClient visionClient,
            PublicationRepository publicationRepository,
            SafeSearchProperties properties
    ) {
        this.visionClient = visionClient;
        this.publicationRepository = publicationRepository;
        this.properties = properties;
    }

    /*
        Se ejecuta en el pool "safeSearchExecutor" DESPUÉS de que la transacción
        de createPublication haga commit. Garantía: el registro ya existe en BD.
    */
    @Async("safeSearchExecutor")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onPublicationImagePending(PublicationImagePendingEvent event) {
        log.info("[SafeSearch] Iniciando análisis para publicación {} | url: {}",
                event.publicationId(), event.imageUrl());
        try {
            ModerationStatus result = analyze(event.imageUrl());
            publicationRepository.updateModerationStatus(event.publicationId(), result);
            log.info("[SafeSearch] Publicación {} → {}", event.publicationId(), result);
        } catch (Exception e) {
            log.error("[SafeSearch] Análisis fallido para publicación {}. " +
                      "Permanece en PENDING para revisión manual. Causa: {}",
                      event.publicationId(), e.getMessage(), e);
        }
    }

    private ModerationStatus analyze(String imageUrl) {
        ImageSource source = ImageSource.newBuilder().setImageUri(imageUrl).build();
        Image image = Image.newBuilder().setSource(source).build();
        Feature feature = Feature.newBuilder()
                .setType(Feature.Type.SAFE_SEARCH_DETECTION)
                .build();

        AnnotateImageRequest request = AnnotateImageRequest.newBuilder()
                .addFeatures(feature)
                .setImage(image)
                .build();

        BatchAnnotateImagesResponse batchResponse =
                visionClient.batchAnnotateImages(List.of(request));

        AnnotateImageResponse response = batchResponse.getResponsesList().get(0);

        if (response.hasError()) {
            log.warn("[SafeSearch] Vision API retornó un error para {}: {}",
                    imageUrl, response.getError().getMessage());
            return ModerationStatus.PENDING; 
        }

        return evaluate(response.getSafeSearchAnnotation());
    }

    /* 
        categoría supera el umbral de rechazo → REJECTED
        las categorías están bajo el umbral de aprobación → APPROVED
        Zona gris → queda PENDING para revisión manual
    */
    private ModerationStatus evaluate(SafeSearchAnnotation a) {
        Likelihood rejectThreshold  = Likelihood.valueOf(properties.getRejectFrom());
        Likelihood approveThreshold = Likelihood.valueOf(properties.getApproveBelow());

        List<Likelihood> scores = List.of(
                a.getAdult(),
                a.getViolence(),
                a.getRacy(),
                a.getMedical(),
                a.getSpoof()
        );
        if (scores.stream().anyMatch(s -> s.getNumber() >= rejectThreshold.getNumber())) return ModerationStatus.REJECTED;
        if (scores.stream().allMatch(s -> s.getNumber() < approveThreshold.getNumber())) return ModerationStatus.APPROVED;
        return ModerationStatus.PENDING;
    }
}