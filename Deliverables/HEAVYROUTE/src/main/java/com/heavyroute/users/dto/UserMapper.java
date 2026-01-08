package com.heavyroute.users.dto;

import com.heavyroute.users.dto.CustomerUpdateDTO;
import com.heavyroute.users.dto.InternalUserUpdateDTO;
import com.heavyroute.users.dto.UserDTO;
import com.heavyroute.users.model.Customer;
import com.heavyroute.users.model.User;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Componente responsabile della trasformazione dei dati (Mapping) del modulo Users.
 * <p>
 * Centralizza la logica di conversione tra il modello di dominio (Entity) e i contratti API (DTO).
 * Gestisce l'aggiornamento parziale delle entità ("Patching") garantendo che i campi nulli
 * nei DTO non sovrascrivano i dati esistenti nel Database.
 * </p>
 */
@Component
public class UserMapper {

    /**
     * Converte un'entità {@link User} (o sottoclasse) nel DTO di lettura generico.
     * <p>
     * <b>Sicurezza:</b> Non espone mai hash della password o dati sensibili.
     * </p>
     *
     * @param entity L'entità da convertire.
     * @return Il DTO popolato, o {@code null} se l'input è nullo.
     */
    public UserDTO toDTO(User entity) {
        if (entity == null) {
            return null;
        }

        UserDTO dto = new UserDTO();
        dto.setId(entity.getId());
        dto.setUsername(entity.getUsername());
        dto.setEmail(entity.getEmail());
        dto.setFirstName(entity.getFirstName());
        dto.setLastName(entity.getLastName());
        dto.setActive(entity.isActive());
        dto.setRole(entity.getRole());

        return dto;
    }

    /**
     * Converte una lista di entità in una lista di DTO.
     *
     * @param users La lista di utenti.
     * @return Lista di DTO (mai null).
     */
    public List<UserDTO> toDTOList(List<User> users) {
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

        // Gestione Three-State Logic per il campo booleano
        // (Null = nessuna modifica, True = attiva, False = disattiva)
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

        // Aggiornamento campi Base (User)
        if (dto.getFirstName() != null) entity.setFirstName(dto.getFirstName());
        if (dto.getLastName() != null) entity.setLastName(dto.getLastName());
        if (dto.getEmail() != null) entity.setEmail(dto.getEmail());

        // Aggiornamento campi Specifici (Customer)
        if (dto.getCompanyName() != null) entity.setCompanyName(dto.getCompanyName());
        if (dto.getVatNumber() != null) entity.setVatNumber(dto.getVatNumber());
        if (dto.getAddress() != null) entity.setAddress(dto.getAddress());
        if (dto.getPhoneNumber() != null) entity.setPhoneNumber(dto.getPhoneNumber());

        // Nota: Lo stato 'active' non è modificabile qui perché i clienti non si auto-attivano.
        // Nota: La password è gestita dal Service.
    }
}