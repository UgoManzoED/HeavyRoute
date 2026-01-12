package com.heavyroute.core.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.heavyroute.auth.security.JwtUtils;
import com.heavyroute.auth.service.impl.UserDetailsServiceImpl;
import com.heavyroute.core.dto.RequestCreationDTO;
import com.heavyroute.core.service.TransportRequestService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(TransportRequestController.class)
class TransportRequestControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private TransportRequestService requestService;

    @MockitoBean
    private JwtUtils jwtUtils;

    @MockitoBean
    private UserDetailsServiceImpl userDetailsService;

    @MockitoBean
    private org.springframework.data.jpa.mapping.JpaMetamodelMappingContext jpaMappingContext;

    @Test
    @WithMockUser(roles = "CUSTOMER")
    @DisplayName("TC-CORE-01: Creazione Richiesta - Dati Validi (Status 201)")
    void createRequest_ShouldReturn201() throws Exception {
        RequestCreationDTO dto = new RequestCreationDTO();
        dto.setOriginAddress("Napoli, Via Roma 1");
        dto.setDestinationAddress("Roma, Via Tiburtina 10");
        dto.setWeight(1500.0);
        dto.setPickupDate(LocalDate.now().plusDays(30));
        dto.setLoadType("Carico Industriale");
        dto.setHeight(2.5);
        dto.setLength(6.0);
        dto.setWidth(2.4);

        mockMvc.perform(post("/api/requests")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated());
    }

    @Test
    @WithMockUser(roles = "CUSTOMER")
    @DisplayName("TC-CORE-02.A: Validazione Input - Rifiuto Peso Negativo (Status 400)")
    void createRequest_NegativeWeight_Returns400() throws Exception {
        RequestCreationDTO dto = new RequestCreationDTO();
        dto.setOriginAddress("Napoli");
        dto.setDestinationAddress("Roma");
        dto.setWeight(-50.0); // Scelta [error] dal LaTeX
        dto.setPickupDate(LocalDate.now().plusDays(10));

        mockMvc.perform(post("/api/requests")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @WithMockUser(roles = "CUSTOMER")
    @DisplayName("TC-CORE-02.B: Validazione Input - Rifiuto Data Passata (Status 400)")
    void createRequest_PastDate_Returns400() throws Exception {
        RequestCreationDTO dto = new RequestCreationDTO();
        dto.setOriginAddress("Napoli");
        dto.setDestinationAddress("Roma");
        dto.setWeight(100.0);
        dto.setPickupDate(LocalDate.now().minusDays(5));

        mockMvc.perform(post("/api/requests")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isBadRequest());
    }
}