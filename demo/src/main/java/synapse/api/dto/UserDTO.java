package synapse.api.dto;

import java.util.UUID;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import synapse.api.model.User;

@Getter
@Setter
@NoArgsConstructor
public class UserDTO {
    private UUID id;
    @NotBlank
    private String name;
    @Email
    private String email;

    public static UserDTO fromEntityMinimal(User u){
        UserDTO dto = new UserDTO();
        dto.id = u.getId();
        dto.name = u.getUsername();
        dto.email = u.getEmail();
        return dto;
    }
}
