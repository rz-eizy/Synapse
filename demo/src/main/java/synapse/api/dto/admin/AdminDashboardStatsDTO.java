package synapse.api.dto.admin;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class AdminDashboardStatsDTO {
    private long pendingPosts;
    private long pendingComments;
    private long pendingAccounts;
    private long resolvedToday;
    private long totalReports;
    private double approvalRate;
}