package synapse.api.dto.admin;

import java.time.LocalDateTime;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import synapse.api.model.enums.AccountStatus;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class AdminAccountDetailDTO {
    private UUID id;
    private String username;
    private String email;
    private String role;
    private AccountStatus accountStatus;
    private LocalDateTime suspendedUntil;
    private String statusReason;
    private LocalDateTime createdAt;
    private Long reportCount;
}