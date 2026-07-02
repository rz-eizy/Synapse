package synapse.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import synapse.api.model.Publication;

@Getter
@Setter
@NoArgsConstructor
public class PublicationDTO {
    @NotBlank
    @Size(max = 250)
    private String content;
    
    @NotBlank 
    @Size(max = 100)
    private String regionTag;
    
    private String imageUrl;

    public static PublicationDTO toPublicationDTO(Publication pb){
        PublicationDTO pDto = new PublicationDTO();
        pDto.setContent(pb.getContent());
        pDto.setRegionTag(pb.getRegionTag());
        pDto.setImageUrl(pb.getImageUrl());
        return pDto;
    }
}
