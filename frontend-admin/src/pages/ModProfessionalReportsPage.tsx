import { useState } from 'react'
import styles from '../styles/pages/ModProfesionalReportsPage.module.css'

type ModerationStatus = 'pending' | 'approved' | 'rejected'

interface Report {
  id: string
  reason: string
  reportedBy: string
  createdAt: string
}

interface ReportedPost {
  id: string
  authorName: string
  imageUrl: string
  content: string
  status: ModerationStatus
  reports: Report[]
}

// mocksss
const MOCK_REPORTED_POSTS: ReportedPost[] = [
  {
    id: '1',
    authorName: 'Dra. Carolina Reyes',
    imageUrl: 'https://placehold.co/400x200?text=Post+1',
    content: 'Medicina natural 110% efectiva y milagrosa',
    status: 'pending',
    reports: [
      { id: 'r1', reason: 'Información médica incorrecta', reportedBy: 'usuario_321', createdAt: '2026-06-27T09:00:00Z' },
      { id: 'r2', reason: 'Contenido engañoso', reportedBy: 'usuario_88', createdAt: '2026-06-28T11:20:00Z' }
    ]
  },
  {
    id: '2',
    authorName: 'Lic. Martín Soto',
    imageUrl: 'https://placehold.co/400x200?text=Post+2',
    content: 'Siganme en mi instagram personal!!!',
    status: 'pending',
    reports: [
      { id: 'r3', reason: 'Spam o autopromoción', reportedBy: 'usuario_12', createdAt: '2026-06-26T14:00:00Z' }
    ]
  },
  {
    id: '3',
    authorName: 'Obst. Javiera Cortés',
    imageUrl: 'https://placehold.co/400x200?text=Post+3',
    content: 'Mitos comunes sobre el Trastorno del espectro autista, aclarados.',
    status: 'approved',
    reports: [
      { id: 'r4', reason: 'Lenguaje inapropiado', reportedBy: 'usuario_45', createdAt: '2026-06-20T18:00:00Z' },
      { id: 'r5', reason: 'Información médica incorrecta', reportedBy: 'usuario_99', createdAt: '2026-06-21T08:30:00Z' },
      { id: 'r6', reason: 'Contenido engañoso', reportedBy: 'usuario_4', createdAt: '2026-06-22T10:10:00Z' }
    ]
  }
]

const STATUS_LABEL: Record<ModerationStatus, string> = {
  pending: 'Pendiente',
  approved: 'Aprobado',
  rejected: 'Rechazado'
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString('es-CL', { day: '2-digit', month: 'short' })
}

export function ModerationProfessionalReports() {
  const [posts, setPosts] = useState<ReportedPost[]>(MOCK_REPORTED_POSTS)

  const handleModerate = (id: string, newStatus: ModerationStatus) => {
    setPosts(prev => prev.map(p => p.id === id ? { ...p, status: newStatus } : p))
  }

  const sortedPosts = [...posts].sort((a, b) => b.reports.length - a.reports.length)
  const reportedCount = posts.length

  return (
    <div className={styles.page}>
      {reportedCount > 0 && (
        <div className={`${styles.banner} ${styles.bannerDanger}`}>
          <span className={styles.bannerIcon}>🚩</span>
          <div className={styles.bannerText}>
            <span className={styles.bannerCount}>{reportedCount} publicaciones</span> de profesionales con reportes activos
          </div>
        </div>
      )}

      {sortedPosts.length === 0 ? (
        <div className={styles.empty}>
          <div className={styles.emptyIcon}>🚩</div>
          <div className={styles.emptyTitle}>Sin reportes</div>
          <div className={styles.emptyText}>No hay publicaciones de profesionales reportadas.</div>
        </div>
      ) : (
        <div className={styles.grid}>
          {sortedPosts.map(post => (
            <div key={post.id} className={styles.card}>
              <img className={styles.cardImage} src={post.imageUrl} alt={post.authorName} />
              <div className={styles.cardBody}>
                <div className={styles.cardHeader}>
                  <div className={styles.author}>
                    <div className={styles.authorAvatar}>{post.authorName.charAt(0)}</div>
                    <span className={styles.authorName}>{post.authorName}</span>
                  </div>
                  <span className={styles.reportsBadge}>
                    🚩 {post.reports.length} {post.reports.length === 1 ? 'reporte' : 'reportes'}
                  </span>
                </div>

                <p className={styles.content}>{post.content}</p>

                <div className={styles.reportsList}>
                  {post.reports.map(report => (
                    <div key={report.id} className={styles.reportItem}>
                      <span className={styles.reportReason}>{report.reason}</span>
                      <span className={styles.reportMeta}>{report.reportedBy} · {formatDate(report.createdAt)}</span>
                    </div>
                  ))}
                </div>

                <div className={styles.actions}>
                  <button className={styles.approveBtn} onClick={() => handleModerate(post.id, 'approved')}>
                    {STATUS_LABEL[post.status] === 'Aprobado' ? 'Aprobado' : 'Aprobar'}
                  </button>
                  <button className={styles.rejectBtn} onClick={() => handleModerate(post.id, 'rejected')}>
                    Eliminar publicación
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}