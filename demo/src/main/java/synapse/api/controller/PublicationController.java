package synapse.api.controller;

import java.util.Map;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import synapse.api.dto.PublicationDTO;
import synapse.api.exeption.UserNotFound;
import synapse.api.model.Publication;
import synapse.api.model.User;
import synapse.api.security.CustomUserDetails;
import synapse.api.service.PublicationService;
import synapse.api.service.UserService;
import synapse.api.service.external.CloudflareR2Service;

@RestController
@RequestMapping("/api/publication")
public class PublicationController {
    private final PublicationService publicationService;
    private final CloudflareR2Service cloudflareService;
    private final UserService userService;

    public PublicationController(
        PublicationService publicationService, 
        CloudflareR2Service cloudflareService,
        UserService userService
    ) {
        this.publicationService = publicationService;
        this.cloudflareService = cloudflareService;
        this.userService = userService;
    }
    
    @GetMapping("/upload-url")
    public ResponseEntity<Map<String, String>> getUploadUrl(
        @AuthenticationPrincipal CustomUserDetails principal,
        @RequestParam("contentType") String contentType
    ) {
        publicationService.assertCanUploadPhoto(principal.getId());
        return ResponseEntity.ok(cloudflareService.generatePresignedUploadUrl(contentType));
    }
    
    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Publication> postNewPublication(
        @RequestBody @Valid PublicationDTO dataDto,
        @AuthenticationPrincipal CustomUserDetails principal
    ) {
        UUID authorId = principal.getId();
        Publication savedPublication = publicationService.createPublication(dataDto, authorId);
        return new ResponseEntity<>(savedPublication, HttpStatus.CREATED);
    }
    
    /* 
        Obtener 1 publicacion (cuando se hace clic)
    */
    @GetMapping("/{idPublication}")
    public ResponseEntity<Publication> getPublication(@PathVariable UUID idPublication) {
        Publication publication = publicationService.findById(idPublication);
        return publication != null ? ResponseEntity.ok(publication) : ResponseEntity.notFound().build();
    }
    /* 
        Dar like o quitar like de una publicacion
    */
    @PostMapping("/{idPublication}/like")
    public ResponseEntity<Publication> postMethodName(
        @PathVariable UUID idPublication,
        @RequestParam boolean isLike
    ) {
        publicationService.handleLike(idPublication, isLike);
        return new ResponseEntity<>(HttpStatus.OK);
    }
    

    /* 
        Obtener publicaciones paginadas 20 max
        Dichas publicaciónes seleccionar en base a:
            - Mas cercanas a la fecha actual
            - ubicación
            - intereses del usuario
    */
    @GetMapping("/feed")
    public ResponseEntity<Page<Publication>> getGeneralFeed(
        @AuthenticationPrincipal CustomUserDetails principal,
        @RequestParam(value = "authorId", required = false) UUID authorId,
        @RequestParam(value = "hasPhoto", required = false) Boolean hasPhoto,
        @RequestParam(value = "page", defaultValue = "0") int page,
        @RequestParam(value = "size", defaultValue = "20") int size 
    ) {
        User user = userService.findById(principal.getId())
            .orElseThrow(UserNotFound::new);

        String region = user.getRegion();
        if (region == null || region.isBlank()) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }

        Page<Publication> feed = publicationService.getFilteredPublications(region, authorId, hasPhoto, page, size);
        return ResponseEntity.ok(feed); 
    }
}