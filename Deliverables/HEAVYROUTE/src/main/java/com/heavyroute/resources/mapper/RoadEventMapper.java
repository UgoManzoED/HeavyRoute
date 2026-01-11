package com.heavyroute.resources.mapper;

import com.heavyroute.common.model.GeoLocation;
import com.heavyroute.resources.dto.RoadEventCreationDTO;
import com.heavyroute.resources.dto.RoadEventResponseDTO;
import com.heavyroute.resources.model.RoadEvent;
import org.springframework.stereotype.Component;

/**
 * Mapper responsabile della conversione tra l'entità {@link RoadEvent} e i relativi DTO.
 * <p>
 * Gestisce l'appiattimento dell'oggetto {@link GeoLocation} e il calcolo dei campi
 * derivati per la risposta.
 * </p>
 * * @author Heavy Route Team
 */
@Component
public class RoadEventMapper {

    /**
     * Converte un DTO di creazione in un'entità {@link RoadEvent}.
     * * @param dto Dati di input della segnalazione.
     * @return L'entità configurata per la persistenza.
     */
    public RoadEvent toEntity(RoadEventCreationDTO dto) {
        if (dto == null) return null;

        return RoadEvent.builder()
                .type(dto.getType())
                .severity(dto.getSeverity())
                .description(dto.getDescription())
                .location(new GeoLocation(dto.getLatitude(), dto.getLongitude()))
                .validFrom(dto.getValidFrom())
                .validTo(dto.getValidTo())
                .build();
    }

    /**
     * Converte un'entità {@link RoadEvent} in un DTO di risposta.
     * * @param entity L'entità persistita.
     * @return DTO arricchito con ID e stati calcolati.
     */
    public RoadEventResponseDTO toResponseDTO(RoadEvent entity) {
        if (entity == null) return null;

        RoadEventResponseDTO dto = new RoadEventResponseDTO();
        dto.setId(entity.getId());
        dto.setType(entity.getType());
        dto.setSeverity(entity.getSeverity());
        dto.setDescription(entity.getDescription());

        if (entity.getLocation() != null) {
            dto.setLatitude(entity.getLocation().getLatitude());
            dto.setLongitude(entity.getLocation().getLongitude());
        }

        dto.setValidFrom(entity.getValidFrom());
        dto.setValidTo(entity.getValidTo());
        dto.setActive(entity.isActive());
        dto.setBlocking(entity.isBlocking());

        return dto;
    }
}