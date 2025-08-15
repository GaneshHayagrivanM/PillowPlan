package com.monthlytracker.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "app")
public class AppProperties {
    private Security security = new Security();
    private Cors cors = new Cors();

    public Security getSecurity() { return security; }
    public Cors getCors() { return cors; }

    public static class Security {
        private Jwt jwt = new Jwt();
        public Jwt getJwt() { return jwt; }
        public static class Jwt {
            private String issuer;
            private int accessTokenTtlMinutes;
            private int refreshTokenTtlDays;
            private String secret;

            public String getIssuer() { return issuer; }
            public void setIssuer(String issuer) { this.issuer = issuer; }
            public int getAccessTokenTtlMinutes() { return accessTokenTtlMinutes; }
            public void setAccessTokenTtlMinutes(int accessTokenTtlMinutes) { this.accessTokenTtlMinutes = accessTokenTtlMinutes; }
            public int getRefreshTokenTtlDays() { return refreshTokenTtlDays; }
            public void setRefreshTokenTtlDays(int refreshTokenTtlDays) { this.refreshTokenTtlDays = refreshTokenTtlDays; }
            public String getSecret() { return secret; }
            public void setSecret(String secret) { this.secret = secret; }
        }
    }

    public static class Cors {
        private String allowedOrigins;
        public String getAllowedOrigins() { return allowedOrigins; }
        public void setAllowedOrigins(String allowedOrigins) { this.allowedOrigins = allowedOrigins; }
    }
}
