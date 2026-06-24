import { Link } from 'react-router-dom'
import { StatsCard } from '../components/StatsCard'
import { dashboardStats } from '../data/Mocksdata'
import styles from '../styles/pages/HomePage.module.css'

const activities = [
  { id: 1, type: 'danger',  text: <><strong>Post rechazado</strong> · Publicación de @ana_vibes marcada como contenido no permitido</>,            time: 'Hace 5 min' },
  { id: 2, type: 'success', text: <><strong>Post aprobado</strong> · Artículo de @dr_hernandez sobre bienestar publicado</>,                        time: 'Hace 12 min' },
  { id: 3, type: 'warning', text: <><strong>Cuenta en revisión</strong> · @psic_luna solicitó verificación profesional</>,                          time: 'Hace 28 min' },
  { id: 4, type: 'danger',  text: <><strong>Comentario rechazado</strong> · Comentario de @miguel_foto con 4 reportes eliminado</>,                  time: 'Hace 45 min' },
  { id: 5, type: 'info',    text: <><strong>Nuevo reporte</strong> · Post de @nutri_garcia reportado por contenido publicitario</>,                  time: 'Hace 1h' },
  { id: 6, type: 'success', text: <><strong>Cuenta verificada</strong> · @dr_hernandez confirmada como profesional de salud</>,                      time: 'Hace 2h' },
]

const quickLinks = [
  { to: '/comentarios',   icon: '💬', bg: '#EDE9FE', title: 'Comentarios',         sub: 'Revisar reportes',          count: 5 },
  { to: '/comunidad',     icon: '👥', bg: '#FEF3C7', title: 'Posts Comunidad',     sub: 'Pendientes de revisión',    count: 4 },
  { to: '/profesionales', icon: '🏥', bg: '#DBEAFE', title: 'Posts Profesionales', sub: 'Pendientes de revisión',    count: 3 },
  { to: '/cuentas',       icon: '👤', bg: '#D1FAE5', title: 'Cuentas',             sub: 'En revisión',               count: 2 },
]

export function HomePage() {
  return (
    <div className={styles.page}>

      <section className={`${styles.hero} animate-scaleIn`}>
        <div className={styles.heroOrbs}>
          <div className={`${styles.orb} ${styles.orb1}`} />
          <div className={`${styles.orb} ${styles.orb2}`} />
          <div className={`${styles.orb} ${styles.orb3}`} />
        </div>

        <div className={styles.heroContent}>
          <div className={styles.heroLeft}>
            <span className={styles.heroEyebrow}>Panel de Control</span>
            <h1 className={styles.heroTitle}>
              Bienvenido al<br />
              <span>Centro de Moderación</span>
            </h1>
            <p className={styles.heroSubtitle}>
              Mantén la comunidad segura revisando publicaciones, comentarios y cuentas desde un solo lugar.
            </p>
          </div>
          <div className={styles.heroRight}>
            <div className={styles.heroPill}>
              <div className={styles.heroPillDot} />
              Sistema operativo
            </div>
          </div>
        </div>

        <div className={styles.heroFooter}>
          <div className={styles.heroStat}><span className={styles.heroStatValue}>{dashboardStats.resolvedToday}</span><span className={styles.heroStatLabel}>Resueltos hoy</span></div>
          <div className={styles.heroStat}><span className={styles.heroStatValue}>{dashboardStats.totalReports}</span><span className={styles.heroStatLabel}>Reportes totales</span></div>
          <div className={styles.heroStat}><span className={styles.heroStatValue}>{dashboardStats.approvalRate}%</span><span className={styles.heroStatLabel}>Tasa de aprobación</span></div>
        </div>
      </section>

      <div className={styles.statsGrid}>
        <StatsCard label="Publicaciones pendientes" value={dashboardStats.pendingPosts}    icon="📝" accentColor="var(--color-warning)" accentBg="var(--color-warning-light)" footer="requieren revisión hoy"    animDelay={0} />
        <StatsCard label="Comentarios pendientes"   value={dashboardStats.pendingComments} icon="💬" accentColor="var(--color-primary)" accentBg="var(--color-primary-xxlight)" footer="en cola de moderación"   animDelay={60} />
        <StatsCard label="Cuentas en revisión"      value={dashboardStats.pendingAccounts} icon="👤" accentColor="var(--color-info)"    accentBg="var(--color-info-light)"      footer="esperando verificación" animDelay={120} />
        <StatsCard label="Resueltos hoy"            value={dashboardStats.resolvedToday}   icon="✅" accentColor="var(--color-success)" accentBg="var(--color-success-light)"  footer="acciones de moderación" animDelay={180} />
        <StatsCard label="Reportes totales"         value={dashboardStats.totalReports}    icon="🚩" accentColor="var(--color-danger)"  accentBg="var(--color-danger-light)"   footer="reportes activos"       animDelay={240} />
        <StatsCard label="Tasa de aprobación"       value={`${dashboardStats.approvalRate}%`} icon="📊" accentColor="#7C3AED" accentBg="#EDE9FE"                              footer="de contenido aprobado"  animDelay={300} />
      </div>

      <section className={styles.section}>
        <div className={styles.sectionHeader}>
          <h2 className={styles.sectionTitle}>Acceso rápido</h2>
        </div>
        <div className={styles.quickGrid}>
          {quickLinks.map((item, i) => (
            <Link key={item.to} to={item.to} className={styles.quickCard} style={{ animationDelay: `${i * 60}ms` }}>
              <div className={styles.quickIcon} style={{ background: item.bg }}>{item.icon}</div>
              <div className={styles.quickTitle}>{item.title}</div>
              <div className={styles.quickSub}>{item.sub}</div>
              <span className={`${styles.quickCount} ${item.count === 0 ? styles.safe : ''}`}>{item.count} pendientes</span>
            </Link>
          ))}
        </div>
      </section>

      <div className={styles.twoCol}>
        <section className={styles.section}>
          <div className={styles.sectionHeader}><h2 className={styles.sectionTitle}>Actividad reciente</h2></div>
          <div className={styles.activityFeed}>
            <div className={styles.activityHeader}>Últimas acciones</div>
            {activities.map((a, i) => (
              <div key={a.id} className={styles.activityItem} style={{ animationDelay: `${i * 50}ms` }}>
                <div className={`${styles.activityDot} ${styles[a.type as keyof typeof styles]}`} />
                <div className={styles.activityText}>{a.text}</div>
                <div className={styles.activityTime}>{a.time}</div>
              </div>
            ))}
          </div>
        </section>

        <section className={styles.section}>
          <div className={styles.sectionHeader}><h2 className={styles.sectionTitle}>Estado del sistema</h2></div>
          <div className={styles.activityFeed}>
            <div className={styles.activityHeader}>Módulos activos</div>
            {[
              { label: 'Moderación de posts', ok: true },
              { label: 'Moderación de comentarios', ok: true },
              { label: 'Gestión de cuentas', ok: true },
              { label: 'Sistema de reportes', ok: true },
              { label: 'Notificaciones push', ok: false },
            ].map((s, i) => (
              <div key={s.label} className={styles.activityItem} style={{ animationDelay: `${i * 50}ms` }}>
                <div className={`${styles.activityDot} ${s.ok ? styles.success : styles.warning}`} />
                <div className={styles.activityText}>{s.label}</div>
                <div className={styles.activityTime}>{s.ok ? '✅ Activo' : '⚠️ Limitado'}</div>
              </div>
            ))}
          </div>
        </section>
      </div>

    </div>
  )
}