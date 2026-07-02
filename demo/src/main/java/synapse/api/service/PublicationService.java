package synapse.api.service;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import synapse.api.dto.PublicationDTO;
import synapse.api.exeption.PhotoUploadNotAllowedException;
import synapse.api.exeption.PublicationNotFound;
import synapse.api.exeption.UserNotFound;
import synapse.api.model.Publication;
import synapse.api.model.User;
import synapse.api.model.enums.ModerationStatus;
import synapse.api.repository.PublicationRepository;
import synapse.api.repository.UserRepository;

@Service
@Transactional()
public class PublicationService {
    private static final Clock clock = Clock.system(ZoneId.of("America/Santiago"));
    private static final String PROFESSIONAL_ROLE = "PROFESSIONAL";
    private final PublicationRepository repository;
    private final UserRepository userRepository;

    public PublicationService(PublicationRepository repository, UserRepository user){
        this.repository = repository;
        this.userRepository = user;
    }

    @Transactional
    public Publication createPublication(PublicationDTO dto, UUID authorId){
        User author = userRepository.findById(authorId)
            .orElseThrow(UserNotFound::new);
        
        Publication publication = new Publication();
        publication.setContent(dto.getContent());
        publication.setRegionTag(author.getRegion());
        publication.setCreatedAt(LocalDateTime.now(clock));
        publication.setAuthor(author);

        boolean wantsToAttachPhoto = dto.getImageUrl() != null && !dto.getImageUrl().isBlank();
        if (wantsToAttachPhoto) {
            if (!PROFESSIONAL_ROLE.equalsIgnoreCase(author.getRole())) {
                throw new PhotoUploadNotAllowedException();
            }
            publication.setImageUrl(dto.getImageUrl());
            publication.setModerationStatus(ModerationStatus.PENDING);
        } else {
            publication.setModerationStatus(ModerationStatus.APPROVED);
        }
        return repository.save(publication);
    }

    private void assertCanUploadPhoto(UUID userId){
        User u = userRepository.findById(userId)
                .orElseThrow(UserNotFound::new);
        if (!PROFESSIONAL_ROLE.equalsIgnoreCase(u.getRole())) throw new PhotoUploadNotAllowedException();
    }

    public Page<Publication> getFilteredPublications(String regionTag, UUID authorId, Boolean hasPhoto,int page, int size){
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return repository.findPublicationByFilters(regionTag, authorId, hasPhoto, ModerationStatus.APPROVED, pageable);
    }

    public Publication findById(UUID id){
        return repository.findByIdWithAuthor(id)
            .orElseThrow(PublicationNotFound::new);
    }
    
    @Transactional
    public void handleLike(UUID publicationId, boolean isLike) {
        Publication publication = findById(publicationId);
        if (isLike) {
            publication.incrementLikes();
        } else {
            publication.decrementLikes();
        }
        repository.save(publication);
    }
}
