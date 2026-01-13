package com.heavyroute.common.config;

import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.model.*;
import com.heavyroute.core.repository.*;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.model.*;
import com.heavyroute.users.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Component
@RequiredArgsConstructor
@Profile("!test")
@Slf4j
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final DriverRepository driverRepository;
    private final CustomerRepository customerRepository;
    private final VehicleRepository vehicleRepository;
    private final TransportRequestRepository requestRepository;
    private final PasswordEncoder passwordEncoder;

    private static final String DEV_PASSWORD = "password";

    @Override
    @Transactional
    public void run(String... args) {
        if (userRepository.count() > 0) {
            log.info("Database già popolato. Seeding saltato.");
            return;
        }

        log.info("📡 Inizio popolamento Database...");
        String encodedPwd = passwordEncoder.encode(DEV_PASSWORD);

        // --- 1. PERSONALE INTERNO ---
        createPlanner("planner", "Luigi", "Verdi", "PLN-001", encodedPwd);
        createCoordinator("coordinator", "Anna", "Rossi", "TC-001", encodedPwd);
        createAccountManager("gaccount", "Marco", "Bianchi", "AM-001", encodedPwd);

        // --- 2. FLOTTA VEICOLI ---
        createVehicle("VE-001-AB", "Iveco Stralis 480", 25000.0, 13.6, 2.55, 4.0, VehicleStatus.AVAILABLE);
        createVehicle("XC-999-ZZ", "Volvo FH16 750", 60000.0, 18.0, 3.0, 4.5, VehicleStatus.AVAILABLE);
        createVehicle("RM-555-KL", "Scania R500", 28000.0, 13.6, 2.55, 4.0, VehicleStatus.AVAILABLE);

        // --- 3. AUTISTI ---
        createDriver("driver1", "Giovanni", "Esposito", "d1@hr.com", "PAT-CE-123456", "DRV-101", DriverStatus.FREE, encodedPwd);
        createDriver("driver2", "Luca", "Moretti", "d2@hr.com", "PAT-CE-987654", "DRV-102", DriverStatus.FREE, encodedPwd);
        createDriver("driver3", "Mario", "Rossi", "d3@hr.com", "PAT-CE-112233", "DRV-103", DriverStatus.FREE, encodedPwd);

        // --- 4. COMMITTENTI ---
        Customer hitachi = createCustomer("hitachi", "Giulia", "Manfredi", "logistica@hitachirail.com",
                "Hitachi Rail STS", "00468920689", "Via Argine 425, Napoli", encodedPwd);

        Customer ansaldo = createCustomer("ansaldo", "Roberto", "Ferry", "transport@ansaldo.com",
                "Ansaldo Energia", "00725620150", "Via Lorenzi 8, Genova", encodedPwd);

        // --- 5. RICHIESTE PENDENTI ---

        log.info("Creazione richieste pendenti...");

        // SCENARIO 1: Trasporto Eccezionale
        createRequest(hitachi,
                "Via Galileo Ferraris 128, Napoli",
                "Via Ciliegiole 77, Pistoia",
                LocalDate.of(2026, 1, 22),
                RequestStatus.PENDING,
                16000.0, // 16 Tonnellate
                26.0,    // 26 Metri (Eccezionale)
                2.8,     // 2.8 Metri (Eccezionale)
                3.8,     // Altezza
                "Fiancate carrozza ferroviaria (x2)"
        );

        // Caso 2: HUB -> Città
        // Genova (Porto Traghetti) -> Milano (Via Torino)
        createRequest(ansaldo, "Piazzale Traghetti, Genova", "Via Torino, Milano",
                LocalDate.now().plusDays(20), RequestStatus.PENDING,
                280000.0, 12.0, 4.5, 4.2, "Turbina GT36");

        // Caso 3: HUB -> HUB
        // Bologna (Interporto) -> Pistoia (Hitachi)
        createRequest(hitachi, "Interporto Bologna", "Hitachi Pistoia",
                LocalDate.now().plusDays(3), RequestStatus.PENDING,
                5000.0, 6.0, 2.4, 2.5, "Casse Ricambi");

        // Caso 4: Città -> Città
        // Milano -> Torino
        createRequest(ansaldo, "Milano", "Torino",
                LocalDate.now().plusDays(5), RequestStatus.PENDING,
                15000.0, 13.6, 2.5, 4.0, "Generatore");

        // Caso 5: HUB -> HUB
        // Napoli (Porto) -> Roma (Smistamento)
        createRequest(hitachi, "Napoli Port", "Roma Smistamento",
                LocalDate.now().plusDays(7), RequestStatus.PENDING,
                12000.0, 10.0, 2.5, 3.0, "Componenti Meccanici");

        log.info("✅ DATABASE INIZIALIZZATO CON DATI DI TEST.");
    }

    // --- HELPER METHODS ---

    private void createPlanner(String username, String name, String surname, String serial, String pwd) {
        LogisticPlanner user = LogisticPlanner.builder()
                .username(username).password(pwd).email(username + "@heavyroute.com")
                .firstName(name).lastName(surname).phoneNumber("+393330000001")
                .active(true).serialNumber(serial).hireDate(LocalDate.now().minusYears(5))
                .build();
        userRepository.save(user);
    }

    private void createCoordinator(String username, String name, String surname, String serial, String pwd) {
        TrafficCoordinator user = TrafficCoordinator.builder()
                .username(username).password(pwd).email("tc@heavyroute.com")
                .firstName(name).lastName(surname).phoneNumber("+393330000002")
                .active(true).serialNumber(serial).hireDate(LocalDate.now().minusYears(3))
                .build();
        userRepository.save(user);
    }

    private void createAccountManager(String username, String name, String surname, String serial, String pwd) {
        AccountManager user = AccountManager.builder()
                .username(username).password(pwd).email("gaccount@heavyroute.com")
                .firstName(name).lastName(surname).phoneNumber("+393330000003")
                .active(true).serialNumber(serial).hireDate(LocalDate.now().minusYears(2))
                .build();
        userRepository.save(user);
    }

    private void createDriver(String username, String name, String surname, String email,
                              String license, String serial, DriverStatus status, String pwd) {
        Driver d = Driver.builder()
                .username(username).password(pwd).email(email)
                .firstName(name).lastName(surname).phoneNumber("+393339876543")
                .active(true).licenseNumber(license).serialNumber(serial)
                .hireDate(LocalDate.now().minusMonths(6)).driverStatus(status)
                .build();
        driverRepository.save(d);
    }

    private Customer createCustomer(String username, String name, String surname, String email,
                                    String company, String vat, String address, String pwd) {
        Customer c = Customer.builder()
                .username(username).password(pwd).email(email)
                .firstName(name).lastName(surname).phoneNumber("+390810000000")
                .active(true).companyName(company).vatNumber(vat)
                .pec(username + "@pec.it").address(address)
                .build();
        return customerRepository.save(c);
    }

    private void createVehicle(String plate, String model, Double cap, Double len, Double wid, Double hei, VehicleStatus status) {
        Vehicle v = Vehicle.builder()
                .licensePlate(plate).model(model).maxLoadCapacity(cap)
                .maxLength(len).maxWidth(wid).maxHeight(hei).status(status)
                .build();
        vehicleRepository.save(v);
    }

    private TransportRequest createRequest(Customer client, String origin, String dest, LocalDate date, RequestStatus status,
                                           Double weight, Double len, Double wid, Double hei, String typeDesc) {
        LoadDetails load = new LoadDetails();
        load.setWeightKg(weight); load.setLength(len); load.setWidth(wid); load.setHeight(hei);
        load.setType(typeDesc); load.setQuantity(1);

        TransportRequest req = TransportRequest.builder()
                .client(client).originAddress(origin).destinationAddress(dest)
                .pickupDate(date).requestStatus(status).load(load)
                .build();
        return requestRepository.save(req);
    }
}