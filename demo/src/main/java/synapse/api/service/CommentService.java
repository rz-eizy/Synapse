package synapse.api.service;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import synapse.api.model.Comment;
import synapse.api.model.Publication;
import synapse.api.model.User;
import synapse.api.repository.CommentRepository;
import synapse.api.repository.PublicationRepository;
import synapse.api.repository.UserRepository;

@Service
public class CommentService {
    private final CommentRepository repository;
    private final PublicationRepository publicacionrepository;
    private final UserRepository userRepository;

    public CommentService(
        CommentRepository repository, 
        PublicationRepository publicacionrepository, 
        UserRepository userRepository
    ){
        this.repository = repository;
        this.publicacionrepository = publicacionrepository;
        this.userRepository = userRepository;
    }
    @Transactional
    public Comment addComment(UUID publicationId, UUID authorId, String content){
        Publication publication = publicacionrepository.findById(publicationId)
                .orElseThrow(() -> new RuntimeException("Publicacion no encontrada"));
        User user = userRepository.findById(authorId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        
        Comment newComment = new Comment();
        newComment.setAuthor(user);
        newComment.setContent(content);
        newComment.setPublication(publication);
        
        return repository.save(newComment);
    }

    public Page<Comment> findPublicationComents(UUID publicationId, int page, int size){
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return repository.findByPublicationIdWithAuthor(publicationId, pageable);
    }
}
