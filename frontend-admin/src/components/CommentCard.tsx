import { useState } from 'react'
import type { Comment } from '../types'
import { Badge } from './Badge'
import { ActionButton } from './ActionButton'
import styles from '../styles/components/CommentCard.module.css'

interface CommentCardProps { comment: Comment; animDelay?: number }

function formatDate(iso: string) {
  return new Date(iso).toLocaleString('es-ES', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })
}
function getInitials(name: string) {
  return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()
}

export function CommentCard({ comment, animDelay = 0 }: CommentCardProps) {
  const [status, setStatus] = useState(comment.status)
  const isFlagged = comment.reportsCount >= 4

  return (
    <div className={`${styles.card} ${isFlagged ? styles.flagged : ''}`} style={{ animationDelay: `${animDelay}ms` }}>
      <div className={styles.cardHeader}>
        <div className={styles.authorInfo}>
          <div className={styles.avatar}>{getInitials(comment.author.displayName)}</div>
          <div className={styles.authorMeta}>
            <span className={styles.displayName}>{comment.author.displayName}</span>
            <span className={styles.username}>@{comment.author.username}</span>
          </div>
        </div>
        <Badge variant={status} />
      </div>

      <div className={styles.context}>
        <div className={styles.contextLabel}>En respuesta a</div>
        <div className={styles.contextPreview}>"{comment.postPreview}"</div>
      </div>

      <p className={styles.content}>{comment.content}</p>

      <div className={styles.metaRow}>
        <div className={styles.metaStat}><span className={styles.metaStatIcon}>❤️</span><span className={styles.metaStatValue}>{comment.likesCount}</span></div>
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
            <ActionButton variant="approve" icon="✓" size="sm" onClick={() => setStatus('approved')}>Aprobar</ActionButton>
            <ActionButton variant="reject" icon="✕" size="sm" onClick={() => setStatus('rejected')}>Rechazar</ActionButton>
          </>
        ) : (
          <div className={styles.alreadyActioned}>{status === 'approved' ? 'Aprobado' : 'Rechazado'}</div>
        )}
      </div>
    </div>
  )
}