package synapse.api.dto;

import java.util.UUID;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ProfessionalProfileDTO {
    private UUID professionalId;
    private String professionName;
    private String currentWork;
    private int costWork;
    private String username;          
    private String profilePictureUrl;  
    
    private Double averageStars;      
    private Long totalReviews;
}
