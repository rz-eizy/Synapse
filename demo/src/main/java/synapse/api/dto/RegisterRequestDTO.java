package synapse.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import synapse.api.model.User;

@Getter
@Setter
@NoArgsConstructor
public class RegisterRequestDTO {
    @NotBlank
    private String name;
    @NotBlank @Email
    private String email;
    @NotBlank
    private String password;

    public static RegisterRequestDTO toRegisterRequestDTO(User dto){
        RegisterRequestDTO registerReq = new RegisterRequestDTO();
        registerReq.setName(dto.getUsername());
        registerReq.setEmail(dto.getEmail());
        registerReq.setPassword(dto.getPassword());
        return registerReq;
    }
}