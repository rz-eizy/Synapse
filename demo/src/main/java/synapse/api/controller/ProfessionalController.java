package synapse.api.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import synapse.api.dto.ProfessionalRequestDTO;
import synapse.api.model.Professional;
import synapse.api.service.ProfessionalService;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;


@RestController
@RequestMapping("/api/professional")
public class ProfessionalController {
    private final ProfessionalService service;

    public ProfessionalController(ProfessionalService professionalService){
        this.service = professionalService;
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
    public ResponseEntity<Professional> getMethodName(
        @PathVariable UUID idProfessional
    ) {
        Professional pro = service.findProfessionalById(idProfessional);
        return ResponseEntity.ok(pro);
    }
    
    @GetMapping()
    public ResponseEntity<Page<Professional>> getMethodName(
        @RequestParam(value = "profession_name", required = false) String professionName,
        @RequestParam(value = "current_work", required = false) String currentWork,
        @RequestParam(value = "stars", required = false) Double stars,
        @RequestParam(value = "page", defaultValue = "0") int page,
        @RequestParam(value = "size", defaultValue = "20") int size 
    ) {
        Page<Professional> list = service.filterProfesional(professionName, currentWork, stars, page, size);
        return ResponseEntity.ok(list);
    }
    
}
