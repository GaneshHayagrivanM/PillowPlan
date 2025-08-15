package com.monthlytracker.auth;

import com.monthlytracker.security.JwtService;
import com.monthlytracker.user.UserEntity;
import com.monthlytracker.user.UserRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.time.Duration;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final UserRepository users;
    private final PasswordEncoder encoder;
    private final JwtService jwtService;

    public AuthController(UserRepository users, PasswordEncoder encoder, JwtService jwtService) {
        this.users = users; this.encoder = encoder; this.jwtService = jwtService;
    }

    public record RegisterRequest(@Email String email, @NotBlank String password, @NotBlank String timezone) {}
    public record LoginRequest(@Email String email, @NotBlank String password) {}

    @GetMapping("/ping")
    public Map<String, String> ping() {
        return Map.of("status", "ok");
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest req) {
        if (users.findByEmail(req.email()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("error", "email_taken"));
        }
        UserEntity u = new UserEntity();
        u.setEmail(req.email());
        u.setPasswordHash(encoder.encode(req.password()));
        u.setTimezone(req.timezone());
        UserEntity saved = users.save(u);
        return ResponseEntity.created(URI.create("/api/users/me")).body(Map.of("id", saved.getId()));
    }

    @PostMapping("/signin")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest req) {
        return users.findByEmail(req.email())
                .filter(u -> encoder.matches(req.password(), u.getPasswordHash()))
                .map(u -> {
                    String access = jwtService.createAccessToken(u.getId(), u.getEmail());
                    String refresh = jwtService.createRefreshToken(u.getId(), u.getEmail());
                    ResponseCookie cookie = ResponseCookie.from("refresh_token", refresh)
                            .httpOnly(true).secure(false).sameSite("Lax")
                            .maxAge(Duration.ofDays(7)).path("/").build();
                    return ResponseEntity.ok()
                            .header("Set-Cookie", cookie.toString())
                            .body(Map.of("access_token", access));
                })
                .orElseGet(() -> ResponseEntity.status(401).body(Map.of("error", "invalid_credentials")));
    }
}
