package synapse.api.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import synapse.api.model.ProfessionalRating;

public interface ProfessionalRatingRepository extends JpaRepository<ProfessionalRating, UUID>{
    Optional<ProfessionalRating> findByReviewerIdAndProfessionalId(UUID reviewerId, UUID professionalId);
}
