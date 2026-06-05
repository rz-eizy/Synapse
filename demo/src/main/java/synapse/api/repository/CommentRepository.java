package synapse.api.repository;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import synapse.api.model.Comment;

@Repository
public interface CommentRepository extends JpaRepository<Comment, UUID>{
    @Query("SELECT c FROM Comment c JOIN FETCH c.author WHERE c.publication.id = :publicationId")
    Page<Comment> findByPublicationIdWithAuthor(@Param("publicationId") UUID publicationId, Pageable pageable);
}
