package synapse.api.model;

import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.persistence.MapsId;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;

@Entity
@Getter
@Setter
@Table(name = "professional_profiles")
@NoArgsConstructor
@AllArgsConstructor
public class Professional {
    @Id
    private UUID id;

    @Column(name = "official_title", nullable = false)
    private String professionName;

    @Column(name = "university_of_degree", nullable = false)
    private String currentWork;

    @Column(name = "external_contact_link")
    private String personalContact;

    @Column(name = "business_hours")
    private String businessHours;

    @Column(name = "session_price")
    private int costWork;

    @OneToMany(mappedBy = "professional", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<ProfessionalRating> ratings = new ArrayList<>();

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(
        name = "user_id",
        referencedColumnName = "user_id",
        nullable = false
    )
    @JsonIgnore
    private User user;
}
