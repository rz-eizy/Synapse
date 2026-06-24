import { useState } from 'react'
import { PostCard } from '../components/PostCard'
import { mockProfessionalPosts } from '../data/Mocksdata'
import type { ModerationStatus } from '../types'
import pageStyles from '../styles/pages/ModProfessionalPage.module.css'

type Filter = 'all' | ModerationStatus

export function ModerationProfessionals() {
  const [filter, setFilter] = useState<Filter>('pending')
  const [sort, setSort] = useState<'date' | 'reports'>('reports')

  const filtered = mockProfessionalPosts
    .filter(p => filter === 'all' || p.status === filter)
    .sort((a, b) => sort === 'reports' ? b.reportsCount - a.reportsCount : new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())

  const pendingCount = mockProfessionalPosts.filter(p => p.status === 'pending').length

  return (
    <div className={pageStyles.page}>
      {pendingCount > 0 && (
        <div className={`${pageStyles.banner} ${pageStyles.bannerPending}`}>
          <span className={pageStyles.bannerIcon}>🏥</span>
          <div className={pageStyles.bannerText}>
            <span className={pageStyles.bannerCount}>{pendingCount} publicaciones</span> de profesionales esperando revisión
          </div>
        </div>
      )}

      <div className={pageStyles.toolbar}>
        <div className={pageStyles.filterGroup}>
          {(['pending', 'approved', 'rejected', 'all'] as Filter[]).map(f => (
            <button key={f} className={`${pageStyles.filterBtn} ${filter === f ? pageStyles.active : ''}`} onClick={() => setFilter(f)}>
              {f === 'all' ? 'Todos' : f === 'pending' ? 'Pendientes' : f === 'approved' ? 'Aprobados' : 'Rechazados'}
            </button>
          ))}
        </div>
        <select className={pageStyles.sortSelect} value={sort} onChange={e => setSort(e.target.value as 'date' | 'reports')}>
          <option value="reports">Ordenar: Más reportados</option>
          <option value="date">Ordenar: Más recientes</option>
        </select>
      </div>

      {filtered.length === 0 ? (
        <div className={pageStyles.empty}>
          <div className={pageStyles.emptyIcon}>🏥</div>
          <div className={pageStyles.emptyTitle}>Sin publicaciones</div>
          <div className={pageStyles.emptyText}>No hay publicaciones con este filtro.</div>
        </div>
      ) : (
        <div className={pageStyles.grid}>
          {filtered.map((post, i) => <PostCard key={post.id} post={post} animDelay={i * 60} />)}
        </div>
      )}
    </div>
  )
}