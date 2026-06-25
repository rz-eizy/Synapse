import { useState } from 'react'
import type { Post } from '../types'
import { Badge } from './Badge'
import { ActionButton } from './ActionButton'
import styles from '../styles/components/PostCard.module.css'

interface PostCardProps { post: Post; animDelay?: number }

function formatDate(iso: string) {
  return new Date(iso).toLocaleString('es-ES', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })
}
function getInitials(name: string) {
  return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()
}

export function PostCard({ post, animDelay = 0 }: PostCardProps) {
  const [status, setStatus] = useState(post.status)
  const isFlagged = post.reportsCount >= 5

  return (
    <div className={`${styles.card} ${isFlagged ? styles.flagged : ''}`} style={{ animationDelay: `${animDelay}ms` }}>
      <div className={styles.cardHeader}>
        <div className={styles.authorInfo}>
          <div className={styles.avatar}>{getInitials(post.author.displayName)}</div>
          <div className={styles.authorMeta}>
            <span className={styles.displayName}>{post.author.displayName}</span>
            <span className={styles.username}>@{post.author.username}</span>
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
        <div className={styles.metaStat}><span className={styles.metaStatIcon}>❤️</span><span className={styles.metaStatValue}>{post.likesCount}</span></div>
        <div className={styles.metaStat}><span className={styles.metaStatIcon}>💬</span><span className={styles.metaStatValue}>{post.commentsCount}</span></div>
        {post.reportsCount > 0 && (
          <div className={`${styles.metaStat} ${styles.reportStat}`}>
            <span className={styles.metaStatIcon}>🚩</span>
            <span className={styles.metaStatValue}>{post.reportsCount} reportes</span>
          </div>
        )}
        <span className={styles.metaDate}>{formatDate(post.createdAt)}</span>
      </div>

      <div className={styles.cardFooter}>
        {status === 'pending' ? (
          <>
            <ActionButton variant="view" icon="👁" size="sm">Revisar</ActionButton>
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