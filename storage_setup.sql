-- Supabase Storage Setup untuk Aplikasi SumTime
-- Jalankan di Supabase SQL Editor

-- =============================================================================
-- 1. BUAT STORAGE BUCKETS
-- =============================================================================

-- Bucket untuk gambar produk
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'products',
    'products',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
);

-- Bucket untuk gambar profile user
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'profiles',
    'profiles',
    true,
    2097152, -- 2MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
);

-- Bucket untuk poster/banner
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'posters',
    'posters',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
);

-- =============================================================================
-- 2. STORAGE POLICIES
-- =============================================================================

-- Policies untuk bucket products
CREATE POLICY "Public read access for products" ON storage.objects
    FOR SELECT USING (bucket_id = 'products');

CREATE POLICY "Admins can upload products" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'products' AND
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can update products" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'products' AND
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can delete products" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'products' AND
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Policies untuk bucket profiles
CREATE POLICY "Public read access for profiles" ON storage.objects
    FOR SELECT USING (bucket_id = 'profiles');

CREATE POLICY "Users can upload own profile" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'profiles' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can update own profile" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'profiles' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can delete own profile" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'profiles' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

-- Policies untuk bucket posters
CREATE POLICY "Public read access for posters" ON storage.objects
    FOR SELECT USING (bucket_id = 'posters');

CREATE POLICY "Admins can manage posters" ON storage.objects
    FOR ALL USING (
        bucket_id = 'posters' AND
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );
