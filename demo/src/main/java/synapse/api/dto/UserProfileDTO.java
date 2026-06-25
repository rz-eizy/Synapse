package synapse.api.dto;

import java.util.ArrayList;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import synapse.api.model.Publication;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileDTO {
    private String username;
    private String profilePictureUrl;
    private List<Publication> publications = new ArrayList<>();
    private List<String> favoriteProfessionalIds = new ArrayList<>();
}
