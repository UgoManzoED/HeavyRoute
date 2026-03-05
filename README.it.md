*[Read this in English](README.md) | [Leggi in Italiano](README.it.md)*

# HeavyRoute - Sistema di Gestione Trasporti Eccezionali

**Università di Salerno** **Corso:** Ingegneria del Software - A.A. 2025/2026  
**Professore:** Andrea DE LUCIA

**Team:** 
* Umberto Manfredini (Matricola: 0512119797) - [GitHub](https://github.com/umanfredini)
* Ugo Manzo (Matricola: 0512119071) - [GitHub](https://github.com/UgoManzoED)
* Pino Fiorello Romano (Matricola: 0512120259) - [GitHub](https://github.com/piifiore)

> Piattaforma software integrata progettata per digitalizzare, automatizzare e ottimizzare il processo di gestione dei trasporti eccezionali, connettendo Committenti, Pianificatori Logistici e Autisti tramite una moderna architettura a 3 livelli.

![Project Status](https://img.shields.io/badge/Status-Active-success)
![Backend](https://img.shields.io/badge/Backend-Spring%20Boot-green)
![Frontend](https://img.shields.io/badge/Frontend-Flutter-blue)
![License](https://img.shields.io/badge/License-APACHE-lightgrey)

---

## Indice
* [Panoramica del Progetto](#panoramica-del-progetto)
* [Architettura e Tecnologie](#architettura-e-tecnologie)
* [Funzionalità Principali](#funzionalità-principali)
* [Tecnologie](#tecnologie)
* [Per Iniziare](#per-iniziare)
  * [Prerequisiti](#prerequisiti)
  * [Installazione e Avvio](#installazione-e-avvio)
* [Documentazione API](#documentazione-api)

---

## Panoramica del Progetto
**HeavyRoute** sostituisce i flussi di lavoro manuali con una soluzione digitale che copre l'intero ciclo di vita del trasporto eccezionale. Il sistema fornisce un ecosistema unificato diviso in tre aree operative:
* **Back-office:** Gestione anagrafiche, pianificazione viaggi e validazione percorsi.
* **Committenti:** Inserimento richieste, monitoraggio dello stato e download documenti.
* **Operatività:** App mobile dedicata agli autisti per la gestione degli incarichi e la segnalazione di imprevisti in tempo reale.

## Architettura e Tecnologie
Il progetto segue un'architettura **Monolitica Modulare** (Modular Monolith) basata su un classico pattern a 3-Tier (Presentation, Logic, Data). 

* **Backend (Logic & Data Tier):** Sviluppato in Java 17 LTS con Spring Boot 3.x. Implementa un sistema di sicurezza basato su Spring Security e JWT (Stateless Authentication), utilizza Spring Data JPA (Hibernate) come ORM e Maven come build tool. Il database relazionale è MariaDB, eseguito tramite container Docker.
* **Frontend (Presentation Tier):** Realizzato con Flutter (Dart) per supportare nativamente piattaforme Web (Dashboard gestionale) e Mobile (App Autista). Utilizza Dio con Interceptors per le chiamate HTTP e strumenti di code generation come `json_serializable` e `build_runner`.

## Funzionalità Principali
**Autenticazione e Sicurezza:** Login sicuro, RBAC (Role-Based Access Control) con 5 ruoli distinti e Password Hashing tramite BCrypt.\
**Gestione Utenti:** Registrazione self-service per i clienti e gestione dello staff interno riservata all'Admin.\
**Core Business:** Creazione richieste di trasporto, sistema di approvazione, generazione automatica dei Viaggi (Trip) e assegnazione risorse (Autista/Veicolo).\
**Gestione Risorse:** Censimento della flotta veicoli con verifica algoritmica della compatibilità fisica (peso/dimensioni).\
**Gestione Errori:** Gestione centralizzata delle eccezioni con standardizzazione delle risposte HTTP tramite RFC 7807 (Problem Details).

## Tecnologie
* [Java 17](https://www.oracle.com/java/) & [Spring Boot 3.x](https://spring.io/projects/spring-boot)
* [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
* [MariaDB](https://mariadb.org/) & [Docker](https://www.docker.com/)
* [Maven](https://maven.apache.org/)

---

## Per Iniziare
Segui queste istruzioni per configurare e avviare l'ambiente di sviluppo locale.

### Prerequisiti
Assicurati di avere installato sulla tua macchina:
* Java JDK 17 o superiore
* Flutter SDK (ultima versione stabile)
* Docker Desktop (per il database) o un'istanza MariaDB locale
* IDE consigliati: IntelliJ IDEA (Backend), VS Code (Frontend)

### Installazione e Avvio

1. **Avvio del Database (Docker)**
Esegui questo comando per avviare un container MariaDB pronto all'uso:
```bash
docker run --name heavyroute-db \
  -e MARIADB_ROOT_PASSWORD=root \
  -e MARIADB_DATABASE=heavyroute_db \
  -p 3306:3306 \
  -d mariadb:latest
```

2. **Avvio del Backend (Spring Boot)**
Apri la cartella del backend tramite terminale o IntelliJ ed esegui:
```bash
mvn spring-boot:run
```
*Il server sarà attivo all'indirizzo: `http://localhost:8080`.*
*Nota: Al primo avvio, il `DataSeeder` popolerà automaticamente il database con dati di prova.*

3. **Avvio del Frontend (Flutter)**
Apri la cartella `heavyroute_app` ed esegui i seguenti comandi per scaricare le dipendenze e avviare l'applicazione web:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

---

## Documentazione API
Una volta avviato il backend, la documentazione Swagger/OpenAPI viene generata in automatico ed è consultabile all'indirizzo:
`http://localhost:8080/swagger-ui.html`
