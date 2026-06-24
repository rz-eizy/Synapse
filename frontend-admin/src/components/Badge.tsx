import type { ModerationStatus, AccountStatus, UserType } from '../types'
import styles from '../styles/components/Badge.module.css'

type BadgeVariant = ModerationStatus | AccountStatus | UserType

const labels: Record<BadgeVariant, string> = {
  pending: 'Pendiente', approved: 'Aprobado', rejected: 'Rechazado',
  active: 'Activo', suspended: 'Suspendido', banned: 'Baneado',
  under_review: 'En revisión', community: 'Comunidad', professional: 'Profesional',
}

interface BadgeProps { variant: BadgeVariant; showDot?: boolean }

export function Badge({ variant, showDot = true }: BadgeProps) {
  return (
    <span className={`${styles.badge} ${styles[variant]}`}>
      {showDot && <span className={styles.dot} />}
      {labels[variant]}
    </span>
  )
}