import { useState } from 'react'
import type { ProfessionalRequest } from '../types'
import { Badge } from './Badge'
import { ActionButton } from './ActionButton'
import styles from '../styles/components/AccountCard.module.css'

interface ProfessionalRequestCardProps {
  request: ProfessionalRequest
  animDelay?: number
  onApprove: (id: string, professionName: string) => Promise<void>
  onReject: (id: string, reason: string) => Promise<void>
}

function getInitials(name: string) {
  if (!name) return 'U'
  return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()
}

function formatDate(iso: string) {
  if (!iso) return ''
  return new Date(iso).toLocaleString('es-ES', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })
}

export function ProfessionalRequestCard({ request, animDelay = 0, onApprove, onReject }: ProfessionalRequestCardProps) {
  const [isApproving, setIsApproving] = useState(false)
  const [isRejecting, setIsRejecting] = useState(false)
  const [professionName, setProfessionName] = useState('')
  const [rejectReason, setRejectReason] = useState('No se encuentra en el registro nacional de prestadores de salud.')
  const [loading, setLoading] = useState(false)

  const handleApproveSubmit = async () => {
    if (!professionName.trim()) return
    setLoading(true)
    try {
      await onApprove(request.id, professionName)
      setIsApproving(false)
    } finally {
      setLoading(false)
    }
  }

  const handleRejectSubmit = async () => {
    if (!rejectReason.trim()) return
    setLoading(true)
    try {
      await onReject(request.id, rejectReason)
      setIsRejecting(false)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className={styles.card} style={{ animationDelay: `${animDelay}ms` }}>
      <div className={styles.cardHeader}>
        <div className={styles.avatarWrap}>
          <div className={styles.avatar}>{getInitials(request.user?.displayName || request.user?.username || 'User')}</div>
        </div>
        <div className={styles.headerInfo}>
          <div className={styles.displayName}>{request.user?.displayName || request.user?.username || 'Desconocido'}</div>
          <div className={styles.username}>{request.user?.email}</div>
          <div className={styles.badgeGroup}>
            <Badge variant="professional" />
            <Badge variant={request.status.toLowerCase() as any} />
          </div>
        </div>
      </div>

      <div style={{ marginTop: '1rem', marginBottom: '1rem' }}>
        <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>Carnet / Identificación:</p>
        {request.verificationPictureUrl ? (
          <img 
            src={request.verificationPictureUrl} 
            alt="Carnet de identidad" 
            style={{ width: '100%', height: '160px', objectFit: 'cover', borderRadius: '8px', border: '1px solid var(--border-color)', cursor: 'pointer' }}
            onClick={() => window.open(request.verificationPictureUrl, '_blank')}
            title="Clic para ver en grande"
          />
        ) : (
          <div style={{ padding: '1rem', background: 'var(--bg-tertiary)', borderRadius: '8px', textAlign: 'center', fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
            No hay imagen adjunta
          </div>
        )}
      </div>

      <div className={styles.cardFooter}>
        <span className={styles.lastActive}>Fecha: {formatDate(request.createdAt)}</span>
        <div className={styles.actions}>
          {request.status === 'PENDING' && !isApproving && !isRejecting && (
            <>
              <ActionButton variant="reject" icon="✕" size="sm" onClick={() => setIsRejecting(true)}>Rechazar</ActionButton>
              <ActionButton variant="approve" icon="✓" size="sm" onClick={() => setIsApproving(true)}>Aceptar</ActionButton>
            </>
          )}
        </div>
      </div>

      {isApproving && (
        <div style={{ padding: '1rem', borderTop: '1px solid var(--color-border)', background: 'var(--color-bg)', borderBottomLeftRadius: '12px', borderBottomRightRadius: '12px' }}>
          <p style={{ fontSize: '0.85rem', marginBottom: '0.5rem', fontWeight: 500, color: 'var(--color-text-primary)' }}>Profesión a asignar:</p>
          <input 
            type="text" 
            value={professionName}
            onChange={(e) => setProfessionName(e.target.value)}
            placeholder="Ej. Psicólogo, Médico..."
            style={{ width: '100%', padding: '0.5rem', borderRadius: '6px', border: '1px solid var(--color-border)', background: 'var(--color-surface)', color: 'var(--color-text-primary)', marginBottom: '0.5rem' }}
            autoFocus
          />
          <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'flex-end' }}>
            <button 
              onClick={() => setIsApproving(false)}
              style={{ padding: '0.4rem 0.8rem', borderRadius: '6px', background: 'transparent', border: '1px solid var(--color-border)', color: 'var(--color-text-secondary)', cursor: 'pointer', fontSize: '0.8rem' }}
              disabled={loading}
            >
              Cancelar
            </button>
            <button 
              onClick={handleApproveSubmit}
              disabled={!professionName.trim() || loading}
              style={{ padding: '0.4rem 0.8rem', borderRadius: '6px', background: 'var(--color-success)', border: 'none', color: '#fff', cursor: professionName.trim() ? 'pointer' : 'not-allowed', fontSize: '0.8rem', fontWeight: 500 }}
            >
              {loading ? 'Guardando...' : 'Confirmar'}
            </button>
          </div>
        </div>
      )}

      {isRejecting && (
        <div style={{ padding: '1rem', borderTop: '1px solid var(--color-border)', background: 'var(--color-bg)', borderBottomLeftRadius: '12px', borderBottomRightRadius: '12px' }}>
          <p style={{ fontSize: '0.85rem', marginBottom: '0.5rem', fontWeight: 500, color: 'var(--color-text-primary)' }}>Motivo del rechazo:</p>
          <textarea 
            value={rejectReason}
            onChange={(e) => setRejectReason(e.target.value)}
            style={{ width: '100%', padding: '0.5rem', borderRadius: '6px', border: '1px solid var(--color-border)', background: 'var(--color-surface)', color: 'var(--color-text-primary)', marginBottom: '0.5rem', minHeight: '60px', resize: 'vertical', fontFamily: 'inherit' }}
            autoFocus
          />
          <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'flex-end' }}>
            <button 
              onClick={() => setIsRejecting(false)}
              style={{ padding: '0.4rem 0.8rem', borderRadius: '6px', background: 'transparent', border: '1px solid var(--color-border)', color: 'var(--color-text-secondary)', cursor: 'pointer', fontSize: '0.8rem' }}
              disabled={loading}
            >
              Cancelar
            </button>
            <button 
              onClick={handleRejectSubmit}
              disabled={!rejectReason.trim() || loading}
              style={{ padding: '0.4rem 0.8rem', borderRadius: '6px', background: 'var(--color-danger)', border: 'none', color: '#fff', cursor: rejectReason.trim() ? 'pointer' : 'not-allowed', fontSize: '0.8rem', fontWeight: 500 }}
            >
              {loading ? 'Enviando...' : 'Rechazar'}
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
