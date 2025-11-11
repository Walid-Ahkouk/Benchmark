package com.example.benchmark.config;

import jakarta.ws.rs.ApplicationPath;
import org.glassfish.jersey.server.ResourceConfig;

@ApplicationPath("/api")
public class JaxRsConfig extends ResourceConfig {
    public JaxRsConfig() {
        // Register resources explicitly to avoid classpath scanning issues
        register(com.example.benchmark.resource.ItemResource.class);
        register(com.example.benchmark.resource.CategoryResource.class);
    }
}
