package com.heavyroute.core.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.heavyroute.core.dto.PlanningDTO;
import com.heavyroute.core.dto.TripDTO;
import com.heavyroute.core.service.TripService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Test di Integrazione "Slice" per il livello Web.
 * <p>
 * Verifica che il Controller gestisca correttamente le richieste HTTP,
 * la serializzazione JSON e la validazione degli input, MOCKANDO (simulando)
 * la logica di business sottostante.
 * </p>
 */
@WebMvcTest(TripManagementController.class)
class TripManagementControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private TripService tripService;

    @Autowired
    private ObjectMapper objectMapper;

    // --- Test TC-CORE-03 ---
    @Test
    void approveTrip_ShouldReturn200_WhenValid() throws Exception {
        // ARRANGE
        Long requestId = 1L;
        TripDTO mockTrip = new TripDTO();
        mockTrip.setId(100L);
        mockTrip.setStatus("IN_PLANNING");

        when(tripService.approveRequest(requestId)).thenReturn(mockTrip);

        // ACT & ASSERT
        mockMvc.perform(post("/api/trips/{id}/approve", requestId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(100))
                .andExpect(jsonPath("$.status").value("IN_PLANNING"));
    }

    // --- Test TC-CORE-02 ---
    @Test
    void planTrip_ShouldReturn400_WhenInputInvalid() throws Exception {
        Long tripId = 100L;
        // DTO Invalido: manca driverId e targa vuota
        PlanningDTO invalidDto = new PlanningDTO();
        invalidDto.setTripId(tripId);
        invalidDto.setVehiclePlate("");

        mockMvc.perform(put("/api/trips/{id}/plan", tripId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidDto)))
                .andExpect(status().isBadRequest()) // Verifica che Spring validi @Valid
                .andExpect(jsonPath("$.type").exists()); // Verifica formato GlobalExceptionHandler
    }

    // --- Test Happy Path Pianificazione ---
    @Test
    void planTrip_ShouldReturn200_WhenValid() throws Exception {
        Long tripId = 100L;
        PlanningDTO dto = new PlanningDTO(tripId, 200L, "AB123CD");

        mockMvc.perform(put("/api/trips/{id}/plan", tripId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk());

        // Verifica che il controller chiami il service
        verify(tripService).planTrip(eq(tripId), any(PlanningDTO.class));
    }
}