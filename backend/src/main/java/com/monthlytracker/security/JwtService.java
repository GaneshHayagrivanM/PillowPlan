package com.monthlytracker.security;

import com.monthlytracker.config.AppProperties;
import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.UUID;

@Service
public class JwtService {
    private final AppProperties props;

    public JwtService(AppProperties props) {
        this.props = props;
    }

    public String createAccessToken(Long userId, String email) {
        return createToken(userId, email, props.getSecurity().getJwt().getAccessTokenTtlMinutes(), ChronoUnit.MINUTES, "access");
    }

    public String createRefreshToken(Long userId, String email) {
        return createToken(userId, email, props.getSecurity().getJwt().getRefreshTokenTtlDays(), ChronoUnit.DAYS, "refresh");
    }

    private String createToken(Long userId, String email, int ttl, ChronoUnit unit, String scope) {
        try {
            Instant now = Instant.now();
            JWTClaimsSet claims = new JWTClaimsSet.Builder()
                    .issuer(props.getSecurity().getJwt().getIssuer())
                    .issueTime(Date.from(now))
                    .expirationTime(Date.from(now.plus(ttl, unit)))
                    .jwtID(UUID.randomUUID().toString())
                    .subject(String.valueOf(userId))
                    .claim("email", email)
                    .claim("scope", scope)
                    .build();
            JWSHeader header = new JWSHeader(JWSAlgorithm.HS256);
            SignedJWT jwt = new SignedJWT(header, claims);
            jwt.sign(new MACSigner(props.getSecurity().getJwt().getSecret().getBytes()));
            return jwt.serialize();
        } catch (Exception e) {
            throw new RuntimeException("Failed to sign JWT", e);
        }
    }
}
