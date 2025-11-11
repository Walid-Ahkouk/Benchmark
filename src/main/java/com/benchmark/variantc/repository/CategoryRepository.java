package com.benchmark.variantc.repository;

import com.benchmark.variantc.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository interface for Category entity.
 * Extends JpaRepository to provide CRUD operations and query methods.
 */
@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    /**
     * Find a category by its unique code.
     *
     * @param code the category code
     * @return an Optional containing the category if found
     */
    Optional<Category> findByCode(String code);

    /**
     * Check if a category exists by its code.
     *
     * @param code the category code
     * @return true if a category with the given code exists
     */
    boolean existsByCode(String code);
}
