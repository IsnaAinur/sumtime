-- Sample Data untuk Testing Aplikasi SumTime
-- Jalankan setelah setup database schema dan RLS policies

-- =============================================================================
-- 1. SAMPLE USERS (Admin & Regular Users)
-- =============================================================================

-- Password hash untuk 'password123' (gunakan bcrypt atau scrypt di production)
-- Untuk testing, kita gunakan plain text terlebih dahulu

INSERT INTO users (email, username, password_hash, role) VALUES
('admin@sumtime.com', 'admin', 'admin123', 'admin'),
('user1@sumtime.com', 'user1', 'user123', 'user'),
('user2@sumtime.com', 'user2', 'user123', 'user'),
('user3@sumtime.com', 'user3', 'user123', 'user');

-- Sample profiles
INSERT INTO profiles (user_id, full_name, phone, address) VALUES
((SELECT id FROM users WHERE username = 'admin'), 'Administrator SumTime', '081234567890', 'Jl. Admin No. 1'),
((SELECT id FROM users WHERE username = 'user1'), 'Ahmad Rahman', '081234567891', 'Jl. Sudirman No. 123, Jakarta'),
((SELECT id FROM users WHERE username = 'user2'), 'Siti Aminah', '081234567892', 'Jl. Thamrin No. 456, Jakarta'),
((SELECT id FROM users WHERE username = 'user3'), 'Budi Santoso', '081234567893', 'Jl. Gatot Subroto No. 789, Jakarta');

-- =============================================================================
-- 2. SAMPLE CATEGORIES
-- =============================================================================

INSERT INTO categories (name, description, sort_order) VALUES
('Dimsum', 'Berbagai jenis dimsum tradisional dan modern', 1),
('Minuman', 'Minuman segar dan menyegarkan', 2);

-- =============================================================================
-- 3. SAMPLE PRODUCTS
-- =============================================================================

INSERT INTO products (name, description, price, category_id, stock_quantity) VALUES
-- Dimsum
('Dimsum Ayam', 'Dimsum ayam yang lezat dengan isian daging ayam pilihan, dibungkus dengan kulit yang tipis dan lembut. Dimasak dengan teknik steaming yang sempurna untuk menghasilkan tekstur yang kenyal dan rasa yang gurih.',
 25000, (SELECT id FROM categories WHERE name = 'Dimsum'), 50),

('Dimsum Udang', 'Dimsum udang premium dengan isian udang segar yang melimpah. Dibuat dengan resep tradisional yang menghasilkan cita rasa yang autentik dan nikmat.',
 28000, (SELECT id FROM categories WHERE name = 'Dimsum'), 45),

('Dimsum Sapi', 'Dimsum dengan isian daging sapi premium, dibumbui dengan rempah-rempah pilihan untuk cita rasa yang kaya dan menggugah selera.',
 30000, (SELECT id FROM categories WHERE name = 'Dimsum'), 40),

('Dimsum Sayuran', 'Dimsum vegetarian yang sehat dengan isian sayuran segar. Cocok untuk Anda yang ingin menjaga pola makan seimbang.',
 22000, (SELECT id FROM categories WHERE name = 'Dimsum'), 35),

-- Minuman
('Es Jeruk', 'Es jeruk segar yang menyegarkan, dibuat dari jeruk peras asli tanpa pengawet. Sempurna untuk menemani hidangan dimsum Anda.',
 15000, (SELECT id FROM categories WHERE name = 'Minuman'), 100),

('Es Teh', 'Es teh manis yang segar, dibuat dari teh pilihan dengan takaran gula yang pas. Minuman klasik yang selalu cocok untuk segala suasana.',
 12000, (SELECT id FROM categories WHERE name = 'Minuman'), 80),

('Jus Alpukat', 'Jus alpukat fresh yang creamy dan nikmat. Dibuat dari alpukat matang yang dipilih langsung dari petani lokal.',
 18000, (SELECT id FROM categories WHERE name = 'Minuman'), 60),

('Thai Tea', 'Thai tea yang autentik dengan rasa yang khas dan manisnya yang pas. Minuman favorit yang bikin nagih.',
 16000, (SELECT id FROM categories WHERE name = 'Minuman'), 70);

-- =============================================================================
-- 4. SAMPLE POSTERS
-- =============================================================================

INSERT INTO posters (title, image_url, description, sort_order) VALUES
('Promo Dimsum Spesial', 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop', 'Dapatkan diskon 20% untuk semua menu dimsum setiap hari Senin - Rabu', 1),
('Menu Baru - Dimsum Sayuran', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&auto=format&fit=crop', 'Coba dimsum sayuran kami yang sehat dan lezat untuk pilihan menu vegetarian', 2);

-- =============================================================================
-- 5. SAMPLE ORDERS & ORDER ITEMS
-- =============================================================================

-- Order 1: User1 - Pesanan Selesai
INSERT INTO orders (order_number, user_id, status, delivery_address, delivery_phone, delivery_notes, subtotal, shipping_cost, total_amount, order_date) VALUES
('ORD-20241221-0001', (SELECT id FROM users WHERE username = 'user1'), 3,
 'Jl. Sudirman No. 123, Jakarta', '081234567891', 'Tolong dikemas rapi ya',
 78000, 10000, 88000, NOW() - INTERVAL '2 days');

-- Order items untuk Order 1
INSERT INTO order_items (order_id, product_id, product_name, product_price, quantity, total_price) VALUES
((SELECT id FROM orders WHERE order_number = 'ORD-20241221-0001'),
 (SELECT id FROM products WHERE name = 'Dimsum Ayam'), 'Dimsum Ayam', 25000, 2, 50000),
((SELECT id FROM orders WHERE order_number = 'ORD-20241221-0001'),
 (SELECT id FROM products WHERE name = 'Dimsum Udang'), 'Dimsum Udang', 28000, 1, 28000);

-- Payment untuk Order 1
INSERT INTO payments (order_id, payment_method, payment_status, amount, payment_date) VALUES
((SELECT id FROM orders WHERE order_number = 'ORD-20241221-0001'), 'cash', 'paid', 88000, NOW() - INTERVAL '2 days');

-- Order 2: User2 - Dalam Pengantaran
INSERT INTO orders (order_number, user_id, status, delivery_address, delivery_phone, delivery_notes, subtotal, shipping_cost, total_amount, order_date) VALUES
('ORD-20241221-0002', (SELECT id FROM users WHERE username = 'user2'), 2,
 'Jl. Thamrin No. 456, Jakarta', '081234567892', 'Bel rumah warna hijau',
 58000, 10000, 68000, NOW() - INTERVAL '4 hours');

-- Order items untuk Order 2
INSERT INTO order_items (order_id, product_id, product_name, product_price, quantity, total_price) VALUES
((SELECT id FROM orders WHERE order_number = 'ORD-20241221-0002'),
 (SELECT id FROM products WHERE name = 'Dimsum Sapi'), 'Dimsum Sapi', 30000, 1, 30000),
((SELECT id FROM orders WHERE order_number = 'ORD-20241221-0002'),
 (SELECT id FROM products WHERE name = 'Es Jeruk'), 'Es Jeruk', 15000, 1, 15000),
((SELECT id FROM orders WHERE order_number = 'ORD-20241221-0002'),
 (SELECT id FROM products WHERE name = 'Es Teh'), 'Es Teh', 12000, 1, 12000);

-- Order 3: User3 - Pesanan Dibuatkan
INSERT INTO orders (order_number, user_id, status, delivery_address, delivery_phone, delivery_notes, subtotal, shipping_cost, total_amount, order_date) VALUES
('ORD-20241221-0003', (SELECT id FROM users WHERE username = 'user3'), 1,
 'Jl. Gatot Subroto No. 789, Jakarta', '081234567893', 'Tolong extra pedas',
 40000, 10000, 50000, NOW() - INTERVAL '30 minutes');

-- Order items untuk Order 3
INSERT INTO order_items (order_id, product_id, product_name, product_price, quantity, total_price) VALUES
((SELECT id FROM orders WHERE order_number = 'ORD-20241221-0003'),
 (SELECT id FROM products WHERE name = 'Dimsum Ayam'), 'Dimsum Ayam', 25000, 1, 25000),
((SELECT id FROM orders WHERE order_number = 'ORD-20241221-0003'),
 (SELECT id FROM products WHERE name = 'Thai Tea'), 'Thai Tea', 16000, 1, 16000);

-- =============================================================================
-- 6. USEFUL QUERIES UNTUK TESTING
-- =============================================================================

-- Query untuk cek data yang sudah diinsert
/*
-- Cek semua users
SELECT u.username, u.email, u.role, p.full_name, p.phone
FROM users u
LEFT JOIN profiles p ON u.id = p.user_id;

-- Cek semua products dengan category
SELECT p.name, p.price, p.stock_quantity, c.name as category
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
ORDER BY c.name, p.name;

-- Cek semua orders dengan status
SELECT o.order_number, u.username, o.total_amount, o.status,
       CASE o.status
           WHEN 0 THEN 'Diterima'
           WHEN 1 THEN 'Dibuatkan'
           WHEN 2 THEN 'Pengantaran'
           WHEN 3 THEN 'Selesai'
           ELSE 'Unknown'
       END as status_text
FROM orders o
JOIN users u ON o.user_id = u.id
ORDER BY o.order_date DESC;

-- Cek order items
SELECT o.order_number, oi.product_name, oi.quantity, oi.total_price
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
ORDER BY o.order_date DESC, oi.product_name;
*/
