package synapse.api.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EditProfileProfessionalRequestDTO {
    private String username;
    private String profilePicture;
    private String currentLocation;
    private String description;
    // Datos de professional
    private String professionName;
    private String currentWork;
    private String personalContact;
    private String businessHours;
    private Integer costWork;
}
