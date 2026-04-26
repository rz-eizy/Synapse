package synapse.api.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import synapse.api.dto.RegisterRequestDTO;
import synapse.api.dto.UserDTO;
import synapse.api.exeption.EmailAlreadyExistsException;
import synapse.api.exeption.UsernameAlreadyExistsException;
import synapse.api.model.User;
import synapse.api.repository.UserRepository;

@Service
@Transactional(readOnly = true)
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder){
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
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

    private void validateUserDoNotExists(String username, String email){
        if (Boolean.TRUE.equals(userRepository.existsByEmail(email))) {
            throw new EmailAlreadyExistsException();
        }
        if (Boolean.TRUE.equals(userRepository.existsByUsername(username))) {
            throw new UsernameAlreadyExistsException();
        }
    }
}
