package synapse.api.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import synapse.api.model.User;
import java.util.Collection;
import java.util.Collections;

public class CustomUserDetails implements UserDetails {

    private transient User user;

    public CustomUserDetails(User user) {
        this.user = user;
    }

    // Cambiar cuando se implementen rol de usuarios
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.emptyList();
    }

    @Override
    public String getPassword() {
        return user.getPassword();
    }

    @Override
    public String getUsername() {
        // Se usa el email como nombre de usuario para autenticacion
        return user.getUsername();
    }

    // Estos metodos pueden ser cambiados mas adelante para reflejar el status de los usuarios
    @Override
    public boolean isAccountNonExpired() { return true;}
    @Override
    public boolean isAccountNonLocked() { return true;}
    @Override
    public boolean isCredentialsNonExpired() { return true;}
    @Override
    public boolean isEnabled() { return true;}
}