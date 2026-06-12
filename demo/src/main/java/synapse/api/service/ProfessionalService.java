package synapse.api.service;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import synapse.api.dto.ProfessionalRequestDTO;
import synapse.api.exeption.UserNotFound;
import synapse.api.model.Professional;
import synapse.api.model.User;
import synapse.api.repository.ProfessionalRepository;
import synapse.api.repository.UserRepository;

@Service
public class ProfessionalService {
    private final UserRepository userRepository;
    private final ProfessionalRepository repository;

    public ProfessionalService(UserRepository userRepository, ProfessionalRepository repository){
        this.userRepository = userRepository;
        this.repository = repository;
    }

    @Transactional
    public Professional promoteToProfessional(UUID userId, ProfessionalRequestDTO dto) {
        User user = userRepository.findById(userId)
            .orElseThrow(UserNotFound::new);
            
        Professional prof = new Professional();
        prof.setProfessionName(dto.getProfessionName());
        prof.setCurrentWork(dto.getCurrentWork());
        prof.setCostWork(dto.getCostWork());
        prof.setUser(user); 
        
        user.setRole("professional"); 
        user.setProfessional(prof);
        return prof; 
    }

    public Professional findProfessionalById(UUID userId) {
        return repository.findById(userId)
                .orElseThrow(UserNotFound::new);
    }

    public Page<Professional> filterProfesional(
        String professionName, 
        String currentWork, 
        Double stars, 
        int page, int size
    ){
        Pageable pageable = PageRequest.of(page, size, Sort.by("stars").descending());
        return repository.findProfessionalByFilters(professionName, currentWork, stars, pageable);
    }
}
