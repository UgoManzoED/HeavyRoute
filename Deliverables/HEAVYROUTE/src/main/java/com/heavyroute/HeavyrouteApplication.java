package com.heavyroute;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class HeavyrouteApplication {

	public static void main(String[] args) {
		SpringApplication.run(HeavyrouteApplication.class, args);
	}

}
