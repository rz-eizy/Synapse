import { useState, useEffect } from 'react'
import { PostCard } from '../components/PostCard'
import { getPosts, moderatePost, getPostReports } from '../services/api'
import type { ModerationStatus, Post, UserType } from '../types'
import pageStyles from '../styles/pages/ModCommunityPage.module.css'

type Filter = 'all' | ModerationStatus

export function ModerationProfessionals() {
  const [filter, setFilter] = useState<Filter>('pending')
  const [sort, setSort] = useState<'date' | 'reports'>('reports')
  const [posts, setPosts] = useState<Post[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchPosts = async () => {
      setLoading(true)
      try {
        const response = await getPosts(filter === 'all' ? undefined : filter)
        const backendPosts = response.content || []
        
        const professionalPosts = backendPosts.filter((pub: any) => pub.author?.role === 'PROFESSIONAL');

        const mappedPosts: Post[] = await Promise.all(
          professionalPosts.map(async (pub: any) => {
            let reportsData = [];
            try {
              const reports = await getPostReports(pub.id);
              if (reports) reportsData = reports;
            } catch (e) {
              console.error("Failed to fetch reports for post " + pub.id, e);
            }

            return {
              id: pub.id,
              author: {
                id: pub.author?.id || 'unknown',
                username: pub.author?.username || 'unknown',
                displayName: pub.author?.username || 'Unknown',
                type: 'professional' as UserType,
                verified: true,
                followersCount: 0,
                joinedAt: pub.author?.createdAt || new Date().toISOString(),
                status: pub.author?.accountStatus?.toLowerCase() || 'active',
                email: pub.author?.email || '',
                reportsCount: 0
              },
              content: pub.content,
              images: pub.imageUrl ? [{ id: pub.id, url: pub.imageUrl }] : [],
              likesCount: pub.likes,
              commentsCount: pub.commentsCount,
              reportsCount: reportsData.length,
              reports: reportsData,
              status: pub.moderationStatus?.toLowerCase() || 'pending',
              createdAt: pub.createdAt,
              tags: pub.regionTag ? [pub.regionTag] : [],
              type: 'professional' as UserType
            };
          })
        );
        
        setPosts(mappedPosts)
      } catch (err) {
        console.error("Error fetching posts:", err)
      } finally {
        setLoading(false)
      }
    }

    fetchPosts()
  }, [filter])

  const handleModerate = async (id: string, newStatus: ModerationStatus) => {
    try {
      await moderatePost(id, newStatus.toUpperCase() as 'APPROVED' | 'REJECTED')
      setPosts(prev => prev.map(p => p.id === id ? { ...p, status: newStatus } : p))
    } catch (err) {
      console.error("Failed to moderate post", err)
      alert("Error al moderar publicación")
    }
  }

  const sortedPosts = [...posts].sort((a, b) => {
    if (sort === 'reports') return b.reportsCount - a.reportsCount
    return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  })

  const pendingCount = posts.filter(p => p.status === 'pending').length

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

      {loading ? (
        <div className={pageStyles.empty}>
          <div className={pageStyles.emptyTitle}>Cargando publicaciones...</div>
        </div>
      ) : sortedPosts.length === 0 ? (
        <div className={pageStyles.empty}>
          <div className={pageStyles.emptyIcon}>🏥</div>
          <div className={pageStyles.emptyTitle}>Sin publicaciones</div>
          <div className={pageStyles.emptyText}>No hay publicaciones con este filtro.</div>
        </div>
      ) : (
        <div className={pageStyles.grid}>
          {sortedPosts.map((post, i) => <PostCard key={post.id} post={post} animDelay={i * 60} onModerate={handleModerate} />)}
        </div>
      )}
    </div>
  )
}