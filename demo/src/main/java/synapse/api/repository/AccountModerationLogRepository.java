package synapse.api.repository;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import synapse.api.model.AccountModerationLog;

public interface AccountModerationLogRepository extends JpaRepository<AccountModerationLog, UUID> {
    @Query("SELECT l FROM AccountModerationLog l JOIN FETCH l.admin JOIN FETCH l.targetUser " +
           "WHERE l.targetUser.id = :userId ORDER BY l.createdAt DESC")
    Page<AccountModerationLog> findByTargetUserId(@Param("userId") UUID userId, Pageable pageable);
}