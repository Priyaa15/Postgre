-- =====================================================
-- E-COMMERCE ANALYTICS PROJECT - PostgreSQL Features
-- =====================================================
-- This project demonstrates:
-- 1. Arrays for storing multiple values
-- 2. JSON columns for flexible data structures
-- 3. Window functions for analytics
-- =====================================================

-- Create the database schema
CREATE SCHEMA IF NOT EXISTS ecommerce;
SET search_path TO ecommerce;

-- =====================================================
-- 1. TABLES WITH ARRAYS AND JSON COLUMNS
-- =====================================================

-- Products table with arrays and JSON
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    tags TEXT[], -- Array of tags
    price DECIMAL(10,2),
    specifications JSONB, -- JSON for flexible product specs
    images TEXT[], -- Array of image URLs
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers table with JSON for preferences
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    preferences JSONB, -- JSON for user preferences
    purchase_history INTEGER[], -- Array of product IDs
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    shipping_address JSONB, -- JSON for address structure
    total_amount DECIMAL(10,2),
    payment_info JSONB -- JSON for payment details
);

-- Order items table
CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    discount_percent DECIMAL(5,2) DEFAULT 0
);

-- Product reviews with JSON for detailed feedback
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    customer_id INTEGER REFERENCES customers(customer_id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_metadata JSONB, -- JSON for additional review data
    helpful_votes INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. SAMPLE DATA INSERTION
-- =====================================================

-- Insert products with arrays and JSON
INSERT INTO products (name, category, tags, price, specifications, images) VALUES
('MacBook Pro 16"', 'Electronics', ARRAY['laptop', 'apple', 'professional'], 2499.99,
 '{"cpu": "M2 Pro", "ram": "16GB", "storage": "512GB SSD", "display": "16-inch Retina", "ports": ["USB-C", "HDMI", "MagSafe"]}',
 ARRAY['macbook-pro-1.jpg', 'macbook-pro-2.jpg']),

('Nike Air Max 270', 'Footwear', ARRAY['shoes', 'nike', 'running', 'casual'], 129.99,
 '{"brand": "Nike", "color": "Black/White", "sizes": [8, 8.5, 9, 9.5, 10, 10.5, 11], "material": "mesh"}',
 ARRAY['nike-air-max-1.jpg', 'nike-air-max-2.jpg', 'nike-air-max-3.jpg']),

('Samsung 4K Smart TV', 'Electronics', ARRAY['tv', 'samsung', '4k', 'smart'], 799.99,
 '{"screen_size": "55 inches", "resolution": "4K UHD", "smart_features": ["Netflix", "Prime Video", "YouTube"], "connectivity": ["WiFi", "Bluetooth", "HDMI"]}',
 ARRAY['samsung-tv-1.jpg', 'samsung-tv-2.jpg']),

('Coffee Maker Pro', 'Appliances', ARRAY['coffee', 'kitchen', 'brewing'], 199.99,
 '{"capacity": "12 cups", "features": ["programmable", "auto-shutoff", "thermal carafe"], "warranty": "2 years"}',
 ARRAY['coffee-maker-1.jpg']);

-- Insert customers with JSON preferences
INSERT INTO customers (email, full_name, preferences, purchase_history) VALUES
('john.doe@email.com', 'John Doe',
 '{"favorite_categories": ["Electronics", "Books"], "price_range": {"min": 50, "max": 2000}, "notifications": {"email": true, "sms": false}}',
 ARRAY[1, 3]),

('jane.smith@email.com', 'Jane Smith',
 '{"favorite_categories": ["Footwear", "Clothing"], "price_range": {"min": 20, "max": 300}, "notifications": {"email": true, "sms": true}}',
 ARRAY[2]),

('bob.wilson@email.com', 'Bob Wilson',
 '{"favorite_categories": ["Appliances", "Electronics"], "price_range": {"min": 100, "max": 1000}, "notifications": {"email": false, "sms": true}}',
 ARRAY[4, 1]);

-- Insert orders with JSON addresses
INSERT INTO orders (customer_id, status, shipping_address, total_amount, payment_info) VALUES
(1, 'delivered', 
 '{"street": "123 Main St", "city": "New York", "state": "NY", "zip": "10001", "country": "USA"}',
 2499.99,
 '{"method": "credit_card", "last_four": "1234", "processor": "stripe"}'),

(2, 'shipped',
 '{"street": "456 Oak Ave", "city": "Los Angeles", "state": "CA", "zip": "90210", "country": "USA"}',
 129.99,
 '{"method": "paypal", "transaction_id": "PP123456"}'),

(1, 'processing',
 '{"street": "123 Main St", "city": "New York", "state": "NY", "zip": "10001", "country": "USA"}',
 799.99,
 '{"method": "credit_card", "last_four": "1234", "processor": "stripe"}');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_percent) VALUES
(1, 1, 1, 2499.99, 0),
(2, 2, 1, 129.99, 10),
(3, 3, 1, 799.99, 5);

-- Insert reviews with JSON metadata
INSERT INTO reviews (product_id, customer_id, rating, review_text, review_metadata) VALUES
(1, 1, 5, 'Excellent laptop for professional work!',
 '{"verified_purchase": true, "review_source": "website", "device_used": "mobile"}'),

(2, 2, 4, 'Comfortable shoes, great for running.',
 '{"verified_purchase": true, "review_source": "mobile_app", "size_purchased": 9}'),

(3, 1, 5, 'Amazing picture quality and smart features.',
 '{"verified_purchase": true, "review_source": "website", "setup_difficulty": "easy"}');

-- =====================================================
-- 3. QUERIES DEMONSTRATING POSTGRESQL FEATURES
-- =====================================================

-- ============ ARRAY OPERATIONS ============

-- 1. Find products with specific tags
SELECT name, tags 
FROM products 
WHERE 'laptop' = ANY(tags);

-- 2. Find products with multiple required tags
SELECT name, tags 
FROM products 
WHERE tags @> ARRAY['nike', 'running'];

-- 3. Get customers who bought specific product IDs
SELECT full_name, purchase_history 
FROM customers 
WHERE purchase_history && ARRAY[1, 2]; -- Overlaps with array

-- 4. Unnest arrays to work with individual elements
SELECT p.name, unnest(p.tags) as individual_tag
FROM products p
ORDER BY p.name, individual_tag;

-- ============ JSON/JSONB OPERATIONS ============

-- 5. Query JSON fields
SELECT name, specifications->>'cpu' as cpu_type
FROM products 
WHERE specifications->>'cpu' LIKE '%M2%';

-- 6. Query nested JSON
SELECT email, preferences->'price_range'->>'max' as max_budget
FROM customers
WHERE (preferences->'price_range'->>'max')::INTEGER > 500;

-- 7. JSON array operations
SELECT name, jsonb_array_elements_text(specifications->'ports') as ports
FROM products
WHERE specifications ? 'ports';

-- 8. Update JSON fields
UPDATE customers 
SET preferences = preferences || '{"last_login": "2024-06-03"}'::jsonb
WHERE customer_id = 1;

-- ============ WINDOW FUNCTIONS ============

-- 9. Rank products by price within category
SELECT 
    name,
    category,
    price,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) as price_rank,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) as dense_price_rank
FROM products;

-- 10. Running total of order amounts by customer
SELECT 
    c.full_name,
    o.order_date,
    o.total_amount,
    SUM(o.total_amount) OVER (
        PARTITION BY c.customer_id 
        ORDER BY o.order_date 
        ROWS UNBOUNDED PRECEDING
    ) as running_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_date;

-- 11. Compare each order to customer's average
SELECT 
    c.full_name,
    o.total_amount,
    AVG(o.total_amount) OVER (PARTITION BY c.customer_id) as customer_avg,
    o.total_amount - AVG(o.total_amount) OVER (PARTITION BY c.customer_id) as diff_from_avg
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- 12. Lead/Lag functions to compare consecutive orders
SELECT 
    customer_id,
    order_date,
    total_amount,
    LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as prev_order_amount,
    LEAD(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as next_order_amount,
    total_amount - LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as change_from_prev
FROM orders
ORDER BY customer_id, order_date;

-- ============ COMPLEX COMBINED QUERIES ============

-- 13. Product analytics with arrays, JSON, and windows
SELECT 
    p.name,
    p.category,
    array_length(p.tags, 1) as tag_count,
    p.specifications->>'brand' as brand,
    COUNT(r.review_id) as review_count,
    AVG(r.rating) as avg_rating,
    RANK() OVER (PARTITION BY p.category ORDER BY AVG(r.rating) DESC NULLS LAST) as rating_rank,
    ROW_NUMBER() OVER (ORDER BY COUNT(r.review_id) DESC) as popularity_rank
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name, p.category, p.tags, p.specifications
ORDER BY popularity_rank;

-- 14. Customer segmentation using JSON preferences and window functions
SELECT 
    c.full_name,
    c.preferences->'favorite_categories' as favorite_categories,
    (c.preferences->'price_range'->>'max')::INTEGER as max_budget,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    NTILE(4) OVER (ORDER BY SUM(o.total_amount) DESC) as customer_quartile,
    CASE 
        WHEN SUM(o.total_amount) > 1000 THEN 'High Value'
        WHEN SUM(o.total_amount) > 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.preferences
ORDER BY total_spent DESC NULLS LAST;

-- =====================================================
-- 4. ADVANCED FEATURES AND INDEXES
-- =====================================================

-- Create indexes for better performance
CREATE INDEX idx_products_tags ON products USING GIN(tags);
CREATE INDEX idx_products_specs ON products USING GIN(specifications);
CREATE INDEX idx_customers_prefs ON customers USING GIN(preferences);

-- Full-text search on product names and tags
CREATE INDEX idx_products_search ON products USING GIN(
    to_tsvector('english', name || ' ' || array_to_string(tags, ' '))
);

-- Search query using full-text search
SELECT name, tags, ts_rank(
    to_tsvector('english', name || ' ' || array_to_string(tags, ' ')),
    plainto_tsquery('english', 'laptop professional')
) as rank
FROM products
WHERE to_tsvector('english', name || ' ' || array_to_string(tags, ' ')) 
      @@ plainto_tsquery('english', 'laptop professional')
ORDER BY rank DESC;

-- =====================================================
-- 5. LEARNING EXERCISES
-- =====================================================

/*
Try these exercises to practice:

1. ARRAY EXERCISES:
   - Find all customers who have purchased products 1 OR 3
   - Add a new tag to all electronics products
   - Remove specific tags from products
   - Find products with exactly 3 tags

2. JSON EXERCISES:
   - Find customers who prefer email notifications
   - Update a customer's price range preferences
   - Extract all unique features from product specifications
   - Find products with specific warranty periods

3. WINDOW FUNCTION EXERCISES:
   - Calculate each product's price percentile within its category
   - Find the top 2 most expensive products per category
   - Calculate month-over-month order growth
   - Identify customers with declining order values

4. COMBINED EXERCISES:
   - Create a recommendation system using customer preferences and purchase history
   - Build a dashboard query showing category performance with rankings
   - Analyze review patterns using metadata and window functions
*/