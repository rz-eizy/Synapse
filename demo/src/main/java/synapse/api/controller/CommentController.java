package synapse.api.controller;

import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import synapse.api.model.Comment;
import synapse.api.security.CustomUserDetails;
import synapse.api.service.CommentService;
import org.springframework.web.bind.annotation.PostMapping;


@RestController
@RequestMapping("/api/comment")
public class CommentController {
    private final CommentService commentService;

    public CommentController(CommentService commentService){
        this.commentService = commentService;
    }

    @PostMapping("/{idPublication}")
    public ResponseEntity<Comment> postNewComment(
        @PathVariable Long idPublication,
        @RequestParam(required = true) String content,
        @AuthenticationPrincipal CustomUserDetails principal
    ) {
        Long authorId = principal.getId();
        if (authorId == null) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        } 
        Comment comment = commentService.addComment(idPublication, authorId, content);
        return new ResponseEntity<>(comment, HttpStatus.CREATED);
    }
    

    @GetMapping("/{idPublication}")
    public ResponseEntity<Page <Comment>> getComments(
        @PathVariable Long idPublication,
        @RequestParam(value = "page", defaultValue = "0") int page,
        @RequestParam(value = "size", defaultValue = "20") int size 
    ) {
        if (idPublication == null) return new ResponseEntity<>(HttpStatus.BAD_REQUEST); 
        Page<Comment> comments = commentService.findPublicationComents(idPublication, page, size);
        return ResponseEntity.ok(comments);
    }
}
