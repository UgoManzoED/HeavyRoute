package com.heavyroute.users.mapper;

import com.heavyroute.users.dto.CustomerUpdateDTO;
import com.heavyroute.users.dto.InternalUserUpdateDTO;
import com.heavyroute.users.dto.UserResponseDTO;
import com.heavyroute.users.model.Customer;
import com.heavyroute.users.model.Driver;
import com.heavyroute.users.model.InternalUser;
import com.heavyroute.users.model.User;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Componente responsabile della trasformazione dei dati (Mapping) del modulo Users.
 * <p>
 * Ora gestisce la strategia "Unificata": mappa l'entità specifica (es. Driver)
 * in un unico DTO di risposta che contiene tutti i campi possibili.
 * </p>
 */
@Component
public class UserMapper {

    /**
     * Converte un'entità {@link User} (o sottoclasse) nel DTO di lettura unificato.
     * <p>
     * Esegue il "Type Checking" a runtime per determinare se l'utente è un Autista,
     * un Cliente o un Membro dello Staff e popola i campi aggiuntivi di conseguenza.
     * </p>
     *
     * @param entity L'entità da convertire.
     * @return Il DTO popolato con dati base + dati specifici del ruolo.
     */
    public UserResponseDTO toDTO(User entity) {
        if (entity == null) {
            return null;
        }

        UserResponseDTO dto = new UserResponseDTO();

        // 1. MAPPING CAMPI BASE (Comuni a tutti)
        dto.setId(entity.getId());
        dto.setUsername(entity.getUsername());
        dto.setEmail(entity.getEmail());
        dto.setFirstName(entity.getFirstName());
        dto.setLastName(entity.getLastName());
        dto.setActive(entity.isActive());
        dto.setRole(entity.getRole());
        dto.setPhoneNumber(entity.getPhoneNumber());

        // 2. MAPPING SPECIFICO PER DRIVER
        if (entity instanceof Driver) {
            Driver driver = (Driver) entity;
            dto.setLicenseNumber(driver.getLicenseNumber());
            dto.setDriverStatus(driver.getDriverStatus());
            dto.setSerialNumber(driver.getSerialNumber());
            dto.setHireDate(driver.getHireDate());
        }

        // 3. MAPPING SPECIFICO PER CUSTOMER
        else if (entity instanceof Customer) {
            Customer customer = (Customer) entity;
            dto.setCompanyName(customer.getCompanyName());
            dto.setVatNumber(customer.getVatNumber());
            dto.setPec(customer.getPec());
            dto.setAddress(customer.getAddress());
            dto.setPhoneNumber(customer.getPhoneNumber());
        }

        else if (entity instanceof InternalUser) {
            InternalUser internal = (InternalUser) entity;
            dto.setSerialNumber(internal.getSerialNumber());
            dto.setHireDate(internal.getHireDate());
        }

        return dto;
    }

    /**
     * Converte una lista di entità in una lista di DTO.
     *
     * @param users La lista di utenti.
     * @return Lista di DTO (mai null).
     */
    public List<UserResponseDTO> toDTOList(List<User> users) {
        if (users == null) {
            return List.of();
        }
        return users.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Aggiorna un utente interno con i dati del DTO.
     * <p>
     * Applica la logica <b>"Null-Safe Update"</b>: aggiorna solo i campi valorizzati nel DTO.
     * La password viene ignorata qui (gestita esplicitamente dal Service per l'hashing).
     * </p>
     *
     * @param dto    DTO contenente i nuovi dati.
     * @param entity Entità persistente da aggiornare.
     */
    public void updateInternalUserFromDTO(InternalUserUpdateDTO dto, User entity) {
        if (dto == null || entity == null) {
            return;
        }

        if (dto.getUsername() != null) entity.setUsername(dto.getUsername());
        if (dto.getEmail() != null) entity.setEmail(dto.getEmail());
        if (dto.getFirstName() != null) entity.setFirstName(dto.getFirstName());
        if (dto.getLastName() != null) entity.setLastName(dto.getLastName());

        if (dto.getActive() != null) {
            entity.setActive(dto.getActive());
        }
    }

    /**
     * Aggiorna un profilo Customer con i dati del DTO specifico.
     * <p>
     * Gestisce sia i campi comuni ereditati da User, sia i campi specifici aziendali
     * dell'entità Customer.
     * </p>
     *
     * @param dto    DTO specifico per l'aggiornamento clienti.
     * @param entity Entità Customer persistente.
     */
    public void updateCustomerFromDTO(CustomerUpdateDTO dto, Customer entity) {
        if (dto == null || entity == null) {
            return;
        }

        // Campi Base
        if (dto.getFirstName() != null) entity.setFirstName(dto.getFirstName());
        if (dto.getLastName() != null) entity.setLastName(dto.getLastName());
        if (dto.getEmail() != null) entity.setEmail(dto.getEmail());

        // Campi Customer
        if (dto.getCompanyName() != null) entity.setCompanyName(dto.getCompanyName());
        if (dto.getVatNumber() != null) entity.setVatNumber(dto.getVatNumber());
        if (dto.getAddress() != null) entity.setAddress(dto.getAddress());
        if (dto.getPhoneNumber() != null) entity.setPhoneNumber(dto.getPhoneNumber());
    }
}