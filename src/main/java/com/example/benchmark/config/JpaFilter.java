package com.example.benchmark.config;

import jakarta.persistence.EntityManager;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;

@WebFilter("/*")
public class JpaFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        EntityManager em = null;
        try {
            em = JpaUtil.getEntityManagerFactory().createEntityManager();
            JpaManager.setEntityManager(em);
            
            chain.doFilter(request, response);

        } finally {
            JpaManager.clearEntityManager();
        }
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No-op
    }

    @Override
    public void destroy() {
        // No-op
    }
}
