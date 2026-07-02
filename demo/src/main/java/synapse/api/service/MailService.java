package synapse.api.service;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class MailService {

    private final JavaMailSender mailSender;

    public MailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void sendPasswordResetOtp(String to, String otp) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setSubject("Código de Recuperación de Contraseña - Synapse");
            message.setText("Hola,\n\n"
                    + "Hemos recibido una solicitud para restablecer tu contraseña en Synapse.\n\n"
                    + "Tu código de recuperación es: " + otp + "\n\n"
                    + "Este código expirará en 15 minutos.\n"
                    + "Si no solicitaste este cambio, puedes ignorar este correo de forma segura.\n\n"
                    + "Saludos,\nEl equipo de Synapse.");
            
            mailSender.send(message);
        } catch (Exception e) {
            System.err.println("Error enviando correo a " + to + ": " + e.getMessage());
        }
    }
}
