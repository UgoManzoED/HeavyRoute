package com.heavyroute.common.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;

/**
 * Gestore centralizzato delle eccezioni per l'applicazione.
 * <p>
 * Intercetta le eccezioni lanciate dai Controller e le converte in risposte HTTP
 * strutturate secondo lo standard RFC 7807 (Problem Details), introdotto in Spring Boot 3.
 * Evita di esporre stack trace o pagine di errore HTML ai client API.
 */

@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Gestisce il caso in cui una risorsa richiesta non viene trovata.
     * <p>
     * Esempio: Ricerca di un ID utente inesistente.
     * Trasforma l'eccezione in un 404 Not Found con dettagli JSON.
     *
     * @param ex L'eccezione catturata contenente il messaggio di errore specifico.
     * @return Un oggetto {@link ProblemDetail} che verrà serializzato in JSON.
     */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ProblemDetail handleNotFound(ResourceNotFoundException ex) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
        problem.setTitle("Risorsa non trovata");
        problem.setProperty("timestamp", Instant.now());
        return problem;
    }



}