package synapse.api.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import synapse.api.dto.ReportRequestDTO;
import synapse.api.model.Report;
import synapse.api.security.CustomUserDetails;
import synapse.api.service.ReportService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;


@RestController
@RequestMapping("api/report")
public class ReportController {
    private final ReportService service;

    public ReportController(ReportService service){
        this.service = service;
    }

    @PostMapping()
    public ResponseEntity<Report> postMethodName(
        @RequestBody(required = true) @Valid ReportRequestDTO dto,
        @AuthenticationPrincipal CustomUserDetails principal
    ) {
        Report report = service.createReport(principal.getId(), dto);
        return new ResponseEntity<>(report, HttpStatus.CREATED);
    }
    
}
