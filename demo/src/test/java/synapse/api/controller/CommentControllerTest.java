package synapse.api.controller;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import synapse.api.model.Comment;
import synapse.api.service.CommentService;
import synapse.api.security.JwtUtils;
import synapse.api.security.UserDetailsServiceImpl;

import java.util.List;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;

@WebMvcTest(controllers = CommentController.class)
@AutoConfigureMockMvc(addFilters = false)
class CommentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private CommentService commentService;

    @MockitoBean
    private JwtUtils jwtUtils;

    @MockitoBean
    private UserDetailsServiceImpl userDetailsService;

    @Test
    void getComments_ReturnsOk() throws Exception {
        UUID pubId = UUID.randomUUID();
        Comment comment = new Comment();
        comment.setId(UUID.randomUUID());
        comment.setContent("Test comment");

        Mockito.when(commentService.findPublicationComents(Mockito.eq(pubId), Mockito.anyInt(), Mockito.anyInt()))
               .thenReturn(new PageImpl<>(List.of(comment), PageRequest.of(0, 20), 1));

        mockMvc.perform(get("/api/comment/" + pubId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].content").value("Test comment"));
    }
}
