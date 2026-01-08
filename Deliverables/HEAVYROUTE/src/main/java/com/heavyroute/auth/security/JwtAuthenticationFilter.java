package com.heavyroute.auth.security;

import com.heavyroute.auth.service.impl.UserDetailsServiceImpl;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Filtro di sicurezza personalizzato che intercetta ogni singola richiesta HTTP.
 * <p>
 * Estende {@link OncePerRequestFilter} per garantire un'unica esecuzione per request
 * (evitando duplicazioni in caso di forward/include interni).
 * Il suo scopo è validare il Token JWT e, se valido, registrare l'utente nel contesto di sicurezza.
 * </p>
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtils jwtUtils;
    private final UserDetailsServiceImpl userDetailsService;

    /**
     * Logica principale del filtro.
     *
     * @param request La richiesta HTTP in arrivo.
     * @param response La risposta HTTP in uscita.
     * @param filterChain La catena dei filtri successivi (passa la palla al prossimo controllo).
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        try {
            // 1. Estrae il token dall'header
            String jwt = parseJwt(request);

            // 2. Se c'è un token ed è crittograficamente valido
            if (jwt != null && jwtUtils.validateJwtToken(jwt)) {
                // 3. Estrae lo username
                String username = jwtUtils.getUserNameFromJwtToken(jwt);

                // 4. Carica i dettagli completi dal DB
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                // 5. Crea l'oggetto di Autenticazione
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                userDetails,
                                null,
                                userDetails.getAuthorities());

                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                // 6. Imposta l'utente nel SecurityContext
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            logger.error("Impossibile impostare l'autenticazione utente: {}", e);
        }

        // 7. Passa al prossimo filtro
        filterChain.doFilter(request, response);
    }

    /**
     * Helper per estrarre il token pulito dall'header HTTP.
     */
    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");
        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }
        return null;
    }
}