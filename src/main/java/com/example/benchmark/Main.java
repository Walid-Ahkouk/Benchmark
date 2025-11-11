package com.example.benchmark;



import com.example.benchmark.config.JpaFilter;
import jakarta.servlet.DispatcherType;
import java.util.EnumSet;
import org.eclipse.jetty.servlet.FilterHolder;
import com.example.benchmark.config.JaxRsConfig;
import com.example.benchmark.config.JpaUtil;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.glassfish.jersey.servlet.ServletContainer;

public class Main {

    public static void main(String[] args) {
        // 1. Initialiser JPA.
        try {
            JpaUtil.getEntityManagerFactory();
        } catch (Throwable ex) {
            System.err.println(">>> L'application n'a pas pu démarrer : impossible d'initialiser la connexion JPA.");
            return;
        }

        // 2. Ajouter un "hook" pour fermer proprement JpaUtil.
        Runtime.getRuntime().addShutdownHook(new Thread(JpaUtil::shutdown));

        // 3. Démarrer le serveur web.
        Server server = new Server(8080);

        ServletContextHandler context = new ServletContextHandler(server, "/");
        
        // 4. Enregistrer le filtre JPA pour gérer l'EntityManager par requête
        context.addFilter(new FilterHolder(new JpaFilter()), "/api/*", EnumSet.of(DispatcherType.REQUEST));

        ServletHolder holder = new ServletHolder(new ServletContainer(new JaxRsConfig()));
        context.addServlet(holder, "/api/*");

        try {
            System.out.println(">>> DÉMARRAGE DU SERVEUR WEB JETTY...");
            server.start();
            System.out.println(">>> SERVEUR DÉMARRÉ. Visitez http://localhost:8080/api/...");
            server.join();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        } finally {
            server.destroy();
        }
    }
}
