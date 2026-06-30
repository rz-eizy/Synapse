import { useState, useEffect } from 'react'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { Layout } from './components/Layout'
import { HomePage } from './pages/Homepage'
import { ModerationComments } from './pages/ModCommentsPage'
import { ModerationCommunity } from './pages/ModCommunityPage'
import { ModerationProfessionals } from './pages/ModProfessionalPage'
import { ModerationAccounts } from './pages/ModAccount'
import { LoginPage } from './pages/LoginPage'
import { getToken } from './services/api'
import { ModerationProfessionalReports } from './pages/ModProfessionalReportsPage'

export function App() {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(!!getToken())

  useEffect(() => {
    const handleStorageChange = () => {
      setIsAuthenticated(!!getToken())
    }
    window.addEventListener('storage', handleStorageChange)
    return () => window.removeEventListener('storage', handleStorageChange)
  }, [])

  if (!isAuthenticated) {
    return <LoginPage onLoginSuccess={() => setIsAuthenticated(true)} />
  }

  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/comentarios" element={<ModerationComments />} />
          <Route path="/comunidad" element={<ModerationCommunity />} />
          <Route path="/profesionales" element={<ModerationProfessionals />} />
          <Route path='/reportesprofesionales' element={<ModerationProfessionalReports />} />
          <Route path="/cuentas" element={<ModerationAccounts />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  )
}