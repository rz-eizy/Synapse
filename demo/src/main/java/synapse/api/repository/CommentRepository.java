package synapse.api.repository;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import synapse.api.model.Comment;
import synapse.api.model.enums.ModerationStatus;
import synapse.api.model.enums.ReportType;

public interface CommentRepository extends JpaRepository<Comment, UUID>{
    @Query("SELECT c FROM Comment c JOIN FETCH c.author " +
            "WHERE (c.publication.id = :publicationId)" +
            "AND (:status IS NULL OR p.moderationStatus = :status)")
    Page<Comment> findByPublicationIdWithAuthor(
        @Param("publicationId") UUID publicationId,
        @Param("status") ModerationStatus status, 
        Pageable pageable
    );

    long countByModerationStatus(ModerationStatus status);

    @Query("SELECT c FROM Comment c JOIN FETCH c.author " +
        "WHERE (:status IS NULL OR c.moderationStatus = :status) " +
        "AND (:type IS NULL OR EXISTS (SELECT 1 FROM Report r WHERE r.comment = c AND r.type = :type))")
    Page<Comment> findForModeration(
        @Param("status") ModerationStatus status,
        @Param("type") ReportType type,
        Pageable pageable
    );
}
