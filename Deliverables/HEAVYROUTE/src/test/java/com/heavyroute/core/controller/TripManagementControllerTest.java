package com.heavyroute.core.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.heavyroute.auth.security.JwtUtils;
import com.heavyroute.auth.security.SecurityConfig;
import com.heavyroute.auth.service.impl.UserDetailsServiceImpl;
import com.heavyroute.core.dto.TripAssignmentDTO;
import com.heavyroute.core.dto.TripResponseDTO;
import com.heavyroute.core.enums.TripStatus;
import com.heavyroute.core.service.TripService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(TripManagementController.class)
@Import(SecurityConfig.class)
class TripManagementControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private TripService tripService;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean private JwtUtils jwtUtils;
    @MockitoBean private UserDetailsServiceImpl userDetailsService;
    @MockitoBean private org.springframework.data.jpa.mapping.JpaMetamodelMappingContext jpaMappingContext;

    @Test
    @WithMockUser(roles = "LOGISTIC_PLANNER")
    @DisplayName("TC-CORE-03: API Approvazione - Creazione Viaggio (Status 201)")
    void approveTrip_ShouldReturn201_WhenValid() throws Exception {
        Long requestId = 1L;
        TripResponseDTO mockTrip = new TripResponseDTO();
        mockTrip.setId(100L);
        mockTrip.setStatus(TripStatus.WAITING_VALIDATION);

        when(tripService.approveRequest(requestId)).thenReturn(mockTrip);

        mockMvc.perform(post("/api/trips/{id}/approve", requestId).with(csrf()))
                .andExpect(status().isCreated()) // Nel controller abbiamo HttpStatus.CREATED
                .andExpect(jsonPath("$.id").value(100))
                .andExpect(jsonPath("$.status").value("WAITING_VALIDATION"));
    }

    @Test
    @WithMockUser(roles = "CUSTOMER") // RUOLO SBAGLIATO
    @DisplayName("TC-CORE-06: API Sicurezza - Blocco Accesso a Ruolo Non Autorizzato")
    void approveTrip_ShouldReturn403_WhenUserIsNotPlanner() throws Exception {
        mockMvc.perform(post("/api/trips/1/approve").with(csrf()))
                .andExpect(status().isForbidden()); // Oracle: 403 Forbidden
    }

    @Test
    @WithMockUser(roles = "LOGISTIC_PLANNER")
    @DisplayName("TC-CORE-02.C: API Validazione - Errore Input in Pianificazione")
    void planTrip_ShouldReturn400_WhenInputInvalid() throws Exception {
        Long tripId = 100L;
        TripAssignmentDTO invalidDto = new TripAssignmentDTO(); // Campi null/empty

        mockMvc.perform(put("/api/trips/{id}/plan", tripId)
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidDto)))
                .andExpect(status().isBadRequest());
    }
}