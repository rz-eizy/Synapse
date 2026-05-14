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
public class LoginRequestDTO {
    @Email
    private String email;
    @NotBlank
    private String password;

    public static LoginRequestDTO toLoginRequest(User dto){
        LoginRequestDTO loginReq = new LoginRequestDTO();
        loginReq.setEmail(dto.getEmail());
        loginReq.setPassword(dto.getPassword());
        return loginReq;
    }
}
