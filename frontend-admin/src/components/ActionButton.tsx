import styles from '../styles/components/ActionButton.module.css'

type ActionVariant = 'approve' | 'reject' | 'view' | 'suspend' | 'ban'

interface ActionButtonProps {
  variant: ActionVariant
  onClick?: () => void
  size?: 'sm' | 'md'
  children: React.ReactNode
  icon?: string
}

export function ActionButton({ variant, onClick, size = 'md', children, icon }: ActionButtonProps) {
  return (
    <button
      className={`${styles.btn} ${styles[variant]} ${size === 'sm' ? styles.sm : ''}`}
      onClick={onClick}
    >
      {icon && <span className={styles.icon}>{icon}</span>}
      {children}
    </button>
  )
}