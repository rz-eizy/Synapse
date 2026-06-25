import { useLocation } from 'react-router-dom'
import { Sidebar } from './Sidebar'
import styles from '../styles/components/Layout.module.css'

interface LayoutProps { children: React.ReactNode }

const pageTitles: Record<string, { title: string; sub: string }> = {
  '/': { title: 'Dashboard', sub: 'Resumen general del sistema' },
  '/comentarios': { title: 'Moderación · Comentarios', sub: 'Revisa y gestiona los comentarios reportados' },
  '/comunidad': { title: 'Moderación · Comunidad', sub: 'Publicaciones de usuarios de la comunidad' },
  '/profesionales': { title: 'Moderación · Profesionales', sub: 'Publicaciones de cuentas profesionales verificadas' },
  '/cuentas': { title: 'Moderación · Cuentas', sub: 'Gestión y revisión de cuentas de usuario' },
}

function formatDate() {
  return new Date().toLocaleDateString('es-ES', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
}

export function Layout({ children }: LayoutProps) {
  const location = useLocation()
  const pageInfo = pageTitles[location.pathname] ?? { title: 'Admin Panel', sub: '' }

  return (
    <div className={styles.layout}>
      <Sidebar />
      <div className={styles.main}>
        <header className={styles.topbar}>
          <div className={styles.topbarLeft}>
            <span className={styles.topbarTitle}>{pageInfo.title}</span>
            <span className={styles.topbarSub}>{pageInfo.sub}</span>
          </div>
          <div className={styles.topbarRight}>
            <span className={styles.topbarDate}>{formatDate()}</span>
            <button className={styles.topbarNotif} aria-label="Notificaciones">
              🔔
              <span className={styles.notifDot} />
            </button>
          </div>
        </header>
        <main className={styles.content}>{children}</main>
      </div>
    </div>
  )
}