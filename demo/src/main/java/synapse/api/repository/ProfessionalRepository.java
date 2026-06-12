package synapse.api.repository;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import synapse.api.model.Professional;

@Repository
public interface ProfessionalRepository extends JpaRepository<Professional, UUID>{

    @Query("SELECT p FROM Professional p JOIN FETCH p.user " +
        "WHERE (:profession_name IS NULL OR p.professionName = :profession_name) " +
        "AND ((:current_work IS NULL OR p.currentWork = :current_work)) " + 
        "AND ((:stars IS NULL OR p.stars = :stars)) ")
    Page<Professional> findProfessionalByFilters(
        @Param("profession_name") String professionName,
        @Param("current_work") String currentWork,
        @Param("stars") Double stars, 
        Pageable pageable
    );
} 
