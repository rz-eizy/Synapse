package synapse.api.service;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.UUID;

import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import synapse.api.model.User;
import synapse.api.model.enums.RequestStatus;
import synapse.api.model.Professional;
import synapse.api.model.ProfessionalRequest;
import synapse.api.dto.ProfessionalRequestDTO;
import synapse.api.exeption.UserNotFound;
import synapse.api.repository.ProfessionalRepository;
import synapse.api.repository.ProfessionalRequestRepository;
import synapse.api.repository.UserRepository;

@Service
public class ProfessionalRequestService {
    private final UserRepository userRepository;
    private final ProfessionalRepository professionalRepository;
    private final ProfessionalRequestRepository requestRepository;
    private final Clock clock = Clock.system(ZoneId.of("America/Santiago"));

    public ProfessionalRequestService(
        ProfessionalRequestRepository requestRepository,
        ProfessionalRepository professionalRepository, 
        UserRepository userRepository
        
    ){
        this.professionalRepository = professionalRepository;
        this.requestRepository = requestRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public ProfessionalRequest createRequest(UUID userId, ProfessionalRequestDTO dto, String imageUrl) {
        User u = userRepository.findById(userId)
                .orElseThrow(UserNotFound::new);
        if (requestRepository.existsByUserIdAndStatus(userId, RequestStatus.PENDING)) {
            throw new IllegalStateException("Ya tienes una solicitud bajo revisión activa.");
        }

        long totalRequests = requestRepository.countByUserId(userId);
        if (totalRequests >= 3) {
            throw new IllegalStateException("Has alcanzado el límite máximo de 3 solicitudes de promoción.");
        }

        ProfessionalRequest request = new ProfessionalRequest();
        request.setUser(u);
        request.setCostWork(dto.getCostWork());
        request.setVerificationPictureUrl(imageUrl);
        request.setCurrentWork(dto.getCurrentWork());
        request.setCreatedAt(LocalDateTime.now(clock)); 
        request.setProfessionName(dto.getProfessionName());
        return requestRepository.save(request);
    }

    public Page<ProfessionalRequest> listProfessionalRequest(int page, int size){
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return requestRepository.findAllByStatus(RequestStatus.PENDING, pageable);
    }

    @Transactional
    public ProfessionalRequest rejectRequest(UUID idRequest, String adminNotes){
        ProfessionalRequest request = requestRepository.findById(idRequest)
                    .orElseThrow(() -> new RuntimeException("Solicitud no encontrada"));
        
        if (request.getStatus() != RequestStatus.PENDING) {
            throw new IllegalStateException("Esta solicitud ya fue procesada previamente.");
        }
        request.setStatus(RequestStatus.REJECTED);
        request.setAdminNotes(adminNotes);
        return request;
    }

    @Transactional
    public Professional approveRequestAndPromoteUser(UUID idRequest, String adminNotes) {
        ProfessionalRequest request = requestRepository.findById(idRequest)
                    .orElseThrow(() -> new RuntimeException("Solicitud no encontrada"));
        
        if (request.getStatus() != RequestStatus.PENDING) {
            throw new IllegalStateException("Esta solicitud ya fue procesada previamente.");
        }

        request.setStatus(RequestStatus.APPROVED);
        request.setAdminNotes(adminNotes);
        
        User user = request.getUser();            
        user.setRole("professional"); 
        
        Professional prof = new Professional();
        prof.setProfessionName(request.getProfessionName());
        prof.setCurrentWork(request.getCurrentWork()); 
        prof.setCostWork(request.getCostWork());
        prof.setUser(user); 
        
        user.setProfessional(prof);
        return professionalRepository.save(prof); 
    }
}