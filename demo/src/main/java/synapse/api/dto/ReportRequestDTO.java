package synapse.api.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import synapse.api.model.enums.ReportType;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReportRequestDTO {
    @NotNull(message = "El tipo de reporte es obligatorio")
    private ReportType type;
    private String description;
    private UUID idReportedUser;
    private UUID idComment;
    private UUID idPublication;
}
