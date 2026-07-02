package synapse.api.scheduler;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import synapse.api.repository.UserRepository;

@Component
public class UserCleanupScheduler {

    private final UserRepository userRepository;

    public UserCleanupScheduler(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Scheduled(cron = "0 0 3 * * ?", zone = "America/Santiago")
    @Transactional
    public void cleanupDeletedUsers() {
        System.out.println("Starting cleanup of soft-deleted users...");
        int batchSize = 100;
        int deletedCount;
        int totalDeleted = 0;

        do {
            deletedCount = userRepository.hardDeleteDeletedUsersBatch(batchSize);
            totalDeleted += deletedCount;
        } while (deletedCount == batchSize);

        System.out.println("Finished cleanup. Total permanently deleted users: " + totalDeleted);
    }
}
