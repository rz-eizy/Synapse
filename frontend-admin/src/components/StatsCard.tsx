import styles from '../styles/components/StatsCard.module.css'

interface StatsCardProps {
  label: string; value: number | string; icon: string;
  accentColor?: string; accentBg?: string;
  footer?: string; highlight?: string; animDelay?: number;
}

export function StatsCard({ label, value, icon, accentColor, accentBg, footer, highlight, animDelay = 0 }: StatsCardProps) {
  return (
    <div
      className={`${styles.card} animate-fadeInUp`}
      style={{ '--accent-color': accentColor, '--accent-bg': accentBg, animationDelay: `${animDelay}ms` } as React.CSSProperties}
    >
      <div className={styles.header}>
        <span className={styles.label}>{label}</span>
        <div className={styles.iconWrap}>{icon}</div>
      </div>
      <div className={styles.value}>{value}</div>
      {footer && (
        <div className={styles.footer}>
          {highlight && <span className={styles.highlight}>{highlight} </span>}
          {footer}
        </div>
      )}
    </div>
  )
}