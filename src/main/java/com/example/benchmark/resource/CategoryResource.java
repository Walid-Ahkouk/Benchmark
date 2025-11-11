package com.example.benchmark.resource;

import com.example.benchmark.config.JpaManager;
import com.example.benchmark.model.Category;
import com.example.benchmark.model.Item;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.List;

@Path("/categories")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CategoryResource {

    @GET
    public Response getAllCategories(@QueryParam("page") @DefaultValue("1") int page,
                                     @QueryParam("size") @DefaultValue("10") int size) {
        EntityManager em = JpaManager.getEntityManager();
        try {
            TypedQuery<Category> query = em.createQuery("SELECT c FROM Category c", Category.class);
            query.setFirstResult((page - 1) * size);
            query.setMaxResults(size);
            List<Category> categories = query.getResultList();
            return Response.ok(categories).build();
        } finally {
            // em.close() is handled by JpaFilter
        }
    }

    @GET
    @Path("/{id}")
    public Response getCategoryById(@PathParam("id") Long id) {
        EntityManager em = JpaManager.getEntityManager();
        try {
            Category category = em.find(Category.class, id);
            if (category == null) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            return Response.ok(category).build();
        } finally {
            // em.close() is handled by JpaFilter
        }
    }

    @POST
    public Response createCategory(Category category) {
        EntityManager em = JpaManager.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(category);
            tx.commit();
            return Response.status(Response.Status.CREATED).entity(category).build();
        } catch (Exception e) {
            if (tx.isActive()) {
                tx.rollback();
            }
            return Response.serverError().entity(e.getMessage()).build();
        } finally {
            // em.close() is handled by JpaFilter
        }
    }

    @PUT
    @Path("/{id}")
    public Response updateCategory(@PathParam("id") Long id, Category updatedCategory) {
        EntityManager em = JpaManager.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Category category = em.find(Category.class, id);
            if (category == null) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            category.setCode(updatedCategory.getCode());
            category.setName(updatedCategory.getName());
            em.merge(category);
            tx.commit();
            return Response.ok(category).build();
        } catch (Exception e) {
            if (tx.isActive()) {
                tx.rollback();
            }
            return Response.serverError().entity(e.getMessage()).build();
        } finally {
            // em.close() is handled by JpaFilter
        }
    }

    @DELETE
    @Path("/{id}")
    public Response deleteCategory(@PathParam("id") Long id) {
        EntityManager em = JpaManager.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Category category = em.find(Category.class, id);
            if (category == null) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            em.remove(category);
            tx.commit();
            return Response.noContent().build();
        } catch (Exception e) {
            if (tx.isActive()) {
                tx.rollback();
            }
            return Response.serverError().entity(e.getMessage()).build();
        } finally {
            // em.close() is handled by JpaFilter
        }
    }

    @GET
    @Path("/{id}/items")
    public Response getItemsForCategory(@PathParam("id") Long categoryId,
                                        @QueryParam("page") @DefaultValue("1") int page,
                                        @QueryParam("size") @DefaultValue("10") int size) {
        EntityManager em = JpaManager.getEntityManager();
        try {
            TypedQuery<Item> query = em.createQuery("SELECT i FROM Item i WHERE i.category.id = :categoryId", Item.class);
            query.setParameter("categoryId", categoryId);
            query.setFirstResult((page - 1) * size);
            query.setMaxResults(size);
            List<Item> items = query.getResultList();
            return Response.ok(items).build();
        } finally {
            // em.close() is handled by JpaFilter
        }
    }
}