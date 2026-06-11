package synapse.api.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import synapse.api.dto.EditProfileRequestDTO;
import synapse.api.dto.UserProfileDTO;
import synapse.api.model.User;
import synapse.api.security.CustomUserDetails;
import synapse.api.service.UserService;

import java.util.UUID;

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

    public UserController(UserService service){
        this.service = service;
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
            request.getCurrentLocation()
        );
        return new ResponseEntity<>(u, HttpStatus.OK);
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
    
        
}
