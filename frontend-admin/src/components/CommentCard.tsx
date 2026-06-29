import type { Comment, ModerationStatus } from '../types'
import { Badge } from './Badge'
import { ActionButton } from './ActionButton'
import styles from '../styles/components/CommentCard.module.css'

interface CommentCardProps { 
  comment: Comment; 
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

export function CommentCard({ comment, animDelay = 0, onModerate }: CommentCardProps) {
  const isFlagged = comment.reportsCount >= 5
  const status = comment.status

  const handleModerate = (newStatus: ModerationStatus) => {
    if (onModerate) {
      onModerate(comment.id, newStatus);
    }
  }

  return (
    <div className={`${styles.card} ${isFlagged ? styles.flagged : ''}`} style={{ animationDelay: `${animDelay}ms` }}>
      <div className={styles.cardHeader}>
        <div className={styles.authorInfo}>
          <div className={styles.avatar}>{getInitials(comment.author?.displayName || 'User')}</div>
          <div className={styles.authorMeta}>
            <span className={styles.displayName}>{comment.author?.displayName || 'Unknown'}</span>
            <span className={styles.username}>@{comment.author?.username || 'unknown'}</span>
            {comment.author?.type === 'professional' && <Badge variant="professional" showDot={false} />}
          </div>
        </div>
        <Badge variant={status} />
      </div>

      <div className={styles.contextArea}>
        <span className={styles.contextLabel}>En respuesta a:</span>
        <span className={styles.contextPreview}>"{comment.postPreview}"</span>
      </div>

      <div className={styles.cardBody}>
        <p className={styles.content}>{comment.content}</p>
      </div>

      <div className={styles.metaRow}>
        <div className={styles.metaStat}><span className={styles.metaStatIcon}>❤️</span><span className={styles.metaStatValue}>{comment.likesCount || 0}</span></div>
        {comment.reportsCount > 0 && (
          <div className={`${styles.metaStat} ${styles.reportStat}`}>
            <span className={styles.metaStatIcon}>🚩</span>
            <span className={styles.metaStatValue}>{comment.reportsCount} reportes</span>
          </div>
        )}
        <span className={styles.metaDate}>{formatDate(comment.createdAt)}</span>
      </div>

      <div className={styles.cardFooter}>
        {status === 'pending' ? (
          <>
            <ActionButton variant="view" icon="👁" size="sm">Ver Post</ActionButton>
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