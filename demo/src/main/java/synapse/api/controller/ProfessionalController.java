package synapse.api.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import synapse.api.dto.ProfessionalProfileDTO;
import synapse.api.dto.ProfessionalRequestDTO;
import synapse.api.model.Professional;
import synapse.api.security.CustomUserDetails;
import synapse.api.service.ProfessionalService;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PostMapping;



@RestController
@RequestMapping("/api/professional")
public class ProfessionalController {
    private final ProfessionalService service;

    public ProfessionalController(ProfessionalService professionalService){
        this.service = professionalService;
    }

    @PostMapping("/rate/{idProfessional}")
    public ResponseEntity<ProfessionalProfileDTO> postNewRating(
        @AuthenticationPrincipal CustomUserDetails principal,
        @PathVariable UUID idProfessional,
        @RequestParam double stars
    ) {
        if (stars < 1.0 || stars > 5.0) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST); 
        }
        service.addProfessionalRating(principal.getId(), idProfessional, stars);        
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PatchMapping("/promote/{idUser}")
    public ResponseEntity<Professional> promoteUser(
        @RequestBody ProfessionalRequestDTO dto,
        @PathVariable UUID idUser
    ){
        Professional pro = service.promoteToProfessional(idUser, dto);
        return ResponseEntity.ok(pro);
    }

    @GetMapping("/{idProfessional}")
    public ResponseEntity<ProfessionalProfileDTO> getMethodName(
        @PathVariable UUID idProfessional
    ) {
        ProfessionalProfileDTO pro = service.findProfessionalById(idProfessional);
        return ResponseEntity.ok(pro);
    }
    
    @GetMapping("/list")
    public ResponseEntity<Page<ProfessionalProfileDTO>> getMethodName(
        @RequestParam(value = "profession_name", required = false) String professionName,
        @RequestParam(value = "current_work", required = false) String currentWork,
        @RequestParam(value = "stars", required = false) Double stars,
        @RequestParam(value = "page", defaultValue = "0") int page,
        @RequestParam(value = "size", defaultValue = "20") int size 
    ) {
        Page<ProfessionalProfileDTO> list = service.filterProfesional(professionName, currentWork, stars, page, size);
        return ResponseEntity.ok(list);
    }
    
}
