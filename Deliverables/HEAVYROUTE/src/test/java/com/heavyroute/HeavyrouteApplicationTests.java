package com.heavyroute;

import com.heavyroute.core.service.ExternalMapService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@SpringBootTest
class HeavyrouteApplicationTests {

	@MockitoBean
	private ExternalMapService externalMapService;

	@Test
	@DisplayName("TC-SYS-01: Integrità del Sistema - Caricamento Contesto")
	void contextLoads() {
	}

}
