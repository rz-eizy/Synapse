import { useEffect, useState } from 'react';
import { login } from '../services/api';
import styles from '../styles/pages/LoginPage.module.css';

// ── 🧪 MODO TEST — pon esto en true para saltarte el login automáticamente ──
// Recuerda volver a dejarlo en false antes de hacer commit / desplegar.
const SKIP_LOGIN_FOR_TESTING = false;

interface LoginPageProps {
  onLoginSuccess: () => void;
}

export function LoginPage({ onLoginSuccess }: LoginPageProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  // Si el flag está activo, entra directo sin pasar por el backend
  useEffect(() => {
    if (SKIP_LOGIN_FOR_TESTING) {
      onLoginSuccess();
    }
  }, [onLoginSuccess]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await login(email, password);
      onLoginSuccess();
    } catch (err: any) {
      setError(err.message || 'Error al iniciar sesión');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.page}>
      <div className={styles.card}>
        <h1 className={styles.title}>Synapse Admin</h1>
        <p className={styles.subtitle}>Ingresa tus credenciales para acceder</p>

        {error && <div className={styles.error}>{error}</div>}

        <form onSubmit={handleSubmit}>
          <div className={styles.formGroup}>
            <label className={styles.label} htmlFor="email">Correo electrónico</label>
            <input
              id="email"
              type="email"
              className={styles.input}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              disabled={loading}
            />
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label} htmlFor="password">Contraseña</label>
            <input
              id="password"
              type="password"
              className={styles.input}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              disabled={loading}
            />
          </div>

          <button type="submit" className={styles.button} disabled={loading}>
            {loading ? 'Iniciando...' : 'Iniciar Sesión'}
          </button>
        </form>

        {/* 🧪 Botón visible solo para testing manual, sin pasar por el backend */}
        <button
          type="button"
          onClick={onLoginSuccess}
          style={{
            marginTop: '12px',
            width: '100%',
            background: 'transparent',
            border: 'none',
            color: '#9CA3AF',
            fontSize: '12px',
            cursor: 'pointer',
            textDecoration: 'underline'
          }}
        >
          Saltar login (solo testing frontend)
        </button>
      </div>
    </div>
  );
}