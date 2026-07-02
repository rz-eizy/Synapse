package synapse.api.service;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.UUID;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import synapse.api.dto.CommentDTO;
import synapse.api.exeption.PublicationNotFound;
import synapse.api.exeption.UserNotFound;
import synapse.api.model.Comment;
import synapse.api.model.Publication;
import synapse.api.model.User;
import synapse.api.model.enums.ModerationStatus;
import synapse.api.model.event.CommentTextPendingEvent;
import synapse.api.repository.CommentRepository;
import synapse.api.repository.PublicationRepository;
import synapse.api.repository.UserRepository;

@Service
public class CommentService {
    private final CommentRepository repository;
    private final UserRepository userRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final PublicationRepository publicacionrepository;
    private static final Clock clock = Clock.system(ZoneId.of("America/Santiago"));

    public CommentService(
        CommentRepository repository,  
        UserRepository userRepository,
        ApplicationEventPublisher eventPublisher,
        PublicationRepository publicacionrepository
    ){
        this.repository = repository;
        this.userRepository = userRepository;
        this.eventPublisher = eventPublisher;
        this.publicacionrepository = publicacionrepository;
    }
    @Transactional
    public Comment addComment(CommentDTO dto){
        Publication publication = publicacionrepository.findById(dto.getPublicationId())
                .orElseThrow(PublicationNotFound::new);
        User user = userRepository.findById(dto.getAuthorId())
                .orElseThrow(UserNotFound::new);
        
        Comment newComment = new Comment();
        newComment.setAuthor(user);
        newComment.setContent(dto.getContent());
        newComment.setPublication(publication);
        newComment.setCreatedAt(LocalDateTime.now(clock));
        newComment.setModerationStatus(ModerationStatus.PENDING);
        
        Comment savedComment = repository.save(newComment);
        eventPublisher.publishEvent(new CommentTextPendingEvent(savedComment.getId(), savedComment.getContent()));
        return savedComment;
    }

    public Page<Comment> findPublicationComents(UUID publicationId, int page, int size){
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return repository.findByPublicationIdWithAuthor(publicationId, ModerationStatus.APPROVED, pageable);
    }
}
