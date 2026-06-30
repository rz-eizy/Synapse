import { NavLink } from 'react-router-dom'
import styles from '../styles/components/Sidebar.module.css'

interface NavItem {
  to: string
  icon: string
  label: string
  badge?: number
}

const mainNav: NavItem[] = [
  { to: '/', icon: '⬡', label: 'Dashboard' },
]

const moderationNav: NavItem[] = [
  { to: '/comentarios', icon: '💬', label: 'Comentarios', badge: 5 },
  { to: '/comunidad', icon: '👥', label: 'Posts Comunidad', badge: 4 },
  { to: '/profesionales', icon: '🏥', label: 'Posts Profesionales', badge: 3 },
    { to: '/reportesprofesionales', icon: '🚩', label: 'Reportes Profesionales', badge: 2 },
  { to: '/cuentas', icon: '👤', label: 'Cuentas', badge: 2 },
]

export function Sidebar() {
  return (
    <aside className={styles.sidebar}>
      <div className={styles.brand}>
        <div className={styles.brandIcon}></div>
        <div className={styles.brandText}>
          <span className={styles.brandName}>Appoyo</span>
          <span className={styles.brandSub}>Admin Panel</span>
        </div>
      </div>

      <div className={styles.divider} />

      <nav className={styles.nav}>
        {mainNav.map((item) => (
          <NavLink
            key={item.to} to={item.to} end
            className={({ isActive }) => [styles.navItem, isActive ? styles.active : ''].join(' ')}
          >
            <span className={styles.navIcon}>{item.icon}</span>
            <span className={styles.navLabel}>{item.label}</span>
          </NavLink>
        ))}

        <div className={styles.navSection}>
          <p className={styles.navSectionLabel}>Moderación</p>
          {moderationNav.map((item) => (
            <NavLink
              key={item.to} to={item.to}
              className={({ isActive }) => [styles.navItem, isActive ? styles.active : ''].join(' ')}
            >
              <span className={styles.navIcon}>{item.icon}</span>
              <span className={styles.navLabel}>{item.label}</span>
              {item.badge !== undefined && item.badge > 0 && (
                <span className={styles.navBadge}>{item.badge}</span>
              )}
            </NavLink>
          ))}
        </div>
      </nav>

      <div className={styles.sidebarFooter}>
        <div className={styles.adminCard}>
          <div className={styles.adminAvatar}>A</div>
          <div className={styles.adminInfo}>
            <div className={styles.adminName}>Admin Principal</div>
            <div className={styles.adminRole}>Conectado</div>
          </div>
          <div className={styles.adminDot} />
        </div>
      </div>
    </aside>
  )
}