package synapse.api.security;


import java.util.List;
import java.util.UUID;
import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Collection;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.authority.SimpleGrantedAuthority;


import synapse.api.model.User;

public class CustomUserDetails implements UserDetails {
    private static final Clock clock = Clock.system(ZoneId.of("America/Santiago"));
    private transient User user;

    public CustomUserDetails(User user) {
        this.user = user;
    }

    // Cambiar cuando se implementen rol de usuarios
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        String rolName = switch (user.getRole().toLowerCase()) {
            case "professional" -> "PROFESSIONAL";
            case "admin" -> "ADMIN";
            default -> "USER";
        };
        return List.of(new SimpleGrantedAuthority("ROLE_" + rolName));
    }
    
    /* 
        BANNED = bloqueado permanentemente
        SUSPENDED = bloqueado hasta la fecha indicada
    */
    @Override
    public boolean isAccountNonLocked() {
        return switch (user.getAccountStatus()) {
            case BANNED -> false;
            case SUSPENDED -> user.getSuspendedUntil() == null
                    || LocalDateTime.now(clock).isAfter(user.getSuspendedUntil());
            case ACTIVE -> true;
        };
    }

    @Override
    public String getPassword() {
        return user.getPassword();
    }

    @Override
    public String getUsername() {
        // Se usa el email como nombre de usuario para autenticacion
        return user.getEmail();
    }
    public UUID getId(){
        return user.getId();
    }

    // Estos metodos pueden ser cambiados mas adelante para reflejar el status de los usuarios
    @Override
    public boolean isAccountNonExpired() { return true;}
    @Override
    public boolean isCredentialsNonExpired() { return true;}
    @Override
    public boolean isEnabled() { return true; }
}