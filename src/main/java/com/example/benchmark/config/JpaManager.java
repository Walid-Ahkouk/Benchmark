package com.example.benchmark.config;

import jakarta.persistence.EntityManager;

public class JpaManager {

    private static final ThreadLocal<EntityManager> emThreadLocal = new ThreadLocal<>();

    public static EntityManager getEntityManager() {
        EntityManager em = emThreadLocal.get();
        if (em == null || !em.isOpen()) {
            throw new IllegalStateException("EntityManager is not available or has been closed. Ensure JpaFilter is configured correctly.");
        }
        return em;
    }

    public static void setEntityManager(EntityManager em) {
        emThreadLocal.set(em);
    }

    public static void clearEntityManager() {
        EntityManager em = emThreadLocal.get();
        if (em != null && em.isOpen()) {
            em.close();
        }
        emThreadLocal.remove();
    }
}
