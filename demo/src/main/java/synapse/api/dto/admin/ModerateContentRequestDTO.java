package synapse.api.dto.admin;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import synapse.api.model.enums.ModerationStatus;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ModerateContentRequestDTO {
    @NotNull(message = "El nuevo estado de moderación es obligatorio")
    private ModerationStatus status;
    private String reason;
}