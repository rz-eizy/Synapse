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
           "p.id, p.professionName, p.institutions, p.yearsExperience, p.city, p.businessHours, p.modality, p.professionalDescription, p.costWork, u.username, u.profilePictureUrl, " +
           "COALESCE(AVG(r.stars), 0.0), COUNT(r)) " +
           "FROM Professional p " +
           "JOIN p.user u " +
           "LEFT JOIN p.ratings r " +
           "WHERE p.id = :professionalId " +
           "GROUP BY p.id, p.professionName, p.institutions, p.yearsExperience, p.city, p.businessHours, p.modality, p.professionalDescription, p.costWork, u.username, u.profilePictureUrl")
    Optional<ProfessionalProfileDTO> findProfileById(@Param("professionalId") UUID professionalId);

    @Query("SELECT new synapse.api.dto.ProfessionalProfileDTO(" +
       "p.id, p.professionName, p.institutions, p.yearsExperience, p.city, p.businessHours, p.modality, p.professionalDescription, p.costWork, u.username, u.profilePictureUrl, " +
       "COALESCE(AVG(r.stars), 0.0), COUNT(r)) " +
       "FROM Professional p " +
       "JOIN p.user u " +
       "LEFT JOIN p.ratings r " +
       "WHERE (:profession_name IS NULL OR p.professionName = :profession_name) " +
       "AND (:institutions IS NULL OR p.institutions = :institutions) " +
       "GROUP BY p.id, p.professionName, p.institutions, p.yearsExperience, p.city, p.businessHours, p.modality, p.professionalDescription, p.costWork, u.username, u.profilePictureUrl " +
       "HAVING (:stars IS NULL OR COALESCE(AVG(r.stars), 0.0) = :stars) " +
       "ORDER BY COALESCE(AVG(r.stars), 0.0) DESC") 
    Page<ProfessionalProfileDTO> findProfessionalByFilters(
        @Param("profession_name") String professionName,
        @Param("institutions") String institutions,
        @Param("stars") Double stars, 
        Pageable pageable
    );

    @Query("SELECT new synapse.api.dto.ProfessionalProfileDTO(" +
       "p.id, p.professionName, p.institutions, p.yearsExperience, p.city, p.businessHours, p.modality, p.professionalDescription, p.costWork, u.username, u.profilePictureUrl, " +
       "COALESCE(AVG(r.stars), 0.0), COUNT(r)) " +
       "FROM Professional p " +
       "JOIN p.user u " +
       "LEFT JOIN p.ratings r " +
       "WHERE u IN (SELECT fav FROM User owner JOIN owner.favorites fav WHERE owner.id = :userId) " +
       "GROUP BY p.id, p.professionName, p.institutions, p.yearsExperience, p.city, p.businessHours, p.modality, p.professionalDescription, p.costWork, u.username, u.profilePictureUrl")
    Page<ProfessionalProfileDTO> findFavoriteProfessionalsByUserId(
        @Param("userId") UUID userId,
        Pageable pageable
    );

    Optional<Professional> findByUserId(UUID userId);
}