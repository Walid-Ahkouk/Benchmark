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

@Path("/items")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ItemResource {

    @GET
    public Response getAllItems(@QueryParam("page") @DefaultValue("1") int page,
                                @QueryParam("size") @DefaultValue("10") int size,
                                @QueryParam("categoryId") Long categoryId) {
        EntityManager em = JpaManager.getEntityManager();
        try {
            String qlString = "SELECT i FROM Item i";
            if (categoryId != null) {
                qlString += " WHERE i.category.id = :categoryId";
            }
            TypedQuery<Item> query = em.createQuery(qlString, Item.class);
            if (categoryId != null) {
                query.setParameter("categoryId", categoryId);
            }
            query.setFirstResult((page - 1) * size);
            query.setMaxResults(size);
            List<Item> items = query.getResultList();
            return Response.ok(items).build();
        } finally {
            // em.close() is handled by JpaFilter
        }
    }

    @GET
    @Path("/{id}")
    public Response getItemById(@PathParam("id") Long id) {
        EntityManager em = JpaManager.getEntityManager();
        try {
            Item item = em.find(Item.class, id);
            if (item == null) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            return Response.ok(item).build();
        } finally {
            // em.close() is handled by JpaFilter
        }
    }

    @POST
    public Response createItem(Item item, @QueryParam("categoryId") Long categoryId) {
        if (categoryId == null) {
            return Response.status(Response.Status.BAD_REQUEST).entity("categoryId is required.").build();
        }
        EntityManager em = JpaManager.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Category category = em.find(Category.class, categoryId);
            if (category == null) {
                return Response.status(Response.Status.BAD_REQUEST).entity("Category not found.").build();
            }
            item.setCategory(category);
            em.persist(item);
            tx.commit();
            return Response.status(Response.Status.CREATED).entity(item).build();
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
    public Response updateItem(@PathParam("id") Long id, Item updatedItem, @QueryParam("categoryId") Long categoryId) {
        EntityManager em = JpaManager.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Item item = em.find(Item.class, id);
            if (item == null) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            item.setSku(updatedItem.getSku());
            item.setName(updatedItem.getName());
            item.setPrice(updatedItem.getPrice());
            item.setStock(updatedItem.getStock());

            if (categoryId != null) {
                Category category = em.find(Category.class, categoryId);
                if (category == null) {
                    return Response.status(Response.Status.BAD_REQUEST).entity("Category not found.").build();
                }
                item.setCategory(category);
            }

            em.merge(item);
            tx.commit();
            return Response.ok(item).build();
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
    public Response deleteItem(@PathParam("id") Long id) {
        EntityManager em = JpaManager.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Item item = em.find(Item.class, id);
            if (item == null) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            em.remove(item);
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
}