package com.heavyroute.auth.security;

import com.heavyroute.auth.service.impl.UserDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Configurazione centrale della sicurezza (Spring Security 6+).
 * <p>
 * Definisce la catena dei filtri (SecurityFilterChain), la politica delle sessioni (Stateless)
 * e le regole di accesso agli endpoint (Authorization).
 * </p>
 */
@Configuration
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final UserDetailsServiceImpl userDetailsService;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    /**
     * Configura il Provider di Autenticazione.
     * Spring userà questo bean per capire come recuperare gli utenti (dal DB)
     * e come verificare le password (usando BCrypt).
     */
    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    /**
     * Espone l'AuthenticationManager come Bean riutilizzabile.
     * Sarà iniettato nel 'AuthController' per eseguire il login manuale (username + password)
     * e generare il primo token.
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    /**
     * Definisce l'algoritmo di hashing.
     * BCrypt è lento intenzionalmente per rendere costosi gli attacchi Brute-Force.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Definisce la Security Filter Chain: l'elenco ordinato di regole e filtri.
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable()) // 1. Disabilitazione CSRF
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth // 3. Regole di Autorizzazione
                        .requestMatchers("/api/auth/**").permitAll() // Login è pubblico
                        .requestMatchers("/api/users/register/**").permitAll() // Registrazione pubblica
                        .anyRequest().authenticated() // Tutto il resto richiede token
                );

        http.authenticationProvider(authenticationProvider());
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}