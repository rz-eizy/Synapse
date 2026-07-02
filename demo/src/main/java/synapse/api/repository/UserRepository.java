package synapse.api.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import synapse.api.dto.admin.AdminAccountDetailDTO;
import synapse.api.model.User;
import synapse.api.model.enums.AccountStatus;

public interface UserRepository extends JpaRepository<User, UUID>{
    Optional<User> findByEmail(String email);

    Optional<User> findByUsername(String username);

    Boolean existsByEmail(String email);

    Boolean existsByUsername(String username);

    @Query("SELECT u FROM User u WHERE (:status IS NULL OR u.accountStatus = :status) AND (:role IS NULL OR u.role = :role)")
    Page<User> findForAdmin(@Param("status") AccountStatus status, @Param("role") String role, Pageable pageable);

    @Query("SELECT new synapse.api.dto.admin.AdminAccountDetailDTO(" +
           "u.id, u.username, u.email, u.role, u.accountStatus, u.suspendedUntil, u.statusReason, u.createdAt, COUNT(r)) " +
           "FROM User u LEFT JOIN Report r ON r.reportedUser = u " +
           "WHERE u.id = :userId " +
           "GROUP BY u.id, u.username, u.email, u.role, u.accountStatus, u.suspendedUntil, u.statusReason, u.createdAt")
    Optional<AdminAccountDetailDTO> findAccountDetailById(@Param("userId") UUID userId);

    @org.springframework.data.jpa.repository.Modifying
    @Query(value = "DELETE FROM users WHERE user_id IN (SELECT user_id FROM users WHERE deleted_at IS NOT NULL LIMIT :batchSize)", nativeQuery = true)
    int hardDeleteDeletedUsersBatch(@Param("batchSize") int batchSize);
}