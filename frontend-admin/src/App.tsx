import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { Layout } from './components/Layout'
import { HomePage } from './pages/Homepage'
import { ModerationComments } from './pages/ModCommentsPage'
import { ModerationCommunity } from './pages/ModCommunityPage'
import { ModerationProfessionals } from './pages/ModProfessionalPage'
import { ModerationAccounts } from './pages/ModAccount'

export function App() {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/comentarios" element={<ModerationComments />} />
          <Route path="/comunidad" element={<ModerationCommunity />} />
          <Route path="/profesionales" element={<ModerationProfessionals />} />
          <Route path="/cuentas" element={<ModerationAccounts />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  )
}