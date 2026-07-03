package synapse.api.controller.admin;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import synapse.api.service.admin.AdminContentModerationService;
import synapse.api.security.JwtUtils;
import synapse.api.security.UserDetailsServiceImpl;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = AdminContentModerationController.class)
@AutoConfigureMockMvc(addFilters = false)
class AdminContentModerationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private AdminContentModerationService service;

    @MockitoBean
    private JwtUtils jwtUtils;

    @MockitoBean
    private UserDetailsServiceImpl userDetailsService;

    @Test
    void testGetReportedContent() throws Exception {
        mockMvc.perform(get("/api/admin/posts")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }
}
