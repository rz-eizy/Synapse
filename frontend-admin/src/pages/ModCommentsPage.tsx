import { useState, useEffect } from 'react'
import { CommentCard } from '../components/CommentCard'
import { getComments, moderateComment, getCommentReports } from '../services/api'
import type { ModerationStatus, Comment, UserType } from '../types'
import pageStyles from '../styles/pages/ModCommentsPage.module.css'

type Filter = 'all' | ModerationStatus

export function ModerationComments() {
  const [filter, setFilter] = useState<Filter>('pending')
  const [sort, setSort] = useState<'date' | 'reports'>('reports')
  const [comments, setComments] = useState<Comment[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchComments = async () => {
      setLoading(true)
      try {
        const response = await getComments(filter === 'all' ? undefined : filter)
        const backendComments = response.content || []
        
        const mappedComments: Comment[] = await Promise.all(
          backendComments.map(async (com: any) => {
            let reportsCount = 0;
            try {
              const reports = await getCommentReports(com.id);
              reportsCount = reports?.length || 0;
            } catch (e) {
              console.error("Failed to fetch reports for comment " + com.id, e);
            }

            return {
              id: com.id,
              author: {
                id: com.author?.id || 'unknown',
                username: com.author?.username || 'unknown',
                displayName: com.author?.username || 'Unknown',
                type: 'community' as UserType, // default
                verified: false,
                followersCount: 0,
                joinedAt: com.author?.createdAt || new Date().toISOString(),
                status: com.author?.accountStatus?.toLowerCase() || 'active',
                email: com.author?.email || '',
                reportsCount: 0
              },
              postId: com.publication?.id || 'unknown',
              postPreview: com.publication?.content ? com.publication.content.substring(0, 50) + '...' : 'Publicación desconocida',
              content: com.content,
              likesCount: com.likes || 0,
              reportsCount: reportsCount,
              status: com.moderationStatus?.toLowerCase() || 'pending',
              createdAt: com.createdAt
            };
          })
        );
        
        setComments(mappedComments)
      } catch (err) {
        console.error("Error fetching comments:", err)
      } finally {
        setLoading(false)
      }
    }

    fetchComments()
  }, [filter])

  const handleModerate = async (id: string, newStatus: ModerationStatus) => {
    try {
      await moderateComment(id, newStatus.toUpperCase() as 'APPROVED' | 'REJECTED')
      setComments(prev => prev.map(c => c.id === id ? { ...c, status: newStatus } : c))
    } catch (err) {
      console.error("Failed to moderate comment", err)
      alert("Error al moderar comentario")
    }
  }

  const sortedComments = [...comments].sort((a, b) => {
    if (sort === 'reports') return b.reportsCount - a.reportsCount
    return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  })

  const pendingCount = comments.filter(c => c.status === 'pending').length

  return (
    <div className={pageStyles.page}>
      {pendingCount > 0 && (
        <div className={`${pageStyles.banner} ${pageStyles.bannerPending}`}>
          <span className={pageStyles.bannerIcon}>⚠️</span>
          <div className={pageStyles.bannerText}>
            <span className={pageStyles.bannerCount}>{pendingCount} comentarios</span> pendientes de moderación
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

      {loading ? (
        <div className={pageStyles.empty}>
          <div className={pageStyles.emptyTitle}>Cargando comentarios...</div>
        </div>
      ) : sortedComments.length === 0 ? (
        <div className={pageStyles.empty}>
          <div className={pageStyles.emptyIcon}>💬</div>
          <div className={pageStyles.emptyTitle}>Sin comentarios</div>
          <div className={pageStyles.emptyText}>No hay comentarios con este filtro.</div>
        </div>
      ) : (
        <div className={pageStyles.grid}>
          {sortedComments.map((comment, i) => <CommentCard key={comment.id} comment={comment} animDelay={i * 60} onModerate={handleModerate} />)}
        </div>
      )}
    </div>
  )
}