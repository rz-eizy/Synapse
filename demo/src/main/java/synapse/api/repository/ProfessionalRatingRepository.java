package synapse.api.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import synapse.api.model.ProfessionalRating;

public interface ProfessionalRatingRepository extends JpaRepository<ProfessionalRating, UUID>{
    @Query("SELECT pr FROM ProfessionalRating pr WHERE pr.reviewer.id = :reviewerId AND pr.professional.id = :professionalId")
    Optional<ProfessionalRating> findOptional(@Param("reviewerId") UUID reviewerId, @Param("professionalId") UUID professionalId);
}
