-- Supabase Database Schema for SumTime Food Ordering App
-- Created for Flutter application

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. USERS TABLE
-- ============================================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    profile_image_url TEXT,
    phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for users table
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ============================================================================
-- 2. MENU ITEMS TABLE
-- ============================================================================

CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price INTEGER NOT NULL CHECK (price >= 0), -- Price in rupiah (no decimals)
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL
);

-- Create indexes for menu_items table
CREATE INDEX idx_menu_items_available ON menu_items(is_available);
CREATE INDEX idx_menu_items_created_by ON menu_items(created_by);

-- ============================================================================
-- 3. POSTERS TABLE
-- ============================================================================

CREATE TABLE posters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255),
    image_url TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL
);

-- Create indexes for posters table
CREATE INDEX idx_posters_active ON posters(is_active);
CREATE INDEX idx_posters_display_order ON posters(display_order);

-- ============================================================================
-- 4. ORDERS TABLE
-- ============================================================================

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id VARCHAR(20) UNIQUE NOT NULL, -- Format: ORD-XXXXX
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    total_amount INTEGER NOT NULL CHECK (total_amount >= 0),
    shipping_cost INTEGER DEFAULT 10000 CHECK (shipping_cost >= 0),
    status INTEGER DEFAULT 0 CHECK (status IN (0, 1, 2, 3)), -- 0=Diterima, 1=Dibuatkan, 2=Pengantaran, 3=Selesai
    delivery_address TEXT,
    phone VARCHAR(20),
    notes TEXT,
    outlet_location VARCHAR(255) DEFAULT 'Jl. Bhayangkara No.55, Tipes',
    order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for orders table
CREATE INDEX idx_orders_order_id ON orders(order_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- ============================================================================
-- 5. ORDER ITEMS TABLE
-- ============================================================================

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id UUID REFERENCES menu_items(id) ON DELETE SET NULL,
    item_name VARCHAR(255) NOT NULL, -- Store name at time of order
    item_price INTEGER NOT NULL CHECK (item_price >= 0), -- Price at time of order
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for order_items table
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_menu_item_id ON order_items(menu_item_id);

-- ============================================================================
-- 6. FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to generate order_id
CREATE OR REPLACE FUNCTION generate_order_id()
RETURNS TRIGGER AS $$
DECLARE
    next_id INTEGER;
    formatted_id VARCHAR(20);
BEGIN
    -- Get next sequence number
    SELECT COALESCE(MAX(CAST(SUBSTRING(order_id FROM 5) AS INTEGER)), 0) + 1
    INTO next_id
    FROM orders;

    -- Format as ORD-XXXXX (5 digits, zero-padded)
    formatted_id := 'ORD-' || LPAD(next_id::TEXT, 5, '0');

    -- Set the order_id
    NEW.order_id := formatted_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate order_id
CREATE TRIGGER trigger_generate_order_id
    BEFORE INSERT ON orders
    FOR EACH ROW
    WHEN (NEW.order_id IS NULL)
    EXECUTE FUNCTION generate_order_id();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER trigger_update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_menu_items_updated_at
    BEFORE UPDATE ON menu_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_posters_updated_at
    BEFORE UPDATE ON posters
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE posters ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Admin can view all users
CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Menu items policies (public read, admin write)
CREATE POLICY "Anyone can view menu items" ON menu_items
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage menu items" ON menu_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Posters policies (public read, admin write)
CREATE POLICY "Anyone can view posters" ON posters
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage posters" ON posters
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Orders policies
CREATE POLICY "Users can view their own orders" ON orders
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own orders" ON orders
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own orders" ON orders
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all orders" ON orders
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can update all orders" ON orders
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Order items policies
CREATE POLICY "Users can view their own order items" ON order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create their own order items" ON order_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can view all order items" ON order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================================================
-- 8. SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- Insert sample admin user (password should be hashed in real app)
-- Note: This is just for demonstration. In real app, use proper password hashing
INSERT INTO users (username, email, password_hash, role) VALUES
('Administrator', 'admin@sumtime.com', 'admin123', 'admin');

-- Insert sample menu items
INSERT INTO menu_items (name, description, price) VALUES
('Dimsum Ayam', 'Dimsum ayam dengan isi ayam pilihan dan sayuran segar', 25000),
('Dimsum Udang', 'Dimsum udang premium dengan udang segar', 28000),
('Es Teh', 'Es teh manis segar', 12000),
('Es Jeruk', 'Es jeruk perasan langsung', 15000);

-- Insert sample poster
INSERT INTO posters (title, image_url, description) VALUES
('Menu Utama SumTime', 'https://example.com/poster1.jpg', 'Koleksi menu terbaik kami');

-- ============================================================================
-- 9. VIEWS (Optional - for easier queries)
-- ============================================================================

-- View for order details with items
CREATE VIEW order_details AS
SELECT
    o.id,
    o.order_id,
    o.user_id,
    u.username,
    u.email,
    o.total_amount,
    o.shipping_cost,
    o.status,
    o.delivery_address,
    o.phone,
    o.notes,
    o.outlet_location,
    o.order_date,
    o.updated_at,
    json_agg(
        json_build_object(
            'item_name', oi.item_name,
            'item_price', oi.item_price,
            'quantity', oi.quantity,
            'subtotal', oi.item_price * oi.quantity
        )
    ) as items
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, u.username, u.email;

-- View for menu items with creator info
CREATE VIEW menu_items_with_creator AS
SELECT
    mi.*,
    u.username as created_by_username
FROM menu_items mi
LEFT JOIN users u ON mi.created_by = u.id;
