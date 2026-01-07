package com.heavyroute.common.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Configurazione globale per il Cross-Origin Resource Sharing (CORS).
 * <p>
 * Questa classe gestisce i permessi di accesso alle API da parte di applicazioni web
 * ospitate su domini o porte differenti.
 * </p>
 */
@Configuration
public class CorsConfig {

    /**
     * Definisce le regole CORS globali per l'applicazione MVC.
     * * @return Un configuratore WebMvc che sovrascrive i mapping CORS di default.
     */
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**") // Abilita su tutte le rotte
                        .allowedOrigins("*") // Permetti a chiunque (per sviluppo)
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS");
            }
        };
    }
}