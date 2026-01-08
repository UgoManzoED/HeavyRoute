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

    /**
     * Gestisce i tentativi di violazione dei vincoli di univocità (Unique Constraints).
     * <p>
     * Intercetta {@link UserAlreadyExistException} quando un utente tenta di registrarsi
     * con un'email o uno username già presenti nel sistema.
     * </p>
     * <p>
     * <strong>Risposta HTTP:</strong> 409 Conflict
     * <br>
     * Viene preferito il 409 al 400 (Bad Request) perché la richiesta è sintatticamente corretta,
     * ma confligge con lo stato attuale della risorsa sul server.
     * </p>
     *
     * @param ex L'eccezione contenente il dettaglio del campo duplicato (es. "Email già in uso").
     * @return Un {@link ProblemDetail} standard RFC 7807 che invita il client a usare credenziali diverse.
     */
    @ExceptionHandler(UserAlreadyExistException.class)
    public ProblemDetail handleUserAlreadyExist(UserAlreadyExistException ex) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.CONFLICT, ex.getMessage());
        problem.setTitle("Utente già esistente");
        problem.setType(URI.create("https://heavyroute.com/errors/user-duplicate"));
        problem.setProperty("timestamp", Instant.now());
        return problem;
    }

    /**
     * Gestisce i fallimenti nelle procedure di autenticazione (Login).
     * <p>
     * Intercetta {@link BadCredentialsException}
     * quando username e password non corrispondono.
     * </p>
     * <p>
     * <strong>Nota di Sicurezza:</strong> La risposta restituisce un messaggio generico
     * ("Credenziali non valide") senza specificare se a essere errato è l'username o la password.
     * Questo approccio ("Security through obscurity" parziale) serve a prevenire
     * <b>Attacchi di Enumerazione</b>, impedendo a un attaccante di verificare quali email
     * sono registrate nel sistema.
     * </p>
     * <p>
     * <strong>Risposta HTTP:</strong> 401 Unauthorized
     * </p>
     *
     * @param ex L'eccezione di sicurezza.
     * @return Un {@link ProblemDetail} che segnala il fallimento dell'autenticazione.
     */
    @ExceptionHandler(BadCredentialsException.class)
    public ProblemDetail handleBadCredentials(BadCredentialsException ex) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.UNAUTHORIZED, ex.getMessage());
        problem.setTitle("Credenziali non valide");
        problem.setType(URI.create("https://heavyroute.com/errors/unauthorized"));
        problem.setProperty("timestamp", Instant.now());
        return problem;
    }
}