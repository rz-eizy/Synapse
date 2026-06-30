import type { Post, ModerationStatus } from '../types'
import { Badge } from './Badge'
import { ActionButton } from './ActionButton'
import styles from '../styles/components/PostCard.module.css'

interface PostCardProps { 
  post: Post; 
  animDelay?: number;
  onModerate?: (id: string, newStatus: ModerationStatus) => void;
}

function formatDate(iso: string) {
  if (!iso) return '';
  return new Date(iso).toLocaleString('es-ES', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })
}
function getInitials(name: string) {
  if (!name) return 'U';
  return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()
}

export function PostCard({ post, animDelay = 0, onModerate }: PostCardProps) {
  const isFlagged = post.reportsCount >= 5
  const status = post.status

  const handleModerate = (newStatus: ModerationStatus) => {
    if (onModerate) {
      onModerate(post.id, newStatus);
    }
  }

  return (
    <div className={`${styles.card} ${isFlagged ? styles.flagged : ''}`} style={{ animationDelay: `${animDelay}ms` }}>
      <div className={styles.cardHeader}>
        <div className={styles.authorInfo}>
          <div className={styles.avatar}>{getInitials(post.author?.displayName || 'User')}</div>
          <div className={styles.authorMeta}>
            <span className={styles.displayName}>{post.author?.displayName || 'Unknown User'}</span>
            <span className={styles.username}>@{post.author?.username || 'unknown'}</span>
          </div>
        </div>
        <div className={styles.badgeGroup}>
          <Badge variant={post.type} />
          <Badge variant={status} />
        </div>
      </div>

      <div className={styles.cardBody}>
        <p className={styles.content}>{post.content}</p>
        {post.images && post.images.length > 0 && (
          <div className={`${styles.imagesGrid} ${post.images.length === 1 ? styles.single : post.images.length === 2 ? styles.two : styles.multi}`}>
            {post.images.map(img => (
              <img key={img.id} src={img.url} alt={img.alt ?? 'Imagen'} className={styles.postImage} />
            ))}
          </div>
        )}
        {post.tags && post.tags.length > 0 && (
          <div className={styles.tags}>
            {post.tags.map(t => <span key={t} className={styles.tag}>#{t}</span>)}
          </div>
        )}
      </div>

      <div className={styles.metaRow}>
        <div className={styles.metaStat}><span className={styles.metaStatIcon}>❤️</span><span className={styles.metaStatValue}>{post.likesCount || 0}</span></div>
        <div className={styles.metaStat}><span className={styles.metaStatIcon}>💬</span><span className={styles.metaStatValue}>{post.commentsCount || 0}</span></div>
        {post.reportsCount > 0 && (
          <div className={`${styles.metaStat} ${styles.reportStat}`}>
            <span className={styles.metaStatIcon}>🚩</span>
            <span className={styles.metaStatValue}>{post.reportsCount} reportes</span>
          </div>
        )}
        <span className={styles.metaDate}>{formatDate(post.createdAt)}</span>
      </div>

      {post.reports && post.reports.length > 0 && (
        <div className={styles.reportsList}>
          <div className={styles.reportsTitle}>Detalle de reportes:</div>
          {post.reports.map(r => (
            <div key={r.id} className={styles.reportItem}>
              <strong>{r.type}:</strong> {r.description || 'Sin detalles'} <em>(por @{r.reporterUsername})</em>
            </div>
          ))}
        </div>
      )}

      <div className={styles.cardFooter}>
        {status === 'pending' ? (
          <>
            <ActionButton variant="view" icon="👁" size="sm">Revisar</ActionButton>
            <ActionButton variant="approve" icon="✓" size="sm" onClick={() => handleModerate('approved')}>Aprobar</ActionButton>
            <ActionButton variant="reject" icon="✕" size="sm" onClick={() => handleModerate('rejected')}>Rechazar</ActionButton>
          </>
        ) : (
          <div className={styles.alreadyActioned}>{status === 'approved' ? 'Aprobado' : 'Rechazado'}</div>
        )}
      </div>
    </div>
  )
}