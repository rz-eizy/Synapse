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
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import synapse.api.model.enums.ModerationStatus;

@Entity
@Getter
@Setter
@Table(name = "posts")
@AllArgsConstructor
@NoArgsConstructor
public class Publication {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "post_id")
    private UUID id;

    @Column(nullable = false, length = 1000)
    private String content; 

    @Column(name = "image_url", length = 500)
    private String imageUrl; 
    
    @Column(name = "region_tag",nullable = false)
    private String regionTag;

    @Column(name = "created_at",nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "likes")
    private int likes;

    @org.hibernate.annotations.Formula("(SELECT COUNT(c.comment_id) FROM comments c JOIN users u ON c.author_id = u.user_id WHERE c.post_id = post_id AND u.deleted_at IS NULL)")
    private Integer commentsCount;

    @Enumerated(EnumType.STRING)
    @Column(name = "moderation_status", nullable = false, length = 20)
    private ModerationStatus moderationStatus = ModerationStatus.APPROVED;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;

    @OneToMany(mappedBy = "publication", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<Comment> comments = new ArrayList<>();

    public void incrementLikes(){
        this.likes++;
    }
    public void decrementLikes(){
        if (likes > 0) {
            this.likes--;
        }
    }
}
