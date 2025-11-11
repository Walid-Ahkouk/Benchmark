-- ========================================
-- Database Initialization Script
-- Variant C - Spring Boot Benchmark
-- ========================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS items CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- Create categories table
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create items table
CREATE TABLE items (
    id BIGSERIAL PRIMARY KEY,
    sku VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL
);

-- Create indexes for performance
CREATE INDEX idx_items_category_id ON items(category_id);
CREATE INDEX idx_items_sku ON items(sku);
CREATE INDEX idx_categories_code ON categories(code);

-- ========================================
-- Insert Sample Data
-- ========================================

-- Insert Categories
INSERT INTO categories (code, name, updated_at) VALUES
('ELEC', 'Electronics', CURRENT_TIMESTAMP),
('CLOTH', 'Clothing', CURRENT_TIMESTAMP),
('BOOKS', 'Books', CURRENT_TIMESTAMP),
('HOME', 'Home & Garden', CURRENT_TIMESTAMP),
('SPORTS', 'Sports & Outdoors', CURRENT_TIMESTAMP),
('TOYS', 'Toys & Games', CURRENT_TIMESTAMP),
('FOOD', 'Food & Beverages', CURRENT_TIMESTAMP),
('HEALTH', 'Health & Beauty', CURRENT_TIMESTAMP),
('AUTO', 'Automotive', CURRENT_TIMESTAMP),
('MUSIC', 'Music & Instruments', CURRENT_TIMESTAMP);

-- Insert Items for Electronics
INSERT INTO items (sku, name, price, stock, category_id, updated_at) VALUES
('ELEC-001', 'Gaming Laptop 15"', 1299.99, 50, 1, CURRENT_TIMESTAMP),
('ELEC-002', 'Wireless Mouse', 29.99, 200, 1, CURRENT_TIMESTAMP),
('ELEC-003', 'Mechanical Keyboard RGB', 89.99, 150, 1, CURRENT_TIMESTAMP),
('ELEC-004', '4K Monitor 27"', 399.99, 75, 1, CURRENT_TIMESTAMP),
('ELEC-005', 'USB-C Hub 7-in-1', 49.99, 300, 1, CURRENT_TIMESTAMP),
('ELEC-006', 'Noise Cancelling Headphones', 199.99, 120, 1, CURRENT_TIMESTAMP),
('ELEC-007', 'Smartphone 128GB', 699.99, 100, 1, CURRENT_TIMESTAMP),
('ELEC-008', 'Tablet 10" WiFi', 349.99, 80, 1, CURRENT_TIMESTAMP),
('ELEC-009', 'Smartwatch Fitness Tracker', 249.99, 150, 1, CURRENT_TIMESTAMP),
('ELEC-010', 'Bluetooth Speaker Portable', 79.99, 200, 1, CURRENT_TIMESTAMP);

-- Insert Items for Clothing
INSERT INTO items (sku, name, price, stock, category_id, updated_at) VALUES
('CLOTH-001', 'Men''s Cotton T-Shirt', 19.99, 500, 2, CURRENT_TIMESTAMP),
('CLOTH-002', 'Women''s Denim Jeans', 59.99, 300, 2, CURRENT_TIMESTAMP),
('CLOTH-003', 'Unisex Hoodie', 44.99, 250, 2, CURRENT_TIMESTAMP),
('CLOTH-004', 'Running Shoes Size 10', 89.99, 150, 2, CURRENT_TIMESTAMP),
('CLOTH-005', 'Leather Jacket Men', 199.99, 50, 2, CURRENT_TIMESTAMP),
('CLOTH-006', 'Summer Dress Women', 39.99, 200, 2, CURRENT_TIMESTAMP),
('CLOTH-007', 'Winter Coat Waterproof', 129.99, 100, 2, CURRENT_TIMESTAMP),
('CLOTH-008', 'Sports Bra Set', 29.99, 300, 2, CURRENT_TIMESTAMP),
('CLOTH-009', 'Formal Suit Men', 299.99, 75, 2, CURRENT_TIMESTAMP),
('CLOTH-010', 'Casual Sneakers', 69.99, 250, 2, CURRENT_TIMESTAMP);

-- Insert Items for Books
INSERT INTO items (sku, name, price, stock, category_id, updated_at) VALUES
('BOOK-001', 'The Art of Programming', 49.99, 200, 3, CURRENT_TIMESTAMP),
('BOOK-002', 'Introduction to Algorithms', 89.99, 150, 3, CURRENT_TIMESTAMP),
('BOOK-003', 'Clean Code Handbook', 39.99, 300, 3, CURRENT_TIMESTAMP),
('BOOK-004', 'Database Design Fundamentals', 59.99, 100, 3, CURRENT_TIMESTAMP),
('BOOK-005', 'Web Development Complete Guide', 69.99, 180, 3, CURRENT_TIMESTAMP),
('BOOK-006', 'Fiction Novel Bestseller', 24.99, 400, 3, CURRENT_TIMESTAMP),
('BOOK-007', 'History of Technology', 34.99, 120, 3, CURRENT_TIMESTAMP),
('BOOK-008', 'Cooking Recipes Collection', 29.99, 250, 3, CURRENT_TIMESTAMP),
('BOOK-009', 'Travel Guide Europe', 19.99, 180, 3, CURRENT_TIMESTAMP),
('BOOK-010', 'Children''s Picture Book', 14.99, 500, 3, CURRENT_TIMESTAMP);

-- Insert Items for Home & Garden
INSERT INTO items (sku, name, price, stock, category_id, updated_at) VALUES
('HOME-001', 'Electric Vacuum Cleaner', 149.99, 100, 4, CURRENT_TIMESTAMP),
('HOME-002', 'Coffee Maker 12-Cup', 79.99, 150, 4, CURRENT_TIMESTAMP),
('HOME-003', 'LED Desk Lamp Adjustable', 34.99, 200, 4, CURRENT_TIMESTAMP),
('HOME-004', 'Garden Tool Set 10-Piece', 59.99, 80, 4, CURRENT_TIMESTAMP),
('HOME-005', 'Air Purifier HEPA Filter', 199.99, 60, 4, CURRENT_TIMESTAMP),
('HOME-006', 'Kitchen Knife Set', 89.99, 120, 4, CURRENT_TIMESTAMP),
('HOME-007', 'Bedding Set Queen Size', 99.99, 150, 4, CURRENT_TIMESTAMP),
('HOME-008', 'Wall Clock Modern Design', 39.99, 200, 4, CURRENT_TIMESTAMP),
('HOME-009', 'Storage Boxes Set of 5', 29.99, 300, 4, CURRENT_TIMESTAMP),
('HOME-010', 'Indoor Plant Pot Ceramic', 24.99, 250, 4, CURRENT_TIMESTAMP);

-- Insert Items for Sports & Outdoors
INSERT INTO items (sku, name, price, stock, category_id, updated_at) VALUES
('SPORT-001', 'Yoga Mat Non-Slip', 29.99, 300, 5, CURRENT_TIMESTAMP),
('SPORT-002', 'Dumbbell Set 20kg', 79.99, 150, 5, CURRENT_TIMESTAMP),
('SPORT-003', 'Camping Tent 4-Person', 199.99, 50, 5, CURRENT_TIMESTAMP),
('SPORT-004', 'Bicycle 21-Speed Mountain', 449.99, 75, 5, CURRENT_TIMESTAMP),
('SPORT-005', 'Soccer Ball Professional', 39.99, 200, 5, CURRENT_TIMESTAMP),
('SPORT-006', 'Swimming Goggles Anti-Fog', 19.99, 400, 5, CURRENT_TIMESTAMP),
('SPORT-007', 'Hiking Backpack 50L', 89.99, 120, 5, CURRENT_TIMESTAMP),
('SPORT-008', 'Tennis Racket Carbon Fiber', 149.99, 100, 5, CURRENT_TIMESTAMP),
('SPORT-009', 'Resistance Bands Set', 24.99, 350, 5, CURRENT_TIMESTAMP),
('SPORT-010', 'Water Bottle Stainless 1L', 19.99, 500, 5, CURRENT_TIMESTAMP);

-- Insert Items for Toys & Games
INSERT INTO items (sku, name, price, stock, category_id, updated_at) VALUES
('TOY-001', 'Building Blocks Set 500pcs', 49.99, 200, 6, CURRENT_TIMESTAMP),
('TOY-002', 'Remote Control Car', 69.99, 150, 6, CURRENT_TIMESTAMP),
('TOY-003', 'Board Game Strategy', 34.99, 250, 6, CURRENT_TIMESTAMP),
('TOY-004', 'Puzzle 1000 Pieces', 24.99, 300, 6, CURRENT_TIMESTAMP),
('TOY-005', 'Action Figure Collectible', 29.99, 400, 6, CURRENT_TIMESTAMP),
('TOY-006', 'Doll House Wooden', 89.99, 80, 6, CURRENT_TIMESTAMP),
('TOY-007', 'Educational Tablet Kids', 99.99, 120, 6, CURRENT_TIMESTAMP),
('TOY-008', 'Plush Toy Teddy Bear', 19.99, 500, 6, CURRENT_TIMESTAMP),
('TOY-009', 'Science Kit Experiment', 44.99, 150, 6, CURRENT_TIMESTAMP),
('TOY-010', 'Art Supplies Set', 34.99, 200, 6, CURRENT_TIMESTAMP);

-- Insert Items for Food & Beverages
INSERT INTO items (sku, name, price, stock, category_id, updated_at) VALUES
('FOOD-001', 'Organic Coffee Beans 1kg', 24.99, 300, 7, CURRENT_TIMESTAMP),
('FOOD-002', 'Green Tea Premium 100 Bags', 14.99, 400, 7, CURRENT_TIMESTAMP),
('FOOD-003', 'Protein Powder Chocolate 2kg', 49.99, 200, 7, CURRENT_TIMESTAMP),
('FOOD-004', 'Olive Oil Extra Virgin 1L', 19.99, 250, 7, CURRENT_TIMESTAMP),
('FOOD-005', 'Honey Raw Organic 500g', 16.99, 350, 7, CURRENT_TIMESTAMP),
('FOOD-006', 'Dark Chocolate Bar 85%', 4.99, 600, 7, CURRENT_TIMESTAMP),
('FOOD-007', 'Granola Cereal Mix 500g', 9.99, 400, 7, CURRENT_TIMESTAMP),
('FOOD-008', 'Almond Butter Natural 1kg', 29.99, 180, 7, CURRENT_TIMESTAMP),
('FOOD-009', 'Energy Drink Sugar-Free 24pk', 34.99, 220, 7, CURRENT_TIMESTAMP),
('FOOD-010', 'Pasta Whole Wheat 5kg', 19.99, 300, 7, CURRENT_TIMESTAMP);

-- Insert Items for Health & Beauty
INSERT INTO items (sku, name, price, stock, category_id, updated_at) VALUES
('HEALTH-001', 'Vitamin C Supplement 60 Caps', 19.99, 300, 8, CURRENT_TIMESTAMP),
('HEALTH-002', 'Face Cream Anti-Aging 50ml', 39.99, 200, 8, CURRENT_TIMESTAMP),
('HEALTH-003', 'Electric Toothbrush', 79.99, 150, 8, CURRENT_TIMESTAMP),
('HEALTH-004', 'Hair Dryer Professional', 59.99, 180, 8, CURRENT_TIMESTAMP),
('HEALTH-005', 'Massage Gun Deep Tissue', 129.99, 100, 8, CURRENT_TIMESTAMP),
('HEALTH-006', 'Aromatherapy Diffuser', 34.99, 250, 8, CURRENT_TIMESTAMP),
('HEALTH-007', 'Shampoo Organic Sulfate-Free', 16.99, 400, 8, CURRENT_TIMESTAMP),
('HEALTH-008', 'Makeup Brush Set 12pcs', 29.99, 300, 8, CURRENT_TIMESTAMP),
('HEALTH-009', 'Fitness Scale Smart BMI', 49.99, 200, 8, CURRENT_TIMESTAMP),
('HEALTH-010', 'Sunscreen SPF 50+ 200ml', 24.99, 350, 8, CURRENT_TIMESTAMP);

-- Insert Items for Automotive
INSERT INTO items (sku, name, price, stock, category_id, updated_at) VALUES
('AUTO-001', 'Car Phone Holder Magnetic', 19.99, 400, 9, CURRENT_TIMESTAMP),
('AUTO-002', 'Jump Starter Power Bank', 89.99, 120, 9, CURRENT_TIMESTAMP),
('AUTO-003', 'Dash Cam 1080p', 79.99, 150, 9, CURRENT_TIMESTAMP),
('AUTO-004', 'Tire Pressure Gauge Digital', 14.99, 500, 9, CURRENT_TIMESTAMP),
('AUTO-005', 'Car Vacuum Cleaner Portable', 49.99, 200, 9, CURRENT_TIMESTAMP),
('AUTO-006', 'Floor Mats All-Weather Set', 59.99, 180, 9, CURRENT_TIMESTAMP),
('AUTO-007', 'LED Headlight Bulbs H7', 39.99, 250, 9, CURRENT_TIMESTAMP),
('AUTO-008', 'Car Cover Waterproof XL', 69.99, 100, 9, CURRENT_TIMESTAMP),
('AUTO-009', 'Bluetooth FM Transmitter', 24.99, 350, 9, CURRENT_TIMESTAMP),
('AUTO-010', 'Seat Cushion Memory Foam', 34.99, 300, 9, CURRENT_TIMESTAMP);

-- Insert Items for Music & Instruments
INSERT INTO items (sku, name, price, stock, category_id, updated_at) VALUES
('MUSIC-001', 'Acoustic Guitar Beginner', 149.99, 80, 10, CURRENT_TIMESTAMP),
('MUSIC-002', 'Digital Piano 88 Keys', 499.99, 40, 10, CURRENT_TIMESTAMP),
('MUSIC-003', 'Microphone Condenser USB', 79.99, 150, 10, CURRENT_TIMESTAMP),
('MUSIC-004', 'Drum Set Electronic', 399.99, 50, 10, CURRENT_TIMESTAMP),
('MUSIC-005', 'Violin 4/4 Full Size', 199.99, 60, 10, CURRENT_TIMESTAMP),
('MUSIC-006', 'Ukulele Soprano', 49.99, 200, 10, CURRENT_TIMESTAMP),
('MUSIC-007', 'Music Stand Adjustable', 24.99, 300, 10, CURRENT_TIMESTAMP),
('MUSIC-008', 'Guitar Strings Set 6', 9.99, 600, 10, CURRENT_TIMESTAMP),
('MUSIC-009', 'Audio Interface 2-Channel', 129.99, 100, 10, CURRENT_TIMESTAMP),
('MUSIC-010', 'Metronome Digital', 19.99, 250, 10, CURRENT_TIMESTAMP);

-- ========================================
-- Verify Data
-- ========================================

-- Count categories
SELECT 'Total Categories:', COUNT(*) FROM categories;

-- Count items
SELECT 'Total Items:', COUNT(*) FROM items;

-- Count items per category
SELECT c.code, c.name, COUNT(i.id) as item_count
FROM categories c
LEFT JOIN items i ON c.id = i.category_id
GROUP BY c.id, c.code, c.name
ORDER BY c.code;

-- Database initialization complete
