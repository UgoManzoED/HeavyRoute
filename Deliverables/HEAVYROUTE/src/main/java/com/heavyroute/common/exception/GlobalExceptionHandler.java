package com.heavyroute.common.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.net.URI;
import java.time.Instant;

/**
 * Gestore centralizzato delle eccezioni per l'applicazione.
 * <p>
 * Intercetta le eccezioni lanciate dai Controller e le converte in risposte HTTP
 * strutturate secondo lo standard RFC 7807 (Problem Details), introdotto in Spring Boot 3.
 * Evita di esporre stack trace o pagine di errore HTML ai client API.
 *
 * @see org.springframework.http.ProblemDetail
 */

@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Gestisce i casi di risorse inesistenti.
     * <p>
     * Intercetta {@link ResourceNotFoundException} quando viene richiesto un identificativo
     * (es. ID utente, codice ordine) non presente nel database.
     * <p>
     * <strong>Risposta HTTP:</strong> 404 Not Found
     *
     * @param ex L'eccezione catturata contenente il messaggio specifico (es. "Utente 123 non trovato").
     * @return Un oggetto {@link ProblemDetail} con type "not-found".
     */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ProblemDetail handleNotFound(ResourceNotFoundException ex) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
        problem.setTitle("Risorsa non trovata");
        problem.setType(URI.create("https://heavyroute.com/errors/not-found"));
        problem.setProperty("timestamp", Instant.now());
        return problem;
    }

    /**
     * Gestisce le violazioni delle regole di business.
     * <p>
     * Intercetta {@link BusinessRuleException} quando un'operazione è tecnicamente valida
     * ma non permessa dallo stato attuale del sistema.
     * <p>
     * <strong>Risposta HTTP:</strong> 409 Conflict
     *
     * @param ex L'eccezione catturata con la descrizione della regola violata.
     * @return Un oggetto {@link ProblemDetail} con type "conflict".
     */
    @ExceptionHandler(BusinessRuleException.class)
    public ProblemDetail handleBusinessRule(BusinessRuleException ex) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.CONFLICT, ex.getMessage());
        problem.setTitle("Violazione Regola di Business");
        problem.setType(URI.create("https://heavyroute.com/errors/conflict"));
        problem.setProperty("timestamp", Instant.now());
        return problem;
    }
}