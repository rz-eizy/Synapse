package synapse.api.service.admin;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import synapse.api.dto.admin.ModerateContentRequestDTO;
import synapse.api.dto.admin.ReportDetailDTO;
import synapse.api.exeption.CommentNotFound;
import synapse.api.exeption.PublicationNotFound;
import synapse.api.model.Comment;
import synapse.api.model.Publication;
import synapse.api.model.enums.ModerationStatus;
import synapse.api.model.enums.ReportType;
import synapse.api.repository.CommentRepository;
import synapse.api.repository.PublicationRepository;
import synapse.api.repository.ReportRepository;

@Service
public class AdminContentModerationService {
    private static final Clock clock = Clock.system(ZoneId.of("America/Santiago"));

    private final PublicationRepository publicationRepository;
    private final CommentRepository commentRepository;
    private final ReportRepository reportRepository;

    public AdminContentModerationService(
        PublicationRepository publicationRepository,
        CommentRepository commentRepository,
        ReportRepository reportRepository
    ) {
        this.publicationRepository = publicationRepository;
        this.commentRepository = commentRepository;
        this.reportRepository = reportRepository;
    }

    public Page<Publication> listPosts(ModerationStatus status, ReportType type, Pageable pageable) {
        return publicationRepository.findForModeration(status, type, pageable);
    }

    public Publication getPostDetail(UUID postId) {
        return publicationRepository.findByIdWithAuthor(postId).orElseThrow(PublicationNotFound::new);
    }

    @Transactional
    public Publication moderatePost(UUID postId, ModerateContentRequestDTO dto) {
        validateDecision(dto.getStatus());
        Publication post = publicationRepository.findByIdWithAuthor(postId).orElseThrow(PublicationNotFound::new);
        post.setModerationStatus(dto.getStatus());
        reportRepository.resolveByPublicationId(postId, LocalDateTime.now(clock));
        return post;
    }

    public List<ReportDetailDTO> getPostReports(UUID postId) {
        return reportRepository.findReportDetailsByPublicationId(postId);
    }

    public Page<Comment> listComments(ModerationStatus status, ReportType type, Pageable pageable) {
        return commentRepository.findForModeration(status, type, pageable);
    }

    @Transactional
    public Comment moderateComment(UUID commentId, ModerateContentRequestDTO dto) {
        validateDecision(dto.getStatus());
        Comment comment = commentRepository.findById(commentId).orElseThrow(CommentNotFound::new);
        comment.setModerationStatus(dto.getStatus());
        reportRepository.resolveByCommentId(commentId, LocalDateTime.now(clock));
        return comment;
    }

    public List<ReportDetailDTO> getCommentReports(UUID commentId) {
        return reportRepository.findReportDetailsByCommentId(commentId);
    }

    private void validateDecision(ModerationStatus status) {
        if (status != ModerationStatus.APPROVED && status != ModerationStatus.REJECTED) {
            throw new IllegalArgumentException("La acción de moderación debe ser APPROVED o REJECTED");
        }
    }
}