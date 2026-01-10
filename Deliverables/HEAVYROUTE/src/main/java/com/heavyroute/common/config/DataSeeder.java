package com.heavyroute.common.config;

import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.model.LoadDetails;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.repository.TransportRequestRepository;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.enums.UserRole;
import com.heavyroute.users.model.*;
import com.heavyroute.users.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

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
            return;
        }

        System.out.println("SEEDING DATABASE...");

        // --- 1. PERSONALE INTERNO ---

        // Pianificatore Logistico
        createInternalUser("planner", "Luigi", "Verdi", "planner@heavyroute.com", UserRole.LOGISTIC_PLANNER);

        // Traffic Coordinator
        createInternalUser("coordinator", "Anna", "Rossi", "tc@heavyroute.com", UserRole.TRAFFIC_COORDINATOR);

        // Gestore Account
        createInternalUser("gaccount", "Marco", "Bianchi", "gaccount@heavyroute.com", UserRole.ACCOUNT_MANAGER);

        // --- 2. FLOTTA VEICOLI ---

        // Veicolo Standard (Disponibile)
        createVehicle("VE-001-AB", "Iveco Stralis 480", 25000.0, 13.6, 2.55, 4.0, VehicleStatus.AVAILABLE);

        // Veicolo Eccezionale (Disponibile)
        createVehicle("XC-999-ZZ", "Volvo FH16 750", 60000.0, 18.0, 3.0, 4.5, VehicleStatus.AVAILABLE);

        // Veicolo in Manutenzione (Non disponibile)
        createVehicle("MN-555-XX", "Scania R500", 30000.0, 13.6, 2.55, 4.0, VehicleStatus.MAINTENANCE);

        // --- 3. AUTISTI ---

        Driver d1 = createDriver("driver1", "Giovanni", "Esposito", "d1@hr.com", "PAT-CE-123456", DriverStatus.FREE);
        Driver d2 = createDriver("driver2", "Luca", "Moretti", "d2@hr.com", "PAT-CE-987654", DriverStatus.FREE);
        Driver d3 = createDriver("driver3", "Matteo", "Ricci", "d3@hr.com", "PAT-CE-112233", DriverStatus.ON_THE_ROAD); // Già occupato

        // --- 4. COMMITTENTI ---

        // Committente 1: Hitachi Rail
        Customer hitachi = createCustomer(
                "hitachi", "Giulia", "Manfredi", "logistica@hitachirail.com",
                "Hitachi Rail STS", "00468920689", "Via Argine 425, Napoli"
        );

        // Committente 2: Ansaldo Energia (per testare multi-utenza)
        Customer ansaldo = createCustomer(
                "ansaldo", "Roberto", "Ferry", "transport@ansaldo.com",
                "Ansaldo Energia", "00725620150", "Via Lorenzi 8, Genova"
        );

        // --- 5. RICHIESTE DI TRASPORTO ---

        // Req 1: Carrozza Ferroviaria (Hitachi) - PENDING
        createRequest(hitachi,
                "Stabilimento Hitachi, Napoli",
                "Deposito Trenitalia, Firenze Osmannoro",
                LocalDate.now().plusDays(10),
                RequestStatus.PENDING,
                "Carrozza Treno Metro linea 1", 35000.0, 24.0, 2.8, 3.8
        );

        // Req 2: Turbina a Gas (Ansaldo) - PENDING
        createRequest(ansaldo,
                "Porto di Genova",
                "Centrale Elettrica Turbigo (MI)",
                LocalDate.now().plusDays(20),
                RequestStatus.PENDING,
                "Turbina GT36", 280000.0, 12.0, 4.5, 4.2
        );

        // Req 3: Ricambi (Hitachi) - APPROVED
        createRequest(hitachi,
                "Interporto Bologna",
                "Hitachi Pistoia",
                LocalDate.now().plusDays(3),
                RequestStatus.APPROVED,
                "Casse Ricambi", 5000.0, 6.0, 2.4, 2.5
        );

        System.out.println("DATABASE POPOLATO CON SUCCESSO!");
    }

    // --- HELPER METHODS ---

    private void createInternalUser(String username, String name, String surname, String email, UserRole role) {
        User user;
        if (role == UserRole.LOGISTIC_PLANNER) user = new LogisticPlanner();
        else if (role == UserRole.TRAFFIC_COORDINATOR) user = new TrafficCoordinator();
        else user = new AccountManager(); // Default fallback

        user.setUsername(username);
        user.setPassword(passwordEncoder.encode("password"));
        user.setEmail(email);
        user.setFirstName(name);
        user.setLastName(surname);
        user.setPhoneNumber("+393331234567");
        user.setActive(true);
        userRepository.save(user);
    }

    private void createVehicle(String plate, String model, Double capacity, Double len, Double wid, Double hei, VehicleStatus status) {
        Vehicle v = new Vehicle();
        v.setLicensePlate(plate);
        v.setModel(model);
        v.setMaxLoadCapacity(capacity);
        v.setMaxLength(len);
        v.setMaxWidth(wid);
        v.setMaxHeight(hei);
        v.setStatus(status);
        vehicleRepository.save(v);
    }

    private Driver createDriver(String username, String name, String surname, String email, String license, DriverStatus status) {
        Driver d = new Driver();
        d.setUsername(username);
        d.setPassword(passwordEncoder.encode("password"));
        d.setEmail(email);
        d.setFirstName(name);
        d.setLastName(surname);
        d.setPhoneNumber("+393339876543");
        d.setActive(true);
        d.setLicenseNumber(license);
        d.setStatus(status);
        return driverRepository.save(d);
    }

    private Customer createCustomer(String username, String name, String surname, String email, String company, String vat, String address) {
        Customer c = new Customer();
        c.setUsername(username);
        c.setPassword(passwordEncoder.encode("password"));
        c.setEmail(email);
        c.setFirstName(name);
        c.setLastName(surname);
        c.setPhoneNumber("+390810000000");
        c.setActive(true);
        c.setCompanyName(company);
        c.setVatNumber(vat);
        c.setPec(username + "@pec.it");
        c.setAddress(address);
        return customerRepository.save(c);
    }

    private void createRequest(Customer client, String origin, String dest, LocalDate date, RequestStatus status,
                               String loadDesc, Double weight, Double len, Double wid, Double hei) {
        TransportRequest req = new TransportRequest();
        req.setClient(client);
        req.setOriginAddress(origin);
        req.setDestinationAddress(dest);
        req.setPickupDate(date);
        req.setRequestStatus(status);

        LoadDetails load = new LoadDetails();
        load.setWeightKg(weight);
        load.setLength(len);
        load.setWidth(wid);
        load.setHeight(hei);
        req.setLoad(load);

        requestRepository.save(req);
    }
}