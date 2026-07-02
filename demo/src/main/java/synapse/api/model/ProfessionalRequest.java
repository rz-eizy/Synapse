package synapse.api.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import synapse.api.model.enums.RequestStatus;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@Table(name = "professional_requests")
public class ProfessionalRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "profession_name")
    private String professionName;

    @Column(name = "current_work")
    private String currentWork;

    @Column(name = "verification_picture", nullable = false)
    private String verificationPictureUrl;

    @Column(name = "cost_work")
    private Integer costWork;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private RequestStatus status = RequestStatus.PENDING;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "admin_notes")
    private String adminNotes; 
}