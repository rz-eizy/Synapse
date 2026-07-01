package synapse.api.config;

import com.google.cloud.vision.v1.Likelihood;
import jakarta.annotation.PostConstruct;
import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Getter
@Setter
@Component
@ConfigurationProperties(prefix = "safesearch")
public class SafeSearchProperties {
    private String approveBelow = "POSSIBLE";
    private String rejectFrom = "LIKELY";

    @PostConstruct
    public void validate() {
        try {
            Likelihood.valueOf(approveBelow);
            Likelihood.valueOf(rejectFrom);
        } catch (IllegalArgumentException e) {
            throw new IllegalStateException(
                "Configuración inválida de SafeSearch: los valores deben ser uno de " +
                "[VERY_UNLIKELY, UNLIKELY, POSSIBLE, LIKELY, VERY_LIKELY]. Causa: " + e.getMessage()
            );
        }
    }
}