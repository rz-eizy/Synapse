package synapse.api.repository;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import synapse.api.model.Professional;
import synapse.api.dto.ProfessionalProfileDTO;

public interface ProfessionalRepository extends JpaRepository<Professional, UUID> {    
    @Query("SELECT new synapse.api.dto.ProfessionalProfileDTO(" +
           "p.id, p.professionName, p.currentWork, p.costWork, u.username, u.profilePictureUrl, " +
           "COALESCE(AVG(r.stars), 0.0), COUNT(r)) " +
           "FROM Professional p " +
           "JOIN p.user u " +
           "LEFT JOIN p.ratings r " +
           "WHERE p.id = :professionalId " +
           "GROUP BY p.id, p.professionName, p.currentWork, p.costWork, u.username, u.profilePictureUrl")
    Optional<ProfessionalProfileDTO> findProfileById(@Param("professionalId") UUID professionalId);

    @Query("SELECT new synapse.api.dto.ProfessionalProfileDTO(" +
       "p.id, p.professionName, p.currentWork, p.costWork, u.username, u.profilePictureUrl, " +
       "COALESCE(AVG(r.stars), 0.0), COUNT(r)) " +
       "FROM Professional p " +
       "JOIN p.user u " +
       "LEFT JOIN p.ratings r " +
       "WHERE (:profession_name IS NULL OR p.professionName = :profession_name) " +
       "AND (:current_work IS NULL OR p.currentWork = :current_work) " +
       "GROUP BY p.id, p.professionName, p.currentWork, p.costWork, u.username, u.profilePictureUrl " +
       "HAVING (:stars IS NULL OR COALESCE(AVG(r.stars), 0.0) = :stars) " +
       "ORDER BY COALESCE(AVG(r.stars), 0.0) DESC") 
    Page<ProfessionalProfileDTO> findProfessionalByFilters(
        @Param("profession_name") String professionName,
        @Param("current_work") String currentWork,
        @Param("stars") Double stars, 
        Pageable pageable
    );
}