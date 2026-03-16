*[Read this in English](README.md) | [Leggi in Italiano](README.it.md)*

# HeavyRoute - Exceptional Transport Management System

**University of Salerno** **Course:** Software Engineering - A.Y. 2025/2026  
**Professor:** Andrea DE LUCIA  

**Team:** 
* Umberto Manfredini (Matricola: 0512119797) - [GitHub](https://github.com/umanfredini)
* Ugo Manzo (Matricola: 0512119071)(Coordinator) - [GitHub](https://github.com/UgoManzoED)
* Pino Fiorello Romano (Matricola: 0512120259) - [GitHub](https://github.com/piifiore)

> An integrated software platform designed to digitize, automate, and optimize the management process of exceptional transports, connecting Clients, Logistics Planners, and Drivers through a modern 3-tier architecture.

![Project Status](https://img.shields.io/badge/Status-Active-success)
![Backend](https://img.shields.io/badge/Backend-Spring%20Boot-green)
![Frontend](https://img.shields.io/badge/Frontend-Flutter-blue)
![License](https://img.shields.io/badge/License-APACHE-lightgrey)

---

## Table of Contents
* [About the Project](#about-the-project)
* [Architecture & Methodology](#architecture--methodology)
* [Key Features](#key-features)
* [Built With](#built-with)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation & Execution](#installation--execution)
* [API Documentation](#api-documentation)

---

## About the Project
**HeavyRoute** replaces manual workflows with a digital solution that covers the entire lifecycle of exceptional transport. The system provides a unified ecosystem divided into three main operational areas:
* **Back-office:** Registry management, trip planning, and route validation.
* **Clients:** Transport request submission, status tracking, and document downloads.
* **Operations:** A dedicated mobile app for drivers to manage assignments and report unexpected events in real-time.

## Architecture & Methodology
The project follows a **Modular Monolith** architecture based on a standard 3-Tier design (Presentation, Logic, Data).

* **Backend (Logic & Data Tier):** Developed in Java 17 LTS using Spring Boot 3.x. It implements stateless authentication via Spring Security and JWT, relies on Spring Data JPA (Hibernate) as its ORM, and uses Maven as the build tool. The database is MariaDB, containerized via Docker.
* **Frontend (Presentation Tier):** Built with Flutter (Dart), supporting both Web (for the management dashboard) and Mobile (for the driver app) platforms. It utilizes Dio with Interceptors for HTTP networking and code generation tools like `json_serializable` and `build_runner`.

## Key Features
**Authentication & Security:** Secure login, Role-Based Access Control (RBAC) with 5 distinct roles, and BCrypt password hashing. \
**User Management:** Self-service registration for clients and internal staff management handled by the Admin. \
**Core Business Logic:** End-to-end management of transport requests, approvals, automatic Trip generation, and resource assignment (Driver/Vehicle). \
**Resource Management:** Vehicle fleet registry coupled with physical compatibility checks (weight/dimensions). \
**Error Handling:** Centralized exception management compliant with RFC 7807 (Problem Details) responses. \

## Built With
* [Java 17](https://www.oracle.com/java/) & [Spring Boot 3.x](https://spring.io/projects/spring-boot)
* [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
* [MariaDB](https://mariadb.org/) & [Docker](https://www.docker.com/)
* [Maven](https://maven.apache.org/)

---

## Getting Started
Follow these instructions to get a local copy up and running on your machine.

### Prerequisites
Ensure you have the following installed on your system:
* Java JDK 17 or higher
* Flutter SDK (latest stable version)
* Docker Desktop (for the database) or a local MariaDB instance
* Recommended IDEs: IntelliJ IDEA (Backend), VS Code (Frontend)

### Installation & Execution

1. **Start the Database (Docker)**
Run the following command to spin up a ready-to-use MariaDB container:
```bash
docker run --name heavyroute-db \
  -e MARIADB_ROOT_PASSWORD=root \
  -e MARIADB_DATABASE=heavyroute_db \
  -p 3306:3306 \
  -d mariadb:latest
```

2. **Start the Backend (Spring Boot)**
Open the backend folder in your terminal or IntelliJ and execute:
```bash
mvn spring-boot:run
```
*The server will be active at: `http://localhost:8080`.*
*Note: On the first run, the `DataSeeder` will automatically populate the database with mock data.*

3. **Start the Frontend (Flutter)**
Navigate to the `heavyroute_app` directory and run these commands to fetch dependencies and launch the web app:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

---

## API Documentation
Once the backend is running, the Swagger/OpenAPI documentation is automatically generated and accessible at:
`http://localhost:8080/swagger-ui.html`
