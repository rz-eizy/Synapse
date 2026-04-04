import styles from './LoginPage.module.css';
import logo from '../../../public/images/logo_synapse.png';

export const LoginPage = () => {
    return (
        <div className={styles.container}>
            <div className={styles.logoGlow} />

            <img src={logo} alt="logo" className={styles.backgroundLogo} />

            {/* card de inicio de sesion */}
            <div className={styles.card}>

                <div className={styles.cardHeader}>
                    <h2>Iniciar Sesión</h2>
                    <span className={styles.cardSubtitle}>Bienvenido de vuelta</span>
                </div>

                <div className={styles.divider} />

                <form className={styles.form}>
                    <div className={styles.inputWrapper}>
                        <span className={styles.inputIcon}>✉</span>
                        <input type='email' placeholder='Correo Electrónico' />
                    </div>

                    <div className={styles.inputWrapper}>
                        <span className={styles.inputIcon}>🔒</span>
                        <input type='password' placeholder='Contraseña' />
                    </div>

                    <div className={styles.buttonWrapper}>
                        <button type='submit'>Ingresar</button>
                    </div>
                </form>

                <span className={styles.forgot}>¿Olvidaste tu contraseña?</span>
            </div>
        </div>
    );
};