package com.benchmark.variantc.controller;

import com.benchmark.variantc.entity.Category;
import com.benchmark.variantc.entity.Item;
import com.benchmark.variantc.repository.CategoryRepository;
import com.benchmark.variantc.repository.ItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * REST Controller for Category endpoints.
 * Provides CRUD operations for categories and relational queries.
 */
@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    private final CategoryRepository categoryRepository;
    private final ItemRepository itemRepository;

    @Autowired
    public CategoryController(CategoryRepository categoryRepository, ItemRepository itemRepository) {
        this.categoryRepository = categoryRepository;
        this.itemRepository = itemRepository;
    }

    /**
     * GET /api/categories
     * Retrieve all categories with pagination.
     *
     * @param pageable pagination parameters (page, size, sort)
     * @return paginated list of categories
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllCategories(Pageable pageable) {
        Page<Category> categoryPage = categoryRepository.findAll(pageable);

        Map<String, Object> response = new HashMap<>();
        response.put("categories", categoryPage.getContent());
        response.put("currentPage", categoryPage.getNumber());
        response.put("totalItems", categoryPage.getTotalElements());
        response.put("totalPages", categoryPage.getTotalPages());
        response.put("pageSize", categoryPage.getSize());

        return ResponseEntity.ok(response);
    }

    /**
     * GET /api/categories/{id}
     * Retrieve a single category by ID.
     *
     * @param id the category ID
     * @return the category if found, 404 otherwise
     */
    @GetMapping("/{id}")
    public ResponseEntity<Category> getCategoryById(@PathVariable Long id) {
        return categoryRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * POST /api/categories
     * Create a new category.
     *
     * @param category the category to create
     * @return the created category with 201 status
     */
    @PostMapping
    public ResponseEntity<Category> createCategory(@RequestBody Category category) {
        // Check if code already exists
        if (category.getCode() != null && categoryRepository.existsByCode(category.getCode())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }

        Category savedCategory = categoryRepository.save(category);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedCategory);
    }

    /**
     * PUT /api/categories/{id}
     * Update an existing category.
     *
     * @param id the category ID
     * @param categoryDetails the updated category data
     * @return the updated category if found, 404 otherwise
     */
    @PutMapping("/{id}")
    public ResponseEntity<Category> updateCategory(
            @PathVariable Long id,
            @RequestBody Category categoryDetails) {

        return categoryRepository.findById(id)
                .map(category -> {
                    // Check if new code conflicts with another category
                    if (categoryDetails.getCode() != null &&
                        !categoryDetails.getCode().equals(category.getCode()) &&
                        categoryRepository.existsByCode(categoryDetails.getCode())) {
                        return ResponseEntity.status(HttpStatus.CONFLICT).<Category>build();
                    }

                    if (categoryDetails.getCode() != null) {
                        category.setCode(categoryDetails.getCode());
                    }
                    if (categoryDetails.getName() != null) {
                        category.setName(categoryDetails.getName());
                    }

                    Category updatedCategory = categoryRepository.save(category);
                    return ResponseEntity.ok(updatedCategory);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * DELETE /api/categories/{id}
     * Delete a category.
     *
     * @param id the category ID
     * @return 204 if deleted, 404 if not found
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategory(@PathVariable Long id) {
        if (!categoryRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }

        categoryRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * GET /api/categories/{id}/items
     * Retrieve all items belonging to a specific category (with pagination).
     * This implements the relational pagination requirement.
     *
     * @param id the category ID
     * @param pageable pagination parameters
     * @return paginated list of items for the category
     */
    @GetMapping("/{id}/items")
    public ResponseEntity<Map<String, Object>> getItemsByCategory(
            @PathVariable Long id,
            Pageable pageable) {

        // Check if category exists
        if (!categoryRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }

        Page<Item> itemPage = itemRepository.findByCategoryId(id, pageable);

        Map<String, Object> response = new HashMap<>();
        response.put("items", itemPage.getContent());
        response.put("currentPage", itemPage.getNumber());
        response.put("totalItems", itemPage.getTotalElements());
        response.put("totalPages", itemPage.getTotalPages());
        response.put("pageSize", itemPage.getSize());
        response.put("categoryId", id);

        return ResponseEntity.ok(response);
    }
}
