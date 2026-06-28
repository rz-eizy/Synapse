package synapse.api.service.admin;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import synapse.api.dto.admin.AdminDashboardStatsDTO;
import synapse.api.model.enums.ModerationStatus;
import synapse.api.model.enums.RequestStatus;
import synapse.api.repository.CommentRepository;
import synapse.api.repository.ProfessionalRequestRepository;
import synapse.api.repository.PublicationRepository;
import synapse.api.repository.ReportRepository;

@Service
public class AdminDashboardService {
    private static final Clock clock = Clock.system(ZoneId.of("America/Santiago"));

    private final PublicationRepository publicationRepository;
    private final CommentRepository commentRepository;
    private final ProfessionalRequestRepository professionalRequestRepository;
    private final ReportRepository reportRepository;

    public AdminDashboardService(
        PublicationRepository publicationRepository,
        CommentRepository commentRepository,
        ProfessionalRequestRepository professionalRequestRepository,
        ReportRepository reportRepository
    ) {
        this.publicationRepository = publicationRepository;
        this.commentRepository = commentRepository;
        this.professionalRequestRepository = professionalRequestRepository;
        this.reportRepository = reportRepository;
    }

    @Transactional(readOnly = true)
    public AdminDashboardStatsDTO getStats() {
        long pendingPosts = publicationRepository.countByModerationStatus(ModerationStatus.PENDING);
        long pendingComments = commentRepository.countByModerationStatus(ModerationStatus.PENDING);
        long pendingAccounts = professionalRequestRepository.countByStatus(RequestStatus.PENDING);

        LocalDateTime startOfDay = LocalDate.now(clock).atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1);
        long resolvedToday = reportRepository.countByResolvedTrueAndResolvedAtBetween(startOfDay, endOfDay);

        long totalReports = reportRepository.count();

        long approvedTotal = publicationRepository.countByModerationStatus(ModerationStatus.APPROVED)
            + commentRepository.countByModerationStatus(ModerationStatus.APPROVED);
        long rejectedTotal = publicationRepository.countByModerationStatus(ModerationStatus.REJECTED)
            + commentRepository.countByModerationStatus(ModerationStatus.REJECTED);
        long moderatedTotal = approvedTotal + rejectedTotal;
        double approvalRate = moderatedTotal == 0 ? 0.0 : (approvedTotal * 100.0) / moderatedTotal;

        return new AdminDashboardStatsDTO(pendingPosts, pendingComments, pendingAccounts, resolvedToday, totalReports, approvalRate);
    }
}