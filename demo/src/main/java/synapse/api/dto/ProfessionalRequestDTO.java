package synapse.api.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class ProfessionalRequestDTO {
    @NotBlank
    private String professionName;
    @NotBlank
    private String currentWork;
    @Min(0)
    private int costWork;
}
