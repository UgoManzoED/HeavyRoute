package com.heavyroute.common.config;

import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.model.LoadDetails;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.repository.TransportRequestRepository;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.model.Customer;
import com.heavyroute.users.model.Driver;
import com.heavyroute.users.model.LogisticPlanner;
import com.heavyroute.users.repository.CustomerRepository;
import com.heavyroute.users.repository.DriverRepository;
import com.heavyroute.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

/**
 * Bootstrapper dei dati iniziali.
 * <p>
 * Questa classe viene eseguita automaticamente all'avvio dell'applicazione.
 * Serve a popolare il database con dati "Mock" (finti) per facilitare lo sviluppo
 * e il testing manuale delle API, senza dover inserire dati via SQL ogni volta.
 * </p>
 */
@Component
@RequiredArgsConstructor
@Profile("!test")
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final DriverRepository driverRepository;
    private final CustomerRepository customerRepository;
    private final VehicleRepository vehicleRepository;
    private final TransportRequestRepository requestRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        if (userRepository.count() > 0) {
            return; // DB già popolato
        }

        System.out.println("SEEDING DATABASE...");

        // 1. Crea Pianificatore Logistico
        LogisticPlanner pl = new LogisticPlanner();
        pl.setUsername("planner");
        pl.setPassword(passwordEncoder.encode("password"));
        pl.setEmail("pl@heavyroute.com");
        pl.setFirstName("Luigi");
        pl.setLastName("Pianificatore");
        pl.setPhoneNumber("+393330000001");
        pl.setActive(true);
        userRepository.save(pl);

        // 2. Crea Veicolo
        Vehicle v1 = new Vehicle();
        v1.setLicensePlate("AB123CD");
        v1.setModel("Iveco Stralis");
        v1.setMaxLoadCapacity(20000.0);
        v1.setMaxHeight(4.0);
        v1.setMaxWidth(2.5);
        v1.setMaxLength(12.0);
        v1.setStatus(VehicleStatus.AVAILABLE);
        vehicleRepository.save(v1);

        // 3. Crea Autista
        Driver d1 = new Driver();
        d1.setUsername("driver");
        d1.setPassword(passwordEncoder.encode("password"));
        d1.setEmail("driver@heavyroute.com");
        d1.setFirstName("Mario");
        d1.setLastName("Rossi");
        d1.setPhoneNumber("+393330000002");
        d1.setActive(true);
        d1.setStatus(DriverStatus.FREE);
        d1.setLicenseNumber("PATENTE-CE");
        driverRepository.save(d1);

        // 4. Crea un Cliente
        Customer customer = new Customer();
        customer.setUsername("cliente");
        customer.setPassword(passwordEncoder.encode("password"));
        customer.setEmail("cliente@azienda.com");
        customer.setFirstName("Giuseppe");
        customer.setLastName("Verdi");
        customer.setPhoneNumber("+393330000003");
        customer.setActive(true);
        customer.setCompanyName("Azienda Spedizioni SRL");
        customer.setVatNumber("12345678901");
        customer.setPec("pec@azienda.com");
        customer.setAddress("Via Roma 1");
        Customer savedCustomer = customerRepository.save(customer);

        // 5. Crea Richiesta Pendente
        TransportRequest req = new TransportRequest();
        req.setClient(savedCustomer);
        req.setOriginAddress("Porto di Napoli");
        req.setDestinationAddress("Interporto Bologna");
        req.setPickupDate(LocalDate.now().plusDays(5));
        req.setRequestStatus(RequestStatus.PENDING);

        // 6. Configurazione del carico
        LoadDetails load = new LoadDetails();
        load.setWeightKg(5000.0);
        load.setLength(12.0);
        load.setHeight(3.0);
        load.setWidth(2.5);
        req.setLoad(load);

        requestRepository.save(req);

        System.out.println("DATABASE POPOLATO CON SUCCESSO!");
    }
}