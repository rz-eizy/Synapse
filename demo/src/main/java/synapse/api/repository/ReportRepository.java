package synapse.api.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import synapse.api.model.Report;

public interface ReportRepository extends JpaRepository<Report, UUID> {
    
}
