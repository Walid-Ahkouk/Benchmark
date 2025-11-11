package com.example.benchmark.config;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

public class JpaUtil {

    private static final String PERSISTENCE_UNIT_NAME = "benchmark-pu";
    private static final EntityManagerFactory factory;

    static {
        try {
            System.out.println(">>> Initialisation de l'EntityManagerFactory JPA...");
            factory = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);
            System.out.println(">>> EntityManagerFactory initialisé avec succès !");
        } catch (Throwable ex) {
            System.err.println(">>> L'initialisation de l'EntityManagerFactory a échoué !");
            throw new ExceptionInInitializerError(ex);
        }
    }

    public static EntityManagerFactory getEntityManagerFactory() {
        return factory;
    }

    public static void shutdown() {
        if (factory != null && factory.isOpen()) {
            System.out.println(">>> Fermeture de l'EntityManagerFactory JPA...");
            factory.close();
            System.out.println(">>> EntityManagerFactory fermé.");
        }
    }
}
