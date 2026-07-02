package synapse.api.controller;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;


import synapse.api.model.Professional;
import synapse.api.model.ProfessionalRequest;
import synapse.api.dto.ProfessionalRequestDTO;
import synapse.api.security.CustomUserDetails;
import synapse.api.service.ProfessionalRequestService;
import org.springframework.web.bind.annotation.GetMapping;


@RestController
@RequestMapping("/api/professional/requests")
public class ProfessionalRequestController {
    private final ProfessionalRequestService requestService;

    public ProfessionalRequestController(
        ProfessionalRequestService requestService
    ) {
        this.requestService = requestService;
    }

    @PreAuthorize("hasRole('USER')") 
    @PostMapping()
    public ResponseEntity<ProfessionalRequest> submitRequest(
            @RequestParam String imageUrl,
            @AuthenticationPrincipal CustomUserDetails principal
    ) {
        ProfessionalRequest newRequest = requestService.createRequest(principal.getId(), imageUrl);
        return new ResponseEntity<>(newRequest, HttpStatus.CREATED);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PatchMapping("/requests/{idRequest}/approve")
    public ResponseEntity<Professional> approveAndPromote(
        @PathVariable UUID idRequest,
        @RequestParam(value = "professionName") String professionName,
        @RequestParam(value = "notes", required = false) String adminNotes
    ){
        Professional professionalProfile = requestService.approveRequestAndPromoteUser(idRequest, professionName, adminNotes);
        return ResponseEntity.ok(professionalProfile);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PatchMapping("/requests/{idRequest}/reject")
    public ResponseEntity<ProfessionalRequest> rejectRequest(
        @PathVariable UUID idRequest,
        @RequestParam(value = "notes", required = false) String adminNotes
    ){
        ProfessionalRequest request = requestService.rejectRequest(idRequest, adminNotes);
        return ResponseEntity.ok(request);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping()
    public ResponseEntity<Page<ProfessionalRequest>> getMethodName(
        @RequestParam(value = "page", defaultValue = "0") int page,
        @RequestParam(value = "size", defaultValue = "20") int size 
    ) {
        Page<ProfessionalRequest> request = requestService.listProfessionalRequest(page, size);
        return ResponseEntity.ok(request);
    }
    
}