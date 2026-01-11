package com.heavyroute.common.exception;

import org.springframework.http.*;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;
import org.springframework.dao.DataIntegrityViolationException;

import java.net.URI;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

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
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    /**
     * Gestisce i fallimenti della validazione dei DTO (@Valid).
     * <p>
     * Questo metodo viene invocato automaticamente da Spring quando i dati in ingresso al Controller
     * non rispettano le annotazioni di validazione (es. @NotNull, @Size).
     * </p>
     *
     * @return Risposta 400 Bad Request arricchita con la lista dettagliata degli errori per campo.
     */
    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            MethodArgumentNotValidException ex,
            HttpHeaders headers,
            HttpStatusCode status,
            WebRequest request) {

        // 1. Creazione dello scheletro della risposta standard (RFC 7807)
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, "Dati di input non validi");
        problem.setTitle("Errore di Validazione");
        problem.setType(URI.create("https://heavyroute.com/errors/validation"));
        problem.setProperty("timestamp", Instant.now());

        // 2. Estrazione e Mappatura degli Errori
        Map<String, String> errors = new HashMap<>();
        for (FieldError error : ex.getBindingResult().getFieldErrors()) {
            // Mappa: nomeCampo -> messaggioErrore
            errors.put(error.getField(), error.getDefaultMessage());
        }

        // 3. Arricchimento del JSON finale
        problem.setProperty("errors", errors);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(problem);
    }

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

    /**
     * Gestisce gli errori di vincolo del Database (SQL Constraints).
     * <p>
     * Esempi tipici: Chiavi duplicate (Unique Index) o violazioni di chiavi esterne.
     * Trasforma un errore tecnico (500) in un errore semantico (409 Conflict).
     * </p>
     *
     * @param ex L'eccezione lanciata da Hibernate/JDBC.
     * @return Un oggetto {@link ProblemDetail} conforme allo standard RFC 7807.
     */
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ProblemDetail> handleDatabaseConstraint(DataIntegrityViolationException ex) {
        // Recuperiamo il messaggio originale del driver DB
        String rootMsg = ex.getMostSpecificCause().getMessage();

        HttpStatus status = HttpStatus.CONFLICT;
        String userMessage = "Errore di integrità dei dati nel database.";
        String title = "Conflitto Dati";

        // CASO A: Dato troppo lungo
        if (rootMsg != null && rootMsg.contains("Data too long")) {
            status = HttpStatus.BAD_REQUEST;
            title = "Dati non validi (Lunghezza)";
            userMessage = "Uno dei campi inseriti supera la lunghezza massima consentita dal database.";

            if (rootMsg.contains("vat_number")) userMessage = "La Partita IVA inserita è troppo lunga.";
        }
        // CASO B: Dato duplicato
        else if (rootMsg != null && rootMsg.contains("Duplicate entry")) {
            status = HttpStatus.CONFLICT;
            title = "Dato Duplicato";

            if (rootMsg.contains("vat_number")) userMessage = "La Partita IVA specificata è già presente.";
            else if (rootMsg.contains("pec")) userMessage = "La PEC specificata è già presente.";
            else if (rootMsg.contains("username")) userMessage = "Lo username è già in uso.";
            else if (rootMsg.contains("email")) userMessage = "L'email è già registrata.";
        }

        ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, userMessage);
        problem.setTitle(title);
        problem.setType(URI.create("https://heavyroute.com/errors/database-constraint"));
        problem.setProperty("timestamp", Instant.now());
        problem.setProperty("debug_message", rootMsg);

        return ResponseEntity.status(status).body(problem);
    }
}