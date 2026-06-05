package synapse.api.service;

import java.util.UUID;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import synapse.api.dto.RegisterRequestDTO;
import synapse.api.dto.UserDTO;
import synapse.api.dto.UserProfileDTO;
import synapse.api.exeption.EmailAlreadyExistsException;
import synapse.api.exeption.UsernameAlreadyExistsException;
import synapse.api.model.User;
import synapse.api.repository.PublicationRepository;
import synapse.api.repository.UserRepository;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final PublicationRepository publicationRepository;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder,PublicationRepository publicationRepository){
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.publicationRepository = publicationRepository;
    }

    @Transactional
    public UserDTO registerUser(RegisterRequestDTO req){
        validateUserDoNotExists(req.getName(), req.getEmail());
        
        User u = new User();
        u.setUsername(req.getName());
        u.setEmail(req.getEmail());
        u.setPassword(passwordEncoder.encode(req.getPassword()));
        
        User savedUser = userRepository.save(u);
        return UserDTO.fromEntityMinimal(savedUser);
    }

    public UserProfileDTO getUserInfo(UUID idUser){
        UserProfileDTO uProfile = new UserProfileDTO();
        User u = userRepository.findById(idUser).orElse(null);
        if (u == null) return null;
         
        uProfile.setUsername(u.getUsername());
        uProfile.setProfilePictureUrl(u.getProfilePictureUrl());
        var pageable = PageRequest.of(0, 50, Sort.by("createdAt").descending());
        var userPostsPage = publicationRepository.findPublicationByFilters(null, idUser, pageable);
    
        uProfile.setPublications(userPostsPage.getContent()); 
        return uProfile;
    }

    @Transactional
    public User editProfile(UUID id, String username, String profilePicture, String currentLocation){
        User u = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));        
        if (username != null && !username.isBlank()) u.setUsername(username);
        if (profilePicture != null && !profilePicture.isBlank()) u.setProfilePictureUrl(profilePicture);
        if (currentLocation != null && !currentLocation.isBlank()) u.setRegion(currentLocation);
    
        return u; 
    }

    private void validateUserDoNotExists(String username, String email){
        if (Boolean.TRUE.equals(userRepository.existsByEmail(email))) {
            throw new EmailAlreadyExistsException();
        }
        if (Boolean.TRUE.equals(userRepository.existsByUsername(username))) {
            throw new UsernameAlreadyExistsException();
        }
    }
}
