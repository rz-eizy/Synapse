package synapse.api.model;

import java.time.LocalDateTime;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

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

    @Column(name = "role", nullable = false, columnDefinition = "user_role default 'regular'")
    private String role = "regular";

    private String profilePictureUrl;
    
    private String region;

    private Boolean isBlocked = false;

    private LocalDateTime createdAt = LocalDateTime.now();
}
