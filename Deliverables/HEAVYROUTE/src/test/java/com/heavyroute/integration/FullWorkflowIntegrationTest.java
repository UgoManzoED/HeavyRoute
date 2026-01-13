package com.heavyroute.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.heavyroute.common.model.GeoLocation;
import com.heavyroute.core.dto.RequestCreationDTO;
import com.heavyroute.core.model.Route;
import com.heavyroute.core.service.ExternalMapService;
import com.heavyroute.users.model.Customer;
import com.heavyroute.users.repository.UserRepository;
import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.time.LocalDate;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
@DisplayName("TC-INTEGRATION: Workflow Completo da Creazione a Assegnazione")
public class FullWorkflowIntegrationTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private UserRepository userRepository;
    @Autowired private PasswordEncoder passwordEncoder;

    @MockitoBean
    private ExternalMapService externalMapService;

    private Long sharedRequestId;

    @BeforeAll
    void setupDatabase() {
        // Setup idempotente del customer per il test
        if (userRepository.findByUsername("customer1").isEmpty()) {
            Customer customer = new Customer();
            customer.setUsername("customer1");
            customer.setPassword(passwordEncoder.encode("password"));
            customer.setEmail("customer1@test.it");
            customer.setFirstName("Mario");
            customer.setLastName("Rossi");
            customer.setPhoneNumber("+390000000000");
            customer.setActive(true);
            customer.setCompanyName("Test S.p.A.");
            customer.setVatNumber("12345678901");
            customer.setPec("test@pec.it");
            customer.setAddress("Via Test 1, Roma");

            userRepository.save(customer);
        }
    }

    @Test
    @Order(1)
    @WithMockUser(username = "customer1", roles = "CUSTOMER")
    @DisplayName("TC-CORE-01: Creazione Richiesta Valida (Blackbox)")
    void step1_createRequest() throws Exception {
        RequestCreationDTO dto = new RequestCreationDTO();
        dto.setOriginAddress("Napoli");
        dto.setDestinationAddress("Roma");
        dto.setWeight(1500.0);
        dto.setPickupDate(LocalDate.now().plusDays(30));
        dto.setLoadType("Merci varie");
        dto.setHeight(2.0); dto.setLength(2.0); dto.setWidth(2.0);

        MvcResult result = mockMvc.perform(post("/api/requests")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andReturn();

        String response = result.getResponse().getContentAsString();
        sharedRequestId = JsonPath.parse(response).read("$.id", Long.class);
    }

    @Test
    @Order(2)
    @WithMockUser(roles = "LOGISTIC_PLANNER")
    @DisplayName("TC-CORE-03: Approvazione Richiesta (Blackbox)")
    void step2_approveRequest() throws Exception {
        Assumptions.assumeTrue(sharedRequestId != null, "Salto: Step 1 fallito");

        // Mock del servizio esterno mappe
        Route mockRoute = Route.builder()
                .routeDistance(100.0)
                .routeDuration(60.0)
                .polyline("encoded_polyline_test")
                .startLocation(new GeoLocation(40.8518, 14.2681)) // Napoli
                .endLocation(new GeoLocation(41.9028, 12.4964))   // Roma
                .build();

        when(externalMapService.calculateFullRoute(anyString(), anyString()))
                .thenReturn(mockRoute);

        // Chiamata all'endpoint
        mockMvc.perform(post("/api/trips/" + sharedRequestId + "/approve").with(csrf()))
                .andExpect(status().isCreated())
                // --- CORREZIONE QUI SOTTO ---
                // Il tuo Service ora restituisce IN_PLANNING, quindi il test deve aspettarsi quello.
                .andExpect(jsonPath("$.status").value("IN_PLANNING"))
                .andExpect(jsonPath("$.tripCode").exists());
    }
}