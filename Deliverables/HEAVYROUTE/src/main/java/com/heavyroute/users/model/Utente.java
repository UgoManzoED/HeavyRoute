package com.heavyroute.users.model;

import com.heavyroute.common.model.BaseEntity;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Data
@NoArgsConstructor
@SuperBuilder
@Entity
@Table(name = "utenti")
@Inheritance(strategy = InheritanceType.JOINED) // Strategia ottimale per l'ODD
public abstract class Utente extends BaseEntity {

    @Column(nullable = false, unique = true)
    protected String username;

    // NFR11: Qui verra salvata la password già hashata con BCrypt (non in chiaro!) [cite: 418]
    @Column(nullable = false)
    protected String password;

    @Column(nullable = false, unique = true)
    protected String email;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    protected RuoloUtente role;

    @Column(name = "phone_number", length = 20, nullable = false)
    protected String phoneNumber;

    @Column(nullable=false)
    protected boolean active=false;

    // Metodo di utilità per il login
    public boolean hasRole(RuoloUtente r) {
        return this.role == r;
    }
}