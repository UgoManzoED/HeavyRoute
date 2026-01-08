package com.heavyroute.auth.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

/**
 * Componente responsabile delle operazioni crittografiche sui token JWT.
 * <p>
 * Gestisce il ciclo di vita tecnico del token: creazione (firma), parsing (lettura)
 * e validazione della firma digitale.
 * </p>
 */
@Component
public class JwtUtils {

    // ATTENZIONE: In produzione, questa chiave NON deve essere hardcodata qui.
    private static final String JWT_SECRET = "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970";
    private static final int JWT_EXPIRATION_MS = 86400000;

    /**
     * Genera un nuovo JWT per un utente autenticato.
     * * @param authentication L'oggetto di Spring Security contenente i dettagli dell'utente loggato.
     * @return Una stringa codificata in Base64 (il token vero e proprio: Header.Payload.Signature).
     */
    public String generateJwtToken(Authentication authentication) {
        UserDetails userPrincipal = (UserDetails) authentication.getPrincipal();

        return Jwts.builder()
                .setSubject((userPrincipal.getUsername()))
                .setIssuedAt(new Date())
                .setExpiration(new Date((new Date()).getTime() + JWT_EXPIRATION_MS))
                .signWith(key(), SignatureAlgorithm.HS256)
                .compact();
    }

    private Key key() {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(JWT_SECRET));
    }

    /**
     * Estrae lo username dal token.
     * Serve al filtro per capire "chi" sta facendo la richiesta.
     */
    public String getUserNameFromJwtToken(String token) {
        return Jwts.parserBuilder().setSigningKey(key()).build()
                .parseClaimsJws(token).getBody().getSubject();
    }

    /**
     * Verifica se il token è valido.
     * Controlla:
     * 1. La firma (il token non è stato manomesso).
     * 2. La scadenza (il token non è expired).
     * 3. La formattazione (il token non è corrotto).
     */
    public boolean validateJwtToken(String authToken) {
        try {
            Jwts.parserBuilder().setSigningKey(key()).build().parseClaimsJws(authToken);
            return true;
        } catch (JwtException e) {
            System.err.println("Invalid JWT token: " + e.getMessage());
        }
        return false;
    }
}