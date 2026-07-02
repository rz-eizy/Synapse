import { useState, useEffect } from 'react'
import { ProfessionalRequestCard } from '../components/ProfessionalRequestCard'
import type { ProfessionalRequest } from '../types'
import { getProfessionalRequests, approveProfessionalRequest, rejectProfessionalRequest } from '../services/api'
import pageStyles from '../styles/pages/ModAccount.module.css'

export function ModerationProfessionalRequests() {
  const [requests, setRequests] = useState<ProfessionalRequest[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [filter, setFilter] = useState<'PENDING' | 'APPROVED' | 'REJECTED' | 'all'>('PENDING')

  const fetchRequests = async () => {
    try {
      setLoading(true)
      const data = await getProfessionalRequests(0, 50)
      setRequests(data.content || [])
    } catch (err: any) {
      setError(err.message || 'Error al cargar las solicitudes')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchRequests()
  }, [])

  const handleApprove = async (id: string, professionName: string) => {
    await approveProfessionalRequest(id, professionName)
    await fetchRequests()
  }

  const handleReject = async (id: string, reason: string) => {
    await rejectProfessionalRequest(id, reason)
    await fetchRequests()
  }

  const filtered = requests.filter(r => filter === 'all' || r.status === filter)
  const pendingCount = requests.filter(r => r.status === 'PENDING').length

  if (loading && requests.length === 0) {
    return <div className={pageStyles.page} style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>Cargando solicitudes...</div>
  }

  if (error) {
    return <div className={pageStyles.page} style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%', color: 'var(--danger-color)' }}>{error}</div>
  }

  return (
    <div className={pageStyles.page}>
      <div className={pageStyles.header}>
        <h1 className={pageStyles.title}>Ascensos a Profesional</h1>
        <p className={pageStyles.subtitle}>Revisa los carnets de identidad para otorgar insignias de profesional</p>
      </div>

      {pendingCount > 0 && (
        <div className={`${pageStyles.banner} ${pageStyles.bannerPending}`}>
          <span className={pageStyles.bannerIcon}>🏥</span>
          <div className={pageStyles.bannerText}>
            <span className={pageStyles.bannerCount}>{pendingCount} solicitudes</span> en espera de revisión
          </div>
        </div>
      )}

      <div className={pageStyles.toolbar}>
        <div className={pageStyles.filterGroup}>
          {([
            { value: 'PENDING', label: 'Pendientes' },
            { value: 'APPROVED', label: 'Aprobadas' },
            { value: 'REJECTED', label: 'Rechazadas' },
            { value: 'all', label: 'Todas' },
          ] as const).map(f => (
            <button 
              key={f.value} 
              className={`${pageStyles.filterBtn} ${filter === f.value ? pageStyles.active : ''}`} 
              onClick={() => setFilter(f.value)}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {filtered.length === 0 ? (
        <div className={pageStyles.empty}>
          <div className={pageStyles.emptyIcon}>📋</div>
          <div className={pageStyles.emptyTitle}>Sin solicitudes</div>
          <div className={pageStyles.emptyText}>No hay solicitudes de ascenso con este filtro.</div>
        </div>
      ) : (
        <div className={pageStyles.grid}>
          {filtered.map((req, i) => (
            <ProfessionalRequestCard 
              key={req.id} 
              request={req} 
              animDelay={i * 60} 
              onApprove={handleApprove}
              onReject={handleReject}
            />
          ))}
        </div>
      )}
    </div>
  )
}
