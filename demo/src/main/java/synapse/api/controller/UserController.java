package synapse.api.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import synapse.api.dto.EditProfileRequestDTO;
import synapse.api.dto.ProfessionalProfileDTO;
import synapse.api.dto.UserProfileDTO;
import synapse.api.model.User;
import synapse.api.security.CustomUserDetails;
import synapse.api.service.ProfessionalService;
import synapse.api.service.UserService;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PutMapping;


@RestController
@RequestMapping("/api/user")
public class UserController {
    private final UserService service;
    private final ProfessionalService professionalService;

    public UserController(UserService service, ProfessionalService professionalService){
        this.service = service;
        this.professionalService = professionalService;
    }
    @GetMapping("/me")
    public ResponseEntity<UserProfileDTO> getUserProfile(@AuthenticationPrincipal CustomUserDetails principal) {
        UUID userId = principal.getId();
        UserProfileDTO u = service.getUserInfo(userId);
        if (u == null) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        } else{
            return new ResponseEntity<>(u, HttpStatus.OK);
        }
    }
    @PatchMapping("/me")
    public ResponseEntity<User> postEditUserProfile(
        @AuthenticationPrincipal CustomUserDetails principal,
        @RequestBody EditProfileRequestDTO request
    ) {
        User u = service.editProfile(
            principal.getId(), 
            request.getUsername(), 
            request.getProfilePicture(), 
            request.getCurrentLocation(),
            request.getDescription()
        );
        return new ResponseEntity<>(u, HttpStatus.OK);
    }
    
    @PutMapping("/preferences")
    public ResponseEntity<Void> putUserPreferences(
        @AuthenticationPrincipal CustomUserDetails principal,
        @RequestBody synapse.api.dto.UserPreferencesDTO request
    ) {
        service.updateUserPreferences(principal.getId(), request.getRegion(), request.getInterestedDiagnostics());
        return new ResponseEntity<>(HttpStatus.OK);
    }
    
    @PutMapping("/favorites/{targetUserId}")
    public ResponseEntity<User> postAddFavorite(
        @AuthenticationPrincipal CustomUserDetails principal,
        @PathVariable UUID targetUserId
    ) {
        UUID userId = principal.getId();
        service.toggleFavorite(userId, targetUserId);
        return new ResponseEntity<>(HttpStatus.OK);
    }
    
    @GetMapping("/favorites/professionals")
    public ResponseEntity<Page<ProfessionalProfileDTO>> getFavoriteProfessionals(
        @AuthenticationPrincipal CustomUserDetails principal,
        @RequestParam(value = "page", defaultValue = "0") int page,
        @RequestParam(value = "size", defaultValue = "20") int size
    ) {
        Page<ProfessionalProfileDTO> favorites = professionalService.getFavoriteProfessionals(principal.getId(), page, size);
        return ResponseEntity.ok(favorites);
    }

    @org.springframework.web.bind.annotation.DeleteMapping("/me")
    public ResponseEntity<Void> deleteUser(@AuthenticationPrincipal CustomUserDetails principal) {
        service.softDeleteUser(principal.getId());
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
