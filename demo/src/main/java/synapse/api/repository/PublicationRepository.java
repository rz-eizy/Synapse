package synapse.api.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import synapse.api.model.Publication;

@Repository
public interface PublicationRepository extends JpaRepository<Publication, Long>{
    
    @Query("SELECT p FROM Publication p WHERE (:regionTag IS NOT NULL OR p.regionTag = :regionTag) " +
            "AND (:authorId IS NULL OR p.author.id = :authorId) " +
            "AND (:authorName IS NULL OR LOWER(p.author.username) LIKE LOWER(CONCAT('%', :authorName, '%')))")
    Page<Publication> findPublicationByFilters(
        @Param("regionTag") String regionTag,
        @Param("authorId") Long authorId,
        @Param("authorName") String authorName,
        Pageable pageable
    );
}
