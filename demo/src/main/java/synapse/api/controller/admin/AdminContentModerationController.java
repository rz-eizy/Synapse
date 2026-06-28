package synapse.api.controller.admin;

import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import synapse.api.dto.admin.ModerateContentRequestDTO;
import synapse.api.dto.admin.ReportDetailDTO;
import synapse.api.model.Comment;
import synapse.api.model.Publication;
import synapse.api.model.enums.ModerationStatus;
import synapse.api.model.enums.ReportType;
import synapse.api.service.admin.AdminContentModerationService;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminContentModerationController {
    private static final List<String> ALLOWED_SORT_FIELDS = List.of("createdAt", "likes");

    private final AdminContentModerationService service;

    public AdminContentModerationController(AdminContentModerationService service) {
        this.service = service;
    }

    @GetMapping("/posts")
    public ResponseEntity<Page<Publication>> listPosts(
        @RequestParam(value = "type", required = false) ReportType type,
        @RequestParam(value = "status", required = false) ModerationStatus status,
        @RequestParam(value = "sort", defaultValue = "createdAt,desc") String sort,
        @RequestParam(value = "page", defaultValue = "0") int page,
        @RequestParam(value = "limit", defaultValue = "20") int limit
    ) {
        Pageable pageable = PageRequest.of(page, limit, parseSort(sort));
        return ResponseEntity.ok(service.listPosts(status, type, pageable));
    }

    @GetMapping("/posts/{id}")
    public ResponseEntity<Publication> getPostDetail(@PathVariable UUID id) {
        return ResponseEntity.ok(service.getPostDetail(id));
    }

    @PatchMapping("/posts/{id}/moderate")
    public ResponseEntity<Publication> moderatePost(
        @PathVariable UUID id,
        @RequestBody @Valid ModerateContentRequestDTO dto
    ) {
        return ResponseEntity.ok(service.moderatePost(id, dto));
    }

    @GetMapping("/posts/{id}/reports")
    public ResponseEntity<List<ReportDetailDTO>> getPostReports(@PathVariable UUID id) {
        return ResponseEntity.ok(service.getPostReports(id));
    }

    @GetMapping("/comments")
    public ResponseEntity<Page<Comment>> listComments(
        @RequestParam(value = "type", required = false) ReportType type,
        @RequestParam(value = "status", required = false) ModerationStatus status,
        @RequestParam(value = "sort", defaultValue = "createdAt,desc") String sort,
        @RequestParam(value = "page", defaultValue = "0") int page,
        @RequestParam(value = "limit", defaultValue = "20") int limit
    ) {
        Pageable pageable = PageRequest.of(page, limit, parseSort(sort));
        return ResponseEntity.ok(service.listComments(status, type, pageable));
    }

    @PatchMapping("/comments/{id}/moderate")
    public ResponseEntity<Comment> moderateComment(
        @PathVariable UUID id,
        @RequestBody @Valid ModerateContentRequestDTO dto
    ) {
        return ResponseEntity.ok(service.moderateComment(id, dto));
    }

    @GetMapping("/comments/{id}/reports")
    public ResponseEntity<List<ReportDetailDTO>> getCommentReports(@PathVariable UUID id) {
        return ResponseEntity.ok(service.getCommentReports(id));
    }

    private Sort parseSort(String sort) {
        String[] parts = sort.split(",");
        String field = parts[0].trim();
        if (!ALLOWED_SORT_FIELDS.contains(field)) {
            field = "createdAt";
        }
        Sort.Direction direction = (parts.length > 1 && "asc".equalsIgnoreCase(parts[1].trim()))
            ? Sort.Direction.ASC
            : Sort.Direction.DESC;
        return Sort.by(direction, field);
    }
}