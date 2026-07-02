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
    private String institutions;
    private String personalContact;
    private String businessHours;
    private Integer costWork;
    private Integer yearsExperience;
    private String city;
    private String workRegion;
    private String modality;
    private String professionalDescription;
    private String healthCoverage;
    private String treatedDiagnostics;
}
