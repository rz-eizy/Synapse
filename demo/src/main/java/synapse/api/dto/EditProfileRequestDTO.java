package synapse.api.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EditProfileRequestDTO {
    private String username;
    private String profilePicture;
    private String currentLocation;
}