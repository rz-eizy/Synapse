package synapse.api.service.admin;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import synapse.api.dto.admin.AccountStatusUpdateRequestDTO;
import synapse.api.dto.admin.AdminAccountDetailDTO;
import synapse.api.exeption.CannotModifyOwnAccountException;
import synapse.api.exeption.UserNotFound;
import synapse.api.model.AccountModerationLog;
import synapse.api.model.User;
import synapse.api.model.enums.AccountStatus;
import synapse.api.repository.AccountModerationLogRepository;
import synapse.api.repository.ReportRepository;
import synapse.api.repository.UserRepository;

@Service
public class AdminAccountService {
    private static final Clock clock = Clock.system(ZoneId.of("America/Santiago"));

    private final UserRepository userRepository;
    private final AccountModerationLogRepository moderationLogRepository;
    private final ReportRepository reportRepository;

    public AdminAccountService(
        UserRepository userRepository,
        AccountModerationLogRepository moderationLogRepository,
        ReportRepository reportRepository
    ) {
        this.userRepository = userRepository;
        this.moderationLogRepository = moderationLogRepository;
        this.reportRepository = reportRepository;
    }

    public Page<User> listAccounts(AccountStatus status, String type, Pageable pageable) {
        return userRepository.findForAdmin(status, type, pageable);
    }

    public AdminAccountDetailDTO getAccountDetail(UUID userId) {
        return userRepository.findAccountDetailById(userId).orElseThrow(UserNotFound::new);
    }

    @Transactional
    public User updateAccountStatus(UUID adminId, UUID targetUserId, AccountStatusUpdateRequestDTO dto) {
        if (adminId.equals(targetUserId)) {
            throw new CannotModifyOwnAccountException();
        }

        User target = userRepository.findById(targetUserId).orElseThrow(UserNotFound::new);
        LocalDateTime now = LocalDateTime.now(clock);

        AccountStatus newStatus = dto.getStatus();
        LocalDateTime newSuspendedUntil = null;

        if (newStatus == AccountStatus.SUSPENDED) {
            if (dto.getSuspendedUntil() == null || !dto.getSuspendedUntil().isAfter(now)) {
                throw new IllegalArgumentException("Para suspender una cuenta debes indicar 'suspendedUntil' con una fecha futura");
            }
            newSuspendedUntil = dto.getSuspendedUntil();
        }

        AccountStatus previousStatus = target.getAccountStatus();
        target.setAccountStatus(newStatus);
        target.setSuspendedUntil(newSuspendedUntil);
        target.setStatusReason(dto.getReason());

        User admin = userRepository.findById(adminId).orElseThrow(UserNotFound::new);

        AccountModerationLog log = new AccountModerationLog();
        log.setTargetUser(target);
        log.setAdmin(admin);
        log.setPreviousStatus(previousStatus);
        log.setNewStatus(newStatus);
        log.setReason(dto.getReason());
        log.setSuspendedUntil(newSuspendedUntil);
        log.setCreatedAt(now);
        moderationLogRepository.save(log);

        if (newStatus == AccountStatus.SUSPENDED || newStatus == AccountStatus.BANNED) {
            reportRepository.resolveByReportedUserId(targetUserId, now);
        }

        return target;
    }

    public Page<AccountModerationLog> getAccountHistory(UUID targetUserId, Pageable pageable) {
        return moderationLogRepository.findByTargetUserId(targetUserId, pageable);
    }
}