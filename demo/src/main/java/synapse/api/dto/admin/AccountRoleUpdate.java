package synapse.api.dto.admin;

import java.time.LocalDateTime;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AccountRoleUpdate {
    private UUID id;
    private String nombre;
    private String pastRol;
    private String newRol;
    private UUID updatedBy;
    private LocalDateTime updatedAt;
}
