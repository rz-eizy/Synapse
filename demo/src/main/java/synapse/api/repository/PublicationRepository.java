package synapse.api.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import synapse.api.model.Publication;

public interface PublicationRepository extends JpaRepository<Publication, UUID>{
    @Query("SELECT p FROM Publication p JOIN FETCH p.author WHERE p.id = :id")
    Optional<Publication> findByIdWithAuthor(@Param("id") UUID id);
    
    @Query("SELECT p FROM Publication p JOIN FETCH p.author " +
           "WHERE (:regionTag IS NULL OR p.regionTag = :regionTag) " +
           "AND (:authorId IS NULL OR p.author.id = :authorId)")
    Page<Publication> findPublicationByFilters(
        @Param("regionTag") String regionTag,
        @Param("authorId") UUID authorId,
        Pageable pageable
    );
}
