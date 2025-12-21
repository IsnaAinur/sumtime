-- Row Level Security (RLS) Policies untuk Aplikasi SumTime
-- Jalankan setelah membuat tabel dan sebelum insert sample data

-- =============================================================================
-- 1. ENABLE RLS pada semua tabel
-- =============================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE posters ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- 2. POLICIES untuk tabel USERS
-- =============================================================================

-- Users bisa baca profil sendiri
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

-- Users bisa update profil sendiri
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Admin bisa baca semua users
CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admin bisa update semua users
CREATE POLICY "Admins can update all users" ON users
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =============================================================================
-- 3. POLICIES untuk tabel PROFILES
-- =============================================================================

-- Users bisa baca profil sendiri
CREATE POLICY "Users can view own profile data" ON profiles
    FOR SELECT USING (auth.uid() = user_id);

-- Users bisa insert/update profil sendiri
CREATE POLICY "Users can manage own profile data" ON profiles
    FOR ALL USING (auth.uid() = user_id);

-- Admin bisa baca semua profiles
CREATE POLICY "Admins can view all profiles" ON profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =============================================================================
-- 4. POLICIES untuk tabel CATEGORIES
-- =============================================================================

-- Semua user (termasuk guest) bisa baca categories aktif
CREATE POLICY "Everyone can view active categories" ON categories
    FOR SELECT USING (is_active = true);

-- Admin bisa manage semua categories
CREATE POLICY "Admins can manage categories" ON categories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =============================================================================
-- 5. POLICIES untuk tabel PRODUCTS
-- =============================================================================

-- Semua user bisa baca products aktif
CREATE POLICY "Everyone can view available products" ON products
    FOR SELECT USING (is_available = true);

-- Admin bisa manage semua products
CREATE POLICY "Admins can manage products" ON products
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =============================================================================
-- 6. POLICIES untuk tabel POSTERS
-- =============================================================================

-- Semua user bisa baca posters aktif
CREATE POLICY "Everyone can view active posters" ON posters
    FOR SELECT USING (is_active = true);

-- Admin bisa manage semua posters
CREATE POLICY "Admins can manage posters" ON posters
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =============================================================================
-- 7. POLICIES untuk tabel ORDERS
-- =============================================================================

-- Users bisa baca order sendiri
CREATE POLICY "Users can view own orders" ON orders
    FOR SELECT USING (auth.uid() = user_id);

-- Users bisa insert order baru (sendiri)
CREATE POLICY "Users can create own orders" ON orders
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users bisa update order sendiri (hanya status tertentu)
CREATE POLICY "Users can update own orders" ON orders
    FOR UPDATE USING (auth.uid() = user_id);

-- Admin bisa baca semua orders
CREATE POLICY "Admins can view all orders" ON orders
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admin bisa update semua orders
CREATE POLICY "Admins can update all orders" ON orders
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =============================================================================
-- 8. POLICIES untuk tabel ORDER_ITEMS
-- =============================================================================

-- Users bisa baca order items dari order sendiri
CREATE POLICY "Users can view own order items" ON order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

-- Users bisa insert order items untuk order sendiri
CREATE POLICY "Users can create order items for own orders" ON order_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

-- Admin bisa baca semua order items
CREATE POLICY "Admins can view all order items" ON order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =============================================================================
-- 9. POLICIES untuk tabel PAYMENTS
-- =============================================================================

-- Users bisa baca payment dari order sendiri
CREATE POLICY "Users can view own payments" ON payments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders
            WHERE orders.id = payments.order_id
            AND orders.user_id = auth.uid()
        )
    );

-- Users bisa insert payment untuk order sendiri
CREATE POLICY "Users can create payments for own orders" ON payments
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM orders
            WHERE orders.id = payments.order_id
            AND orders.user_id = auth.uid()
        )
    );

-- Admin bisa manage semua payments
CREATE POLICY "Admins can manage all payments" ON payments
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =============================================================================
-- 10. FUNCTIONS untuk generate order number
-- =============================================================================

CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
DECLARE
    current_date_str TEXT;
    sequence_number INTEGER;
    order_num TEXT;
BEGIN
    -- Format: ORD-YYYYMMDD-XXXX (contoh: ORD-20241221-0001)
    current_date_str := TO_CHAR(NOW(), 'YYYYMMDD');

    -- Cari nomor urut untuk tanggal ini
    SELECT COALESCE(MAX(CAST(SUBSTRING(order_number FROM '[0-9]+$') AS INTEGER)), 0) + 1
    INTO sequence_number
    FROM orders
    WHERE DATE(order_date) = current_date_str::DATE;

    -- Format nomor order
    order_num := 'ORD-' || current_date_str || '-' || LPAD(sequence_number::TEXT, 4, '0');

    RETURN order_num;
END;
$$ LANGUAGE plpgsql;
