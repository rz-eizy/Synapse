package synapse.api.dto;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class ProfessionalProfileDTO {
    private UUID professionalId;
    private String professionName;
    private String institutions;
    private int costWork;
    private String username;          
    private String profilePictureUrl;  
    
    private Double averageStars;      
    private Long totalReviews;
}
