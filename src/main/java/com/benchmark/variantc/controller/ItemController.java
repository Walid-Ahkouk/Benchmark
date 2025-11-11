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
 * REST Controller for Item endpoints.
 * Provides CRUD operations for items and filtering by category.
 */
@RestController
@RequestMapping("/api/items")
public class ItemController {

    private final ItemRepository itemRepository;
    private final CategoryRepository categoryRepository;

    @Autowired
    public ItemController(ItemRepository itemRepository, CategoryRepository categoryRepository) {
        this.itemRepository = itemRepository;
        this.categoryRepository = categoryRepository;
    }

    /**
     * GET /api/items
     * Retrieve all items with pagination.
     * Supports optional filtering by categoryId query parameter.
     *
     * @param categoryId optional category ID to filter items
     * @param pageable pagination parameters (page, size, sort)
     * @return paginated list of items
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllItems(
            @RequestParam(required = false) Long categoryId,
            Pageable pageable) {

        Page<Item> itemPage;

        // Apply category filter if provided
        if (categoryId != null) {
            itemPage = itemRepository.findByCategoryId(categoryId, pageable);
        } else {
            itemPage = itemRepository.findAll(pageable);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("items", itemPage.getContent());
        response.put("currentPage", itemPage.getNumber());
        response.put("totalItems", itemPage.getTotalElements());
        response.put("totalPages", itemPage.getTotalPages());
        response.put("pageSize", itemPage.getSize());

        if (categoryId != null) {
            response.put("categoryId", categoryId);
        }

        return ResponseEntity.ok(response);
    }

    /**
     * GET /api/items/{id}
     * Retrieve a single item by ID.
     *
     * @param id the item ID
     * @return the item if found, 404 otherwise
     */
    @GetMapping("/{id}")
    public ResponseEntity<Item> getItemById(@PathVariable Long id) {
        return itemRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * POST /api/items
     * Create a new item.
     *
     * @param itemRequest the item data (includes categoryId)
     * @return the created item with 201 status
     */
    @PostMapping
    public ResponseEntity<Item> createItem(@RequestBody Map<String, Object> itemRequest) {
        // Check if SKU already exists
        String sku = (String) itemRequest.get("sku");
        if (sku != null && itemRepository.existsBySku(sku)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }

        Item item = new Item();
        item.setSku(sku);
        item.setName((String) itemRequest.get("name"));

        // Handle price conversion
        Object priceObj = itemRequest.get("price");
        if (priceObj != null) {
            item.setPrice(new java.math.BigDecimal(priceObj.toString()));
        }

        // Handle stock conversion
        Object stockObj = itemRequest.get("stock");
        if (stockObj != null) {
            item.setStock(Integer.parseInt(stockObj.toString()));
        }

        // Handle category association if provided
        Object categoryIdObj = itemRequest.get("categoryId");
        if (categoryIdObj != null) {
            Long categoryId = Long.parseLong(categoryIdObj.toString());
            Category category = categoryRepository.findById(categoryId).orElse(null);
            if (category == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
            }
            item.setCategory(category);
        }

        Item savedItem = itemRepository.save(item);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedItem);
    }

    /**
     * PUT /api/items/{id}
     * Update an existing item.
     *
     * @param id the item ID
     * @param itemRequest the updated item data
     * @return the updated item if found, 404 otherwise
     */
    @PutMapping("/{id}")
    public ResponseEntity<Item> updateItem(
            @PathVariable Long id,
            @RequestBody Map<String, Object> itemRequest) {

        return itemRepository.findById(id)
                .map(item -> {
                    // Check if new SKU conflicts with another item
                    String newSku = (String) itemRequest.get("sku");
                    if (newSku != null &&
                        !newSku.equals(item.getSku()) &&
                        itemRepository.existsBySku(newSku)) {
                        return ResponseEntity.status(HttpStatus.CONFLICT).<Item>build();
                    }

                    // Update fields if provided
                    if (newSku != null) {
                        item.setSku(newSku);
                    }

                    if (itemRequest.containsKey("name")) {
                        item.setName((String) itemRequest.get("name"));
                    }

                    if (itemRequest.containsKey("price")) {
                        Object priceObj = itemRequest.get("price");
                        if (priceObj != null) {
                            item.setPrice(new java.math.BigDecimal(priceObj.toString()));
                        }
                    }

                    if (itemRequest.containsKey("stock")) {
                        Object stockObj = itemRequest.get("stock");
                        if (stockObj != null) {
                            item.setStock(Integer.parseInt(stockObj.toString()));
                        }
                    }

                    // Handle category update if provided
                    if (itemRequest.containsKey("categoryId")) {
                        Object categoryIdObj = itemRequest.get("categoryId");
                        if (categoryIdObj == null) {
                            item.setCategory(null);
                        } else {
                            Long categoryId = Long.parseLong(categoryIdObj.toString());
                            Category category = categoryRepository.findById(categoryId).orElse(null);
                            if (category == null) {
                                return ResponseEntity.status(HttpStatus.BAD_REQUEST).<Item>build();
                            }
                            item.setCategory(category);
                        }
                    }

                    Item updatedItem = itemRepository.save(item);
                    return ResponseEntity.ok(updatedItem);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * DELETE /api/items/{id}
     * Delete an item.
     *
     * @param id the item ID
     * @return 204 if deleted, 404 if not found
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long id) {
        if (!itemRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }

        itemRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
