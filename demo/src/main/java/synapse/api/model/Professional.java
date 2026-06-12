package synapse.api.model;

import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;

@Entity
@Getter
@Setter
@Table(name = "professional")
@NoArgsConstructor
@AllArgsConstructor
public class Professional {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "profession_name", nullable = false)
    private String professionName;

    @Column(name = "current_work", nullable = false)
    private String currentWork;
    
    @Column(name = "stars", nullable = false)
    private double stars = 0.0;

    @Column(name = "personal_contact")
    private String personalContact;

    @Column(name = "business_hours")
    private String businessHours;

    @Column(name = "cost_work")
    private int costWork;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "user_id",
        referencedColumnName = "user_id",
        nullable = false
    )
    @JsonIgnore
    private User user;
}
