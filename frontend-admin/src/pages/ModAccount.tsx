import { useState } from 'react'
import { AccountCard } from '../components/AccountCard'
import { mockAccounts } from '../data/Mocksdata'
import type { AccountStatus } from '../types'
import pageStyles from '../styles/pages/ModAccount.module.css'

type Filter = 'all' | AccountStatus

export function ModerationAccounts() {
  const [filter, setFilter] = useState<Filter>('under_review')
  const [sort, setSort] = useState<'reports' | 'date'>('reports')

  const filtered = mockAccounts
    .filter(a => filter === 'all' || a.status === filter)
    .sort((a, b) => sort === 'reports'
      ? (b.reportedPostsCount + b.reportedCommentsCount) - (a.reportedPostsCount + a.reportedCommentsCount)
      : new Date(b.lastActiveAt).getTime() - new Date(a.lastActiveAt).getTime()
    )

  const reviewCount = mockAccounts.filter(a => a.status === 'under_review').length

  return (
    <div className={pageStyles.page}>
      {reviewCount > 0 && (
        <div className={`${pageStyles.banner} ${pageStyles.bannerPending}`}>
          <span className={pageStyles.bannerIcon}>👤</span>
          <div className={pageStyles.bannerText}>
            <span className={pageStyles.bannerCount}>{reviewCount} cuentas</span> en espera de revisión
          </div>
        </div>
      )}

      <div className={pageStyles.toolbar}>
        <div className={pageStyles.filterGroup}>
          {([
            { value: 'under_review', label: 'En revisión' },
            { value: 'active', label: 'Activas' },
            { value: 'suspended', label: 'Suspendidas' },
            { value: 'banned', label: 'Baneadas' },
            { value: 'all', label: 'Todas' },
          ] as { value: Filter; label: string }[]).map(f => (
            <button key={f.value} className={`${pageStyles.filterBtn} ${filter === f.value ? pageStyles.active : ''}`} onClick={() => setFilter(f.value)}>
              {f.label}
            </button>
          ))}
        </div>
        <select className={pageStyles.sortSelect} value={sort} onChange={e => setSort(e.target.value as 'reports' | 'date')}>
          <option value="reports">Ordenar: Más reportados</option>
          <option value="date">Ordenar: Más recientes</option>
        </select>
      </div>

      {filtered.length === 0 ? (
        <div className={pageStyles.empty}>
          <div className={pageStyles.emptyIcon}>👤</div>
          <div className={pageStyles.emptyTitle}>Sin cuentas</div>
          <div className={pageStyles.emptyText}>No hay cuentas con este filtro.</div>
        </div>
      ) : (
        <div className={pageStyles.grid}>
          {filtered.map((account, i) => <AccountCard key={account.id} account={account} animDelay={i * 60} />)}
        </div>
      )}
    </div>
  )
}