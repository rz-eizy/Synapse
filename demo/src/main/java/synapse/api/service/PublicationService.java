package synapse.api.service;

import java.time.LocalDateTime;

import synapse.api.model.User;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import synapse.api.dto.PublicationDTO;
import synapse.api.model.Publication;
import synapse.api.repository.PublicationRepository;
import synapse.api.repository.UserRepository;

@Service
@Transactional()
public class PublicationService {
    private final PublicationRepository repository;
    private final UserRepository userRepository;

    public PublicationService(PublicationRepository repository, UserRepository user){
        this.repository = repository;
        this.userRepository = user;
    }

    public Publication createPublication(PublicationDTO dto, Long authorId){
        User author = userRepository.findById(authorId)
            .orElseThrow(() -> new IllegalArgumentException("usuario no identificado con id: " + authorId));
        
        Publication publication = new Publication();
        publication.setContent(dto.getContent());
        publication.setRegionTag(dto.getRegionTag());
        publication.setCreatedAt(LocalDateTime.now());
        publication.setAuthor(author);

        if (dto.getImageUrl() != null && !dto.getImageUrl().isBlank()) publication.setImageUrl(dto.getImageUrl());
        return repository.save(publication);
    }

    public Page<Publication> getFilteredPublications(String regionTag, Long authorId, String authorName, int page, int size){
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        String nameFilter = (authorName != null && !authorName.isBlank()) ? authorName : null;
        return repository.findPublicationByFilters(regionTag, authorId, nameFilter, pageable);
    }

    public Publication findById(Long id){
        return repository.findById(id).orElse(null);
    }
}
