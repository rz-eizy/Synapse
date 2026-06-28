package synapse.api.dto.admin;

import java.time.LocalDateTime;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import synapse.api.model.enums.AccountStatus;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AccountStatusUpdateRequestDTO {
    @NotNull(message = "El nuevo estado de la cuenta es obligatorio")
    private AccountStatus status;
    private String reason;
    private LocalDateTime suspendedUntil;
}