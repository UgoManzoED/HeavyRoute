# HeavyRoute - Sistema di Gestione Trasporti Eccezionali
![Project Status](https://img.shields.io/badge/status-active-success.svg)
![Backend](https://img.shields.io/badge/backend-Spring%20Boot-green)
![Frontend](https://img.shields.io/badge/frontend-Flutter-blue)
![License](https://img.shields.io/badge/license-Apache-lightgrey)

HeavyRoute è una piattaforma software integrata progettata per digitalizzare, automatizzare e ottimizzare il processo di gestione dei trasporti eccezionali. Il sistema connette Committenti, Pianificatori Logistici e Autisti attraverso un'architettura moderna a 3 livelli.

---

## Indice
1. Panoramica del Progetto
2. Architettura e Tecnologie
3. Funzionalità Principali
4. Prerequisiti
5. Guida all'Installazione e Avvio
6. Documentazione API
7. Autori

---

## Panoramica del Progetto
Il sistema sostituisce i flussi di lavoro manuali con una soluzione digitale che copre l'intero ciclo di vita del trasporto:
* Back-office: Gestione anagrafiche, pianificazione viaggi, validazione percorsi.
* Committenti: Inserimento richieste, monitoraggio stato, download documenti.
* Operatività: App mobile per autisti per gestione incarichi e segnalazione imprevisti.

---

## Architettura e Tecnologie

Il progetto segue un'architettura Monolitica Modulare (Modular Monolith) basata su 3-Tier (Presentation, Logic, Data).

### Backend (Logic Tier e Data Tier)
* Linguaggio: Java 17 LTS
* Framework: Spring Boot 3.x
* Database: MariaDB (eseguito via Docker)
* Sicurezza: Spring Security + JWT (Stateless Authentication)
* ORM: Spring Data JPA (Hibernate)
* Build Tool: Maven

### Frontend (Presentation Tier)
* Framework: Flutter (Dart)
* Piattaforme Supportate: Web (Dashboard) e Mobile (App Autista)
* HTTP Client: Dio + Interceptors
* Code Generation: json_serializable, build_runner

---

## Funzionalità Principali
* Autenticazione e Sicurezza: Login sicuro, RBAC (Role-Based Access Control) con 5 ruoli distinti, Password Hashing (BCrypt).
* Gestione Utenti: Registrazione self-service per clienti, gestione staff interno da parte dell'Admin.
* Core Business: Creazione richieste di trasporto, approvazione, generazione automatica Viaggi (Trip), assegnazione risorse (Autista/Veicolo).
* Gestione Risorse: Censimento flotta veicoli e verifica compatibilità (peso/dimensioni).
* Gestione Errori: Gestione centralizzata delle eccezioni con risposte RFC 7807 (Problem Details).

---

## Prerequisiti
Assicurati di avere installato sulla tua macchina:
* Java JDK 17 o superiore.
* Flutter SDK (ultima versione stabile).
* Docker Desktop (per il database) o un'istanza MariaDB locale.
* IDE consigliati: IntelliJ IDEA (Backend), VS Code (Frontend).

---

## Guida all'Installazione e Avvio

### 1. Avvio del Database (Docker)
Esegui questo comando per avviare un container MariaDB pronto all'uso:

    docker run --name heavyroute-db \
      -e MARIADB_ROOT_PASSWORD=root \
      -e MARIADB_DATABASE=heavyroute_db \
      -p 3306:3306 \
      -d mariadb:latest

### 2. Avvio del Backend (Spring Boot)
Apri la cartella del backend con IntelliJ o terminale ed esegui:

    mvn spring-boot:run

Il server sarà attivo su: http://localhost:8080.
Nota: Al primo avvio, il DataSeeder popolerà automaticamente il database con dati di prova.

### 3. Avvio del Frontend (Flutter)
Apri la cartella heavyroute_app ed esegui i seguenti comandi per scaricare le dipendenze e avviare l'applicazione:

    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    flutter run -d chrome

---

## Documentazione API
Una volta avviato il backend, la documentazione Swagger/OpenAPI è disponibile all'indirizzo:
http://localhost:8080/swagger-ui.html

---

## Autori
Progetto sviluppato per il corso di Ingegneria del Software (UNISA - 2025/2026).
* Umberto Manfredini
* Ugo Manzo
* Pino Fiorello Romano
