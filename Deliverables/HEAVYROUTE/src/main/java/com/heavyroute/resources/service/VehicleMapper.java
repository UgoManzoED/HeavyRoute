package com.heavyroute.resources.service;

import com.heavyroute.resources.dto.VehicleDTO;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.enums.VehicleStatus;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Componente responsabile della mappatura tra l'entità {@link Vehicle} e il relativo DTO.
 * <p>
 * Gestisce la conversione dei tipi di dato, in particolare la trasformazione
 * tra l'enumerazione {@link VehicleStatus} e la sua rappresentazione testuale nel DTO.
 * </p>
 * * @author Heavy Route Team
 */
@Component
public class VehicleMapper {

    /**
     * Converte un'entità {@link Vehicle} in un {@link VehicleDTO}.
     * <p>
     * Utilizza {@code .name()} sull'Enum dello stato per popolare il campo String del DTO.
     * </p>
     * * @param entity L'entità da convertire.
     * @return Il DTO popolato.
     */
    public VehicleDTO toDTO(Vehicle entity) {
        if (entity == null) return null;

        VehicleDTO dto = new VehicleDTO();
        dto.setLicensePlate(entity.getLicensePlate());
        dto.setModel(entity.getModel());
        dto.setMaxLoadCapacity(entity.getMaxLoadCapacity());
        dto.setMaxHeight(entity.getMaxHeight());
        dto.setMaxWidth(entity.getMaxWidth());
        dto.setMaxLength(entity.getMaxLength());

        // Conversione Enum -> String per il DTO
        if (entity.getStatus() != null) {
            dto.setStatus(VehicleStatus.valueOf(entity.getStatus().name()));
        }

        return dto;
    }

    /**
     * Converte una lista di entità Vehicle in una lista di VehicleDTO.
     */
    public List<VehicleDTO> toDTOList(List<Vehicle> entities) {
        if (entities == null) {
            return List.of();
        }
        return entities.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Converte un {@link VehicleDTO} in un'entità {@link Vehicle}.
     * <p>
     * Utilizza {@code VehicleStatus.valueOf()} per convertire la stringa del DTO nell'Enum richiesto dall'Entity.
     * </p>
     * * @param dto Il DTO da convertire.
     * @return L'entità configurata.
     */
    public Vehicle toEntity(VehicleDTO dto) {
        if (dto == null) return null;

        return Vehicle.builder()
                .licensePlate(dto.getLicensePlate())
                .model(dto.getModel())
                .maxLoadCapacity(dto.getMaxLoadCapacity())
                .maxHeight(dto.getMaxHeight())
                .maxWidth(dto.getMaxWidth())
                .maxLength(dto.getMaxLength())
                // Conversione String -> Enum per l'Entity
                .status(VehicleStatus.valueOf(String.valueOf(dto.getStatus())))
                .build();
    }
}