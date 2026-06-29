package synapse.api.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToOne;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import synapse.api.model.enums.AccountStatus;

@Entity
@Getter
@Setter
@jakarta.persistence.Table(name = "users")
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = jakarta.persistence.GenerationType.UUID) 
    @Column(name = "user_id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "full_name",length = 50)
    private String username;

    @Column(name = "email",nullable = false, unique = true, length = 100)
    private String email;

    @Column(name = "password_hash",nullable = false, length = 255)
    @JsonIgnore
    private String password;

    @Column(name = "role", nullable = false)
    private String role = "regular";

    @Column(name = "description")
    private String description;

    @Column(name = "profile_picture_url")
    private String profilePictureUrl;
    
    @Column(name = "region")
    private String region;

    @Enumerated(EnumType.STRING)
    @Column(name = "account_status", nullable = false, length = 20)
    private AccountStatus accountStatus = AccountStatus.ACTIVE;

    @Column(name = "suspended_until")
    private LocalDateTime suspendedUntil;

    @Column(name = "status_reason", length = 500)
    private String statusReason;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "favorites",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "favorite_user_id")
    )
    @JsonIgnore
    private List<User> favorites = new ArrayList<>();

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Professional professional;
}
