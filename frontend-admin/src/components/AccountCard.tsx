import { useState } from 'react'
import type { Account } from '../types'
import { Badge } from './Badge'
import { ActionButton } from './ActionButton'
import styles from '../styles/components/AccountCard.module.css'

interface AccountCardProps { account: Account; animDelay?: number }

function getInitials(name: string) {
  return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()
}
function formatLastActive(iso: string) {
  return new Date(iso).toLocaleString('es-ES', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })
}

export function AccountCard({ account, animDelay = 0 }: AccountCardProps) {
  const [status, setStatus] = useState(account.status)
  const isFlagged = account.reportedPostsCount >= 5

  return (
    <div className={`${styles.card} ${isFlagged ? styles.flagged : ''}`} style={{ animationDelay: `${animDelay}ms` }}>
      <div className={styles.cardHeader}>
        <div className={styles.avatarWrap}>
          <div className={styles.avatar}>{getInitials(account.user.displayName)}</div>
          {account.user.verified && <div className={styles.verifiedBadge}>✓</div>}
        </div>
        <div className={styles.headerInfo}>
          <div className={styles.displayName}>{account.user.displayName}</div>
          <div className={styles.username}>@{account.user.username} · {account.user.email}</div>
          <div className={styles.badgeGroup}>
            <Badge variant={account.user.type} />
            <Badge variant={status} />
          </div>
        </div>
      </div>

      {account.bio && <p className={styles.bio}>"{account.bio}"</p>}

      <div className={styles.statsGrid}>
        <div className={styles.stat}>
          <span className={styles.statValue}>{account.postsCount}</span>
          <span className={styles.statLabel}>Publicaciones</span>
        </div>
        <div className={styles.stat}>
          <span className={`${styles.statValue} ${account.reportedPostsCount > 4 ? styles.danger : ''}`}>{account.reportedPostsCount}</span>
          <span className={styles.statLabel}>Posts reportados</span>
        </div>
        <div className={styles.stat}>
          <span className={`${styles.statValue} ${account.reportedCommentsCount > 2 ? styles.danger : ''}`}>{account.reportedCommentsCount}</span>
          <span className={styles.statLabel}>Comentarios rep.</span>
        </div>
      </div>

      <div className={styles.cardFooter}>
        <span className={styles.lastActive}>Activo: {formatLastActive(account.lastActiveAt)}</span>
        <div className={styles.actions}>
          {status !== 'banned' && status !== 'suspended' ? (
            <>
              <ActionButton variant="suspend" icon="⏸" size="sm" onClick={() => setStatus('suspended')}>Suspender</ActionButton>
              <ActionButton variant="ban" icon="🚫" size="sm" onClick={() => setStatus('banned')}>Banear</ActionButton>
            </>
          ) : (
            <ActionButton variant="approve" icon="↩" size="sm" onClick={() => setStatus('active')}>Restaurar</ActionButton>
          )}
        </div>
      </div>
    </div>
  )
}