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
 * Filtro "Gatekeeper" per l'autenticazione Stateless via JWT.
 * <p>
 * <b>Ruolo Architetturale:</b> Intercetta ogni richiesta HTTP in ingresso prima che raggiunga i Controller.
 * <p>
 * <b>Funzionamento:</b>
 * <ol>
 * <li>Cerca l'header {@code Authorization}.</li>
 * <li>Verifica la validità crittografica del Token (firma e scadenza).</li>
 * <li>Verifica l'esistenza dell'utente nel Database (Allineamento Stato).</li>
 * <li>Se tutto è OK, inietta l'identità nel {@link SecurityContextHolder}.</li>
 * </ol>
 * </p>
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtils jwtUtils;
    private final UserDetailsServiceImpl userDetailsService;

    /**
     * Logica core del filtro.
     *
     * @param request La richiesta HTTP in arrivo.
     * @param response La risposta HTTP in uscita.
     * @param filterChain La catena dei filtri successivi (passa la palla al prossimo controllo).
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        try {
            // 1. Estrazione del Token dall'Header
            String jwt = parseJwt(request);

            // 2. Validazione Crittografica (Stateless)
            if (jwt != null && jwtUtils.validateJwtToken(jwt)) {
                String username = jwtUtils.getUserNameFromJwtToken(jwt);

                // 3. Validazione di Stato (Stateful Check) e Fail-Safe
                try {
                    // Proviamo a caricare l'utente dal DB aggiornato.
                    UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                    // Se l'utente esiste, creiamo il token di autenticazione interno di Spring
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(
                                    userDetails,
                                    null,
                                    userDetails.getAuthorities());

                    // Aggiungiamo metadati della richiesta
                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                    // AUTENTICAZIONE RIUSCITA
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                } catch (Exception e) {
                    // GESTIONE "ZOMBIE TOKEN" (Token valido, Utente inesistente)
                    // LOGGARE ma NON ROMPERE la richiesta.
                    logger.warn("Token valido ma utente non trovato nel DB (DB Resettato?): " + e.getMessage());
                }
            }
        } catch (Exception e) {
            logger.error("Impossibile impostare l'autenticazione utente: {}", e);
        }

        // 4. Propagazione
        filterChain.doFilter(request, response);
    }

    /**
     * Helper per estrarre il token pulito dall'header HTTP Authorization.
     * Ritorna null se l'header manca o non inizia con "Bearer ".
     */
    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");
        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }
        return null;
    }
}