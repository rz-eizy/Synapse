package synapse.api.dto;

import synapse.api.model.User;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UserDTO {
    private Long id;
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
