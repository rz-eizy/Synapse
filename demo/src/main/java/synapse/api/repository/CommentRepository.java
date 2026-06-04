package synapse.api.repository;

import org.springframework.stereotype.Repository;

import synapse.api.model.Comment;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long>{
    @Query("SELECT c FROM Comment c JOIN FETCH c.author WHERE c.publication.id = :publicationId")
    Page<Comment> findByPublicationIdWithAuthor(@Param("publicationId") Long publicationId, Pageable pageable);
}
