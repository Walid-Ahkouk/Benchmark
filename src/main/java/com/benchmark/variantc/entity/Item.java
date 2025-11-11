package com.benchmark.variantc.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Item entity representing a product item in the benchmark database.
 */
@Entity
@Table(name = "items")
public class Item {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "sku", nullable = false, unique = true, length = 100)
    private String sku;

    @Column(name = "name", nullable = false, length = 255)
    private String name;

    @Column(name = "price", nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(name = "stock", nullable = false)
    private Integer stock;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = true)
    private Category category;

    // ========================================
    // Constructors
    // ========================================

    public Item() {
    }

    public Item(String sku, String name, BigDecimal price, Integer stock) {
        this.sku = sku;
        this.name = name;
        this.price = price;
        this.stock = stock;
        this.updatedAt = LocalDateTime.now();
    }

    public Item(String sku, String name, BigDecimal price, Integer stock, Category category) {
        this.sku = sku;
        this.name = name;
        this.price = price;
        this.stock = stock;
        this.category = category;
        this.updatedAt = LocalDateTime.now();
    }

    // ========================================
    // Lifecycle Callbacks
    // ========================================

    @PrePersist
    protected void onCreate() {
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // ========================================
    // Getters and Setters
    // ========================================

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public Integer getStock() {
        return stock;
    }

    public void setStock(Integer stock) {
        this.stock = stock;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    // ========================================
    // Object Methods
    // ========================================

    @Override
    public String toString() {
        return "Item{" +
                "id=" + id +
                ", sku='" + sku + '\'' +
                ", name='" + name + '\'' +
                ", price=" + price +
                ", stock=" + stock +
                ", updatedAt=" + updatedAt +
                ", categoryId=" + (category != null ? category.getId() : null) +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Item)) return false;
        Item item = (Item) o;
        return id != null && id.equals(item.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
