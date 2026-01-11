package com.heavyroute.users.dto;

import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserResponseDTO {

    // --- CAMPI COMUNI ---
    private Long id;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private UserRole role;
    private boolean active;

    // --- CAMPI STAFF / DRIVER ---
    private String serialNumber;
    private LocalDate hireDate;

    // --- CAMPI SPECIFICI DRIVER ---
    private String licenseNumber;
    private DriverStatus driverStatus;

    // --- CAMPI SPECIFICI CUSTOMER ---
    private String companyName;
    private String vatNumber;
    private String pec;
    private String address;
}