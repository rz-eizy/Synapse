package synapse.api.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import synapse.api.dto.admin.ReportDetailDTO;
import synapse.api.model.Report;

public interface ReportRepository extends JpaRepository<Report, UUID> {

    long countByResolvedTrueAndResolvedAtBetween(LocalDateTime start, LocalDateTime end);

    long countByPublicationIdAndResolvedFalse(UUID publicationId);

    long countByCommentIdAndResolvedFalse(UUID commentId);

    @Query("SELECT new synapse.api.dto.admin.ReportDetailDTO(r.id, r.type, r.description, r.createdAt, u.username, r.resolved) " +
           "FROM Report r JOIN r.reporter u WHERE r.publication.id = :publicationId ORDER BY r.createdAt DESC")
    List<ReportDetailDTO> findReportDetailsByPublicationId(@Param("publicationId") UUID publicationId);

    @Query("SELECT new synapse.api.dto.admin.ReportDetailDTO(r.id, r.type, r.description, r.createdAt, u.username, r.resolved) " +
           "FROM Report r JOIN r.reporter u WHERE r.comment.id = :commentId ORDER BY r.createdAt DESC")
    List<ReportDetailDTO> findReportDetailsByCommentId(@Param("commentId") UUID commentId);

    @Modifying
    @Query("UPDATE Report r SET r.resolved = true, r.resolvedAt = :now WHERE r.publication.id = :publicationId AND r.resolved = false")
    void resolveByPublicationId(@Param("publicationId") UUID publicationId, @Param("now") LocalDateTime now);

    @Modifying
    @Query("UPDATE Report r SET r.resolved = true, r.resolvedAt = :now WHERE r.comment.id = :commentId AND r.resolved = false")
    void resolveByCommentId(@Param("commentId") UUID commentId, @Param("now") LocalDateTime now);

    @Modifying
    @Query("UPDATE Report r SET r.resolved = true, r.resolvedAt = :now WHERE r.reportedUser.id = :userId AND r.resolved = false")
    void resolveByReportedUserId(@Param("userId") UUID userId, @Param("now") LocalDateTime now);
}