package com.heavyroute.common.model;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

/**
 * Astrazione di base per la persistenza delle entità.
 * <p>
 * Questa classe utilizza i meccanismi di <strong>Spring Data JPA Auditing</strong> per gestire
 * automaticamente il ciclo di vita temporale dei record.
 * </p>
 * <h3>Best Practice:</h3>
 * Estendere questa classe per tutte le entità che richiedono persistenza su database relazionali,
 * a meno che non si tratti di tabelle di join pure.
 * @see org.springframework.data.jpa.domain.support.AuditingEntityListener
 */

@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public abstract class BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;
}