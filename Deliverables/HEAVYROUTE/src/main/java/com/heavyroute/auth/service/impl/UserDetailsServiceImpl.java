package com.heavyroute.auth.service.impl;

import com.heavyroute.users.model.User;
import com.heavyroute.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;

    /**
     * Metodo core invocato da Spring durante il login e la validazione del token.
     * * @param username Lo username passato nel login o estratto dal JWT.
     * @return Un oggetto {@link UserDetails} standard.
     * @throws UsernameNotFoundException se l'utente non esiste nel DB.
     */
    @Override
    @Transactional
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 1. Cerca nel database
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Utente non trovato: " + username));

        // 2. Mappa nel formato di SPRING SECURITY
        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword()) // Hashata
                .roles(user.getRole().name())
                .disabled(!user.isActive())
                .build();
    }
}