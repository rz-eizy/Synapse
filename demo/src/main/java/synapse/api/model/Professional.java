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

    @Column(name = "official_title")
    private String professionName;

    @Column(name = "institutions")
    private String institutions;

    @Column(name = "external_contact_link")
    private String personalContact;

    @Column(name = "business_hours")
    private String businessHours;

    @Column(name = "session_price")
    private Integer costWork;

    @Column(name = "years_experience")
    private Integer yearsExperience;

    @Column(name = "city")
    private String city;

    @Column(name = "work_region")
    private String workRegion;

    @Column(name = "modality")
    private String modality;

    @Column(name = "professional_description")
    private String professionalDescription;

    @Column(name = "health_coverage")
    private String healthCoverage;

    @Column(name = "treated_diagnostics")
    private String treatedDiagnostics;

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
