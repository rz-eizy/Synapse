package synapse.api.service.external;

import java.time.Duration;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;

@Service
public class CloudflareR2Service {
    
    private final S3Presigner s3Presigner;

    @Value("${cloudflare.r2.bucket-name}")
    private String bucketName;

    @Value("${cloudflare.r2.public-url}")
    private String publicUrl;

    public CloudflareR2Service(S3Presigner s3Presigner) {
        this.s3Presigner = s3Presigner;
    }

    public Map<String, String> generatePresignedUploadUrl(String contentType) {
        String fileName = UUID.randomUUID().toString() + ".jpg";

        PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(fileName)
                    .contentType(contentType)
                    .build();
        
        PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                .signatureDuration(Duration.ofMinutes(5))
                .putObjectRequest(putObjectRequest)
                .build();

        PresignedPutObjectRequest request = s3Presigner.presignPutObject(presignRequest);
        return java.util.Map.of(
            "uploadUrl", request.url().toString(),
            "publicUrl", publicUrl + "/" + fileName
        );
    }
}