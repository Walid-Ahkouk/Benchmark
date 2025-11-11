package com.benchmark.variantc.repository;

import com.benchmark.variantc.entity.Item;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository interface for Item entity.
 * Extends JpaRepository to provide CRUD operations and query methods.
 */
@Repository
public interface ItemRepository extends JpaRepository<Item, Long> {

    /**
     * Find an item by its unique SKU.
     *
     * @param sku the item SKU
     * @return an Optional containing the item if found
     */
    Optional<Item> findBySku(String sku);

    /**
     * Check if an item exists by its SKU.
     *
     * @param sku the item SKU
     * @return true if an item with the given SKU exists
     */
    boolean existsBySku(String sku);

    /**
     * Find all items belonging to a specific category (with pagination).
     * This method implements the relational filter requirement.
     *
     * @param categoryId the category ID to filter by
     * @param pageable pagination information
     * @return a page of items belonging to the specified category
     */
    Page<Item> findByCategoryId(Long categoryId, Pageable pageable);
}
