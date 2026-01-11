package com.heavyroute.auth.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.heavyroute.users.dto.CustomerRegistrationDTO;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Test di Integrazione per i flussi di registrazione.
 * <p>
 * Carica l'intero contesto dell'applicazione (Database, Security, Bean) e simula
 * chiamate HTTP verso i controller per verificare che l'intera catena risponda correttamente.
 * </p>
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class AuthControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * Scenario Negativo: Input non valido.
     * Verifica che il backend risponda 400 e con la struttura JSON corretta (RFC 7807 + errors map).
     */
    @Test
    @DisplayName("Should return 400 and ProblemDetail when Customer input is invalid (Validation Check)")
    void whenRegisterInvalidCustomer_thenReturns400AndErrorMap() throws Exception {
        // 1. Arrange: DTO invalido
        CustomerRegistrationDTO invalidDto = new CustomerRegistrationDTO();
        invalidDto.setEmail("email-non-valida");
        invalidDto.setPassword("short"); // < 8 char
        invalidDto.setUsername("usr"); // < 4 char

        // 2. Act & Assert
        mockMvc.perform(post("/api/auth/register/customer")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidDto)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.title").value("Errore di Validazione"))

                .andExpect(jsonPath("$.errors.email").exists())
                .andExpect(jsonPath("$.errors.password").exists())
                .andExpect(jsonPath("$.errors.vatNumber").exists())
                .andExpect(jsonPath("$.errors.pec").exists());
    }

    /**
     * Scenario Positivo: Registrazione OK.
     * Verifica che i dati corretti vengano salvati e il server risponda 201.
     */
    @Test
    @DisplayName("Should return 201 Created when Customer registration is valid")
    void whenRegisterValidCustomer_thenReturnsSuccess() throws Exception {
        // 1. Arrange
        CustomerRegistrationDTO validDto = new CustomerRegistrationDTO();
        validDto.setUsername("mario.trasporti");
        validDto.setPassword("PasswordSicura123!"); // > 8 char
        validDto.setEmail("info@mariotrasporti.it"); // Email valida
        validDto.setFirstName("Mario");
        validDto.setLastName("Rossi");
        validDto.setCompanyName("Mario Trasporti S.R.L.");
        validDto.setVatNumber("12345678901"); // 11 cifre (valido)
        validDto.setPec("mario.trasporti@pec.it");
        validDto.setPhoneNumber("+393331234567");
        validDto.setAddress("Via Roma 1, Milano");

        // 2. Act & Assert
        mockMvc.perform(post("/api/auth/register/customer")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(validDto)))
                .andExpect(status().isCreated()); // 201 Created
    }
}