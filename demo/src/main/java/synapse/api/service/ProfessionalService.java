package synapse.api.service;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import synapse.api.dto.EditProfileProfessionalRequestDTO;
import synapse.api.dto.ProfessionalProfileDTO;
import synapse.api.exeption.ProfessionalNotFound;
import synapse.api.exeption.UserNotFound;
import synapse.api.model.Professional;
import synapse.api.model.ProfessionalRating;
import synapse.api.model.User;
import synapse.api.repository.ProfessionalRatingRepository;
import synapse.api.repository.ProfessionalRepository;
import synapse.api.repository.UserRepository;

@Service
public class ProfessionalService {
    private final UserRepository userRepository;
    private final ProfessionalRepository repository;
    private final ProfessionalRatingRepository ratingRepository;
    private static final Clock clock = Clock.system(ZoneId.of("America/Santiago"));

    public ProfessionalService(
        UserRepository userRepository, 
        ProfessionalRepository repository,
        ProfessionalRatingRepository ratingRepository
    ){
        this.ratingRepository = ratingRepository;
        this.userRepository = userRepository;
        this.repository = repository;
    }

    public ProfessionalProfileDTO findProfessionalById(UUID userId) {
        return repository.findProfileById(userId)
                .orElseThrow(ProfessionalNotFound::new);
    }

    public ProfessionalProfileDTO findProfessionalProfile(UUID professionalId){
        return repository.findProfileById(professionalId)
                .orElseThrow(ProfessionalNotFound::new);
    }

    public Page<ProfessionalProfileDTO> filterProfesional(
        String professionName, 
        String currentWork, 
        Double stars, 
        int page, int size
    ) {
        Pageable pageable = PageRequest.of(page, size);
        return repository.findProfessionalByFilters(professionName, currentWork, stars, pageable);
    }

    @Transactional
    public void addProfessionalRating(UUID reviewerId, UUID professionalId, double stars) {
        Optional<ProfessionalRating> ratingExist = ratingRepository.findByReviewerIdAndProfessionalId(reviewerId, professionalId);
        if (ratingExist.isPresent()) {
            ProfessionalRating rating = ratingExist.get();
            rating.setStars(stars);
        }else {
            Professional professional = repository.findById(professionalId)
                    .orElseThrow(ProfessionalNotFound::new);
            User reviewer = userRepository.findById(reviewerId)
                        .orElseThrow(UserNotFound::new);
            
            ProfessionalRating newRating = new ProfessionalRating();
            newRating.setProfessional(professional);
            newRating.setReviewer(reviewer);
            newRating.setStars(stars);
            newRating.setCreatedAt(LocalDateTime.now(clock));
            ratingRepository.save(newRating);
        }
    }

    public Page<ProfessionalProfileDTO> getFavoriteProfessionals(UUID userId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return repository.findFavoriteProfessionalsByUserId(userId, pageable);
    }

    @Transactional
    public Professional editProfessionalProfile(UUID id, EditProfileProfessionalRequestDTO dto) {
        editUserData(id, dto);
        
        Professional p = repository.findByUserId(id)
            .orElseThrow(ProfessionalNotFound::new);
        
        if (dto.getProfessionName() != null && !dto.getProfessionName().isBlank()) p.setProfessionName(dto.getProfessionName());
        if (dto.getCurrentWork() != null && !dto.getCurrentWork().isBlank()) p.setCurrentWork(dto.getCurrentWork());
        if (dto.getPersonalContact() != null && !dto.getPersonalContact().isBlank()) p.setPersonalContact(dto.getPersonalContact());
        if (dto.getBusinessHours() != null && !dto.getBusinessHours().isBlank()) p.setBusinessHours(dto.getBusinessHours());
        if (dto.getCostWork() != null) p.setCostWork(dto.getCostWork());
        return p; 
    }

    private void editUserData(UUID id, EditProfileProfessionalRequestDTO dto) {
        User u = userRepository.findById(id)
            .orElseThrow(UserNotFound::new);        
        
        if (dto.getUsername() != null && !dto.getUsername().isBlank()) u.setUsername(dto.getUsername());
        if (dto.getProfilePicture() != null && !dto.getProfilePicture().isBlank()) u.setProfilePictureUrl(dto.getProfilePicture());
        if (dto.getCurrentLocation() != null && !dto.getCurrentLocation().isBlank()) u.setRegion(dto.getCurrentLocation());
        if (dto.getDescription() != null && !dto.getDescription().isBlank()) u.setDescription(dto.getDescription());
    }
}
