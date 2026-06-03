package synapse.api.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "posts")
@AllArgsConstructor
@NoArgsConstructor
public class Publication {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 1000)
    private String content; 

    @Column(name = "image_url", length = 500)
    private String imageUrl; 
    
    @Column(name = "region_tag",nullable = false)
    private String regionTag;

    @Column(name = "created_at",nullable = false)
    private LocalDateTime createdAt;

    /*  
        Implementacion futura
        Cuando esto sea falso se debe enviar a un admin para monitoreo
    */
    @Column(nullable = false)
    private boolean isApproved = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;
}
