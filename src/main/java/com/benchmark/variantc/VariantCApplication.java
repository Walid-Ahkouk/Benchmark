package com.benchmark.variantc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main Spring Boot Application class for Variant C Benchmark.
 *
 * This application implements a performance benchmark using:
 * - Spring Boot 3.x
 * - Spring MVC (@RestController) for REST endpoints
 * - Spring Data JPA with Hibernate for persistence
 * - PostgreSQL database
 * - HikariCP connection pooling
 * - Spring Boot Actuator for monitoring
 * - Prometheus metrics export
 */
@SpringBootApplication
public class VariantCApplication {

    public static void main(String[] args) {
        SpringApplication.run(VariantCApplication.class, args);
    }
}
