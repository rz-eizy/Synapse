package synapse.api.config;

import com.google.api.gax.core.FixedCredentialsProvider;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.vision.v1.ImageAnnotatorClient;
import com.google.cloud.vision.v1.ImageAnnotatorSettings;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;

import java.io.IOException;

@Configuration
public class VisionConfig {
    @Value("${gcp.credentials.path}")
    private Resource credentialsResource;

    @Bean(destroyMethod = "close") 
    public ImageAnnotatorClient imageAnnotatorClient() throws IOException {
        GoogleCredentials credentials = GoogleCredentials
                .fromStream(credentialsResource.getInputStream())
                .createScoped(ImageAnnotatorSettings.getDefaultServiceScopes());

        ImageAnnotatorSettings settings = ImageAnnotatorSettings.newBuilder()
                .setCredentialsProvider(FixedCredentialsProvider.create(credentials))
                .build();

        return ImageAnnotatorClient.create(settings);
    }
}