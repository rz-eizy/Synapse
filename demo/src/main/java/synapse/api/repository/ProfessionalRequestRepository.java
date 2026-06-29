package synapse.api.repository;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import synapse.api.model.ProfessionalRequest;
import synapse.api.model.enums.RequestStatus;

public interface ProfessionalRequestRepository extends JpaRepository<ProfessionalRequest,UUID> {
    long countByUserId(UUID userId);

    long countByStatus(RequestStatus status);
    
    boolean existsByUserIdAndStatus(UUID userId, RequestStatus status);

    Page<ProfessionalRequest> findAllByStatus(RequestStatus status, Pageable pageable);
}
