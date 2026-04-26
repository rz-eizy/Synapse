package synapse.api.service;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

import synapse.api.dto.AuthResponseDTO;
import synapse.api.dto.LoginRequestDTO;
import synapse.api.security.JwtUtils;
import synapse.api.security.UserDetailsServiceImpl;

@Service
public class AuthService {
    private final AuthenticationManager authenticationManager;
    private final UserDetailsServiceImpl userDetailsService;
    private final JwtUtils jwtUtils;

    public AuthService(AuthenticationManager authenticationManager,
            UserDetailsServiceImpl userDetailsService, JwtUtils jwtUtils
        ){
            this.authenticationManager = authenticationManager;
            this.userDetailsService = userDetailsService;
            this.jwtUtils = jwtUtils; 
    }

    public AuthResponseDTO login(LoginRequestDTO requestDTO){
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(requestDTO.getEmail(), requestDTO.getPassword())
        );
        var user = userDetailsService.loadUserByUsername(requestDTO.getEmail());
        var jwtToken = jwtUtils.generateToken(user);
        
        return AuthResponseDTO.builder().token(jwtToken).build();
    }
}
