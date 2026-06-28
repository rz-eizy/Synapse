package synapse.api.service;

import java.util.UUID;
import java.time.Clock;
import java.time.ZoneId;
import java.time.LocalDateTime;

import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import synapse.api.dto.ReportRequestDTO;
import synapse.api.exeption.CommentNotFound;
import synapse.api.exeption.PublicationNotFound;
import synapse.api.exeption.UserNotFound;
import synapse.api.model.Comment;
import synapse.api.model.Publication;
import synapse.api.model.Report;
import synapse.api.model.User;
import synapse.api.model.enums.ReportType;
import synapse.api.repository.CommentRepository;
import synapse.api.repository.PublicationRepository;
import synapse.api.repository.ReportRepository;
import synapse.api.repository.UserRepository;

@Service
public class ReportService {
    private static final Clock clock = Clock.system(ZoneId.of("America/Santiago"));
    private final PublicationRepository publicationRepository;
    private final CommentRepository commentRepository;
    private final ReportRepository reportRepository;
    private final UserRepository userRepository;

    public ReportService(
        PublicationRepository publicationRepository,
        CommentRepository commentRepository,
        ReportRepository reportRepository,
        UserRepository userRepository
    ) {
        this.publicationRepository = publicationRepository;
        this.commentRepository = commentRepository;
        this.reportRepository = reportRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Report createReport(UUID reporterId, ReportRequestDTO dto) {
        if (dto.getType() == ReportType.OTHER && (dto.getDescription() == null || dto.getDescription().isBlank())) {
            throw new IllegalArgumentException("La descripción es obligatoria para el tipo 'OTHER'");
        }

        int targets = 0;
        if (dto.getIdReportedUser() != null) targets++;
        if (dto.getIdPublication() != null) targets++;
        if (dto.getIdComment() != null) targets++;

        if (targets != 1) {
            throw new IllegalArgumentException("El reporte debe estar asociado exactamente a un objetivo (usuario, publicación o comentario)");
        }

        Report report = new Report();
        report.setType(dto.getType());
        report.setDescription(dto.getDescription());
        report.setCreatedAt(LocalDateTime.now(clock));
        
        User reporter = userRepository.findById(reporterId).orElseThrow(UserNotFound::new);
        report.setReporter(reporter);
        
        if (dto.getIdPublication() != null) {
            Publication pub = publicationRepository.findById(dto.getIdPublication()).orElseThrow(PublicationNotFound::new);
            pub.setModerationStatus(synapse.api.model.enums.ModerationStatus.PENDING);
            report.setPublication(pub);
        }

        if (dto.getIdReportedUser() != null) {
            User reportedU = userRepository.findById(dto.getIdReportedUser()).orElseThrow(UserNotFound::new);
            report.setReportedUser(reportedU);
        }

        if (dto.getIdComment() != null) {
            Comment com = commentRepository.findById(dto.getIdComment()).orElseThrow(CommentNotFound::new);
            com.setModerationStatus(synapse.api.model.enums.ModerationStatus.PENDING);
            report.setComment(com);
        }
        reportRepository.save(report);
        return report;
    }
}
