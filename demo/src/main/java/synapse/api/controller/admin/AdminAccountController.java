package synapse.api.controller.admin;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import synapse.api.dto.admin.AccountStatusUpdateRequestDTO;
import synapse.api.dto.admin.AdminAccountDetailDTO;
import synapse.api.model.AccountModerationLog;
import synapse.api.model.User;
import synapse.api.model.enums.AccountStatus;
import synapse.api.security.CustomUserDetails;
import synapse.api.service.admin.AdminAccountService;

@RestController
@RequestMapping("/api/admin/accounts")
@PreAuthorize("hasRole('ADMIN')")
public class AdminAccountController {
    private final AdminAccountService service;

    public AdminAccountController(AdminAccountService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<Page<User>> listAccounts(
        @RequestParam(value = "status", required = false) AccountStatus status,
        @RequestParam(value = "type", required = false) String type,
        @RequestParam(value = "page", defaultValue = "0") int page,
        @RequestParam(value = "limit", defaultValue = "20") int limit
    ) {
        Pageable pageable = PageRequest.of(page, limit);
        return ResponseEntity.ok(service.listAccounts(status, type, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<AdminAccountDetailDTO> getAccountDetail(@PathVariable UUID id) {
        return ResponseEntity.ok(service.getAccountDetail(id));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<User> updateAccountStatus(
        @AuthenticationPrincipal CustomUserDetails principal,
        @PathVariable UUID id,
        @RequestBody @Valid AccountStatusUpdateRequestDTO dto
    ) {
        User updated = service.updateAccountStatus(principal.getId(), id, dto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/{id}/history")
    public ResponseEntity<Page<AccountModerationLog>> getAccountHistory(
        @PathVariable UUID id,
        @RequestParam(value = "page", defaultValue = "0") int page,
        @RequestParam(value = "limit", defaultValue = "20") int limit
    ) {
        Pageable pageable = PageRequest.of(page, limit);
        return ResponseEntity.ok(service.getAccountHistory(id, pageable));
    }
}