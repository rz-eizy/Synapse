package synapse.api.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.transaction.Transactional;
import synapse.api.model.Publication;
import synapse.api.model.enums.ModerationStatus;
import synapse.api.model.enums.ReportType;

public interface PublicationRepository extends JpaRepository<Publication, UUID>{
    @Query("SELECT p FROM Publication p JOIN FETCH p.author WHERE p.id = :id")
    Optional<Publication> findByIdWithAuthor(@Param("id") UUID id);
    
    @Query("SELECT p FROM Publication p JOIN FETCH p.author " +
       "WHERE (:regionTag IS NULL OR p.regionTag = :regionTag) " +
       "AND(:status IS NULL OR p.moderationStatus = :status) " +
       "AND (:authorId IS NULL OR p.author.id = :authorId) " +
       "AND (:hasPhoto IS NULL OR (:hasPhoto = true AND p.imageUrl IS NOT NULL) OR (:hasPhoto = false AND p.imageUrl IS NULL))")
    Page<Publication> findPublicationByFilters(
        @Param("regionTag") String regionTag,
        @Param("authorId") UUID authorId,
        @Param("hasPhoto") Boolean hasPhoto,
        @Param("status") ModerationStatus status,
        Pageable pageable
    );

    long countByModerationStatus(ModerationStatus status);

    @Query("SELECT p FROM Publication p JOIN FETCH p.author " +
        "WHERE (:status IS NULL OR p.moderationStatus = :status) " +
        "AND (:type IS NULL OR EXISTS (SELECT 1 FROM Report r WHERE r.publication = p AND r.type = :type))")
    Page<Publication> findForModeration(
        @Param("status") ModerationStatus status,
        @Param("type") ReportType type,
        Pageable pageable
    );

    @Modifying
    @Transactional
    @Query("UPDATE Publication p SET p.moderationStatus = :status WHERE p.id = :id")
    void updateModerationStatus(@Param("id") UUID id, @Param("status") ModerationStatus status);
}
