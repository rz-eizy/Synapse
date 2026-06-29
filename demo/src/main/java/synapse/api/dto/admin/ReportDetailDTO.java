package synapse.api.dto.admin;

import java.time.LocalDateTime;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import synapse.api.model.enums.ReportType;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class ReportDetailDTO {
    private UUID id;
    private ReportType type;
    private String description;
    private LocalDateTime createdAt;
    private String reporterUsername;
    private boolean resolved;
}