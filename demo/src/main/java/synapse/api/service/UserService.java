package synapse.api.service;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.UUID;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import synapse.api.dto.RegisterRequestDTO;
import synapse.api.dto.UserDTO;
import synapse.api.dto.UserProfileDTO;
import synapse.api.exeption.CannotAddYourselfToFavorites;
import synapse.api.exeption.EmailAlreadyExistsException;
import synapse.api.exeption.UserNotFound;
import synapse.api.exeption.UsernameAlreadyExistsException;
import synapse.api.model.User;
import synapse.api.model.enums.ModerationStatus;
import synapse.api.repository.ProfessionalRequestRepository;
import synapse.api.repository.PublicationRepository;
import synapse.api.repository.UserRepository;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final PublicationRepository publicationRepository;
    private final ProfessionalRequestRepository professionalRequestRepository;
    private final MailService mailService;
    private static final Clock clock = Clock.system(ZoneId.of("America/Santiago"));

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder, PublicationRepository publicationRepository, ProfessionalRequestRepository professionalRequestRepository, MailService mailService){
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.publicationRepository = publicationRepository;
        this.professionalRequestRepository = professionalRequestRepository;
        this.mailService = mailService;
    }

    @Transactional
    public UserDTO registerUser(RegisterRequestDTO req){
        validateUserDoNotExists(req.getName(), req.getEmail());
        
        User u = new User();
        u.setUsername(req.getName());
        u.setEmail(req.getEmail());
        u.setPassword(passwordEncoder.encode(req.getPassword()));
        u.setRegion("Araucanía");
        u.setCreatedAt(LocalDateTime.now(clock));
        User savedUser = userRepository.save(u);
        return UserDTO.fromEntityMinimal(savedUser);
    }

    @Transactional(readOnly = true)
    public UserProfileDTO getUserInfo(UUID idUser){
        UserProfileDTO uProfile = new UserProfileDTO();
        User u = userRepository.findById(idUser).orElse(null);
        if (u == null) return null;
         
        uProfile.setUsername(u.getUsername());
        uProfile.setProfilePictureUrl(u.getProfilePictureUrl());
        uProfile.setRole(u.getRole());
        var pageable = PageRequest.of(0, 50, Sort.by("createdAt").descending());
        var userPostsPage = publicationRepository.findPublicationByFilters(u.getRegion(), idUser, null, ModerationStatus.APPROVED, pageable);
    
        uProfile.setPublications(userPostsPage.getContent()); 

        java.util.List<String> favIds = new java.util.ArrayList<>();
        for (User fav : u.getFavorites()) {
            favIds.add(fav.getId().toString());
        }
        uProfile.setFavoriteProfessionalIds(favIds);

        synapse.api.model.ProfessionalRequest rejectedReq = professionalRequestRepository.findFirstByUserIdAndStatusOrderByCreatedAtDesc(idUser, synapse.api.model.enums.RequestStatus.REJECTED);
        if (rejectedReq != null) {
            uProfile.setRejectedRequestId(rejectedReq.getId().toString());
            uProfile.setRejectedRequestMotive(rejectedReq.getAdminNotes());
        }

        return uProfile;
    }

    @Transactional
    public User editProfile(UUID id, String username, String profilePicture, String currentLocation, String description){
        User u = userRepository.findById(id)
            .orElseThrow(UserNotFound::new);        
        if (username != null && !username.isBlank()) u.setUsername(username);
        if (profilePicture != null && !profilePicture.isBlank()) u.setProfilePictureUrl(profilePicture);
        if (currentLocation != null && !currentLocation.isBlank()) u.setRegion(currentLocation);
        if (description != null && !description.isBlank()) u.setDescription(description);
        return u; 
    }

    @Transactional
    public void toggleFavorite(UUID userId, UUID targetUserId){
        if (userId.equals(targetUserId)) throw new CannotAddYourselfToFavorites();
        User currentUser = userRepository.findById(userId)
                .orElseThrow(UserNotFound::new);
        User targetUser = userRepository.findById(targetUserId)
                .orElseThrow(UserNotFound::new);
        // Si ya es favorito al hacer clic nuevamente este se elimina de la lista
        boolean removed = currentUser.getFavorites().removeIf(u -> u.getId().equals(targetUserId));
        if (!removed) {
            currentUser.getFavorites().add(targetUser);
        }
    }

    private void validateUserDoNotExists(String username, String email){
        if (Boolean.TRUE.equals(userRepository.existsByEmail(email))) {
            throw new EmailAlreadyExistsException();
        }
        if (Boolean.TRUE.equals(userRepository.existsByUsername(username))) {
            throw new UsernameAlreadyExistsException();
        }
    }
    public java.util.Optional<User> findById(UUID id) {
        return userRepository.findById(id);
    }

    @Transactional
    public void softDeleteUser(UUID userId) {
        User u = userRepository.findById(userId)
                .orElseThrow(UserNotFound::new);
        u.setDeletedAt(LocalDateTime.now(clock));
        userRepository.save(u);
    }

    @Transactional
    public void requestPasswordReset(String email) {
        User u = userRepository.findByEmail(email).orElse(null);
        if (u == null) return; // Silent return to prevent email enumeration
        
        String otp = String.format("%06d", new java.util.Random().nextInt(999999));
        u.setResetOtpCode(otp);
        u.setResetOtpExpiration(LocalDateTime.now(clock).plusMinutes(15));
        
        mailService.sendPasswordResetOtp(u.getEmail(), otp);
    }

    @Transactional
    public boolean confirmPasswordReset(String email, String otp, String newPassword) {
        User u = userRepository.findByEmail(email).orElse(null);
        if (u == null) return false;
        
        if (u.getResetOtpCode() == null || !u.getResetOtpCode().equals(otp)) {
            return false;
        }
        
        if (u.getResetOtpExpiration() == null || u.getResetOtpExpiration().isBefore(LocalDateTime.now(clock))) {
            return false; // OTP expired
        }
        
        u.setPassword(passwordEncoder.encode(newPassword));
        u.setResetOtpCode(null);
        u.setResetOtpExpiration(null);
        
        return true;
    }
}
