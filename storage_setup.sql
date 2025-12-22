-- Supabase Storage Setup for SumTime App
-- Run these commands in Supabase SQL Editor to setup storage buckets

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public)
VALUES
    ('menu', 'menu', true),
    ('posters', 'posters', true),
    ('profiles', 'profiles', true);

-- Set up RLS policies for storage
-- Allow authenticated users to upload to their own folders
CREATE POLICY "Users can upload menu images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'menu'
        AND auth.role() = 'authenticated'
    );

CREATE POLICY "Users can upload poster images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'posters'
        AND auth.role() = 'authenticated'
    );

CREATE POLICY "Users can upload profile images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'profiles'
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Allow public access to view images
CREATE POLICY "Public can view menu images" ON storage.objects
    FOR SELECT USING (bucket_id = 'menu');

CREATE POLICY "Public can view poster images" ON storage.objects
    FOR SELECT USING (bucket_id = 'posters');

CREATE POLICY "Public can view profile images" ON storage.objects
    FOR SELECT USING (bucket_id = 'profiles');

-- Allow users to delete their own uploaded images
CREATE POLICY "Users can delete their own images" ON storage.objects
    FOR DELETE USING (
        auth.role() = 'authenticated'
        AND (
            bucket_id = 'menu'
            OR bucket_id = 'posters'
            OR (bucket_id = 'profiles' AND (storage.foldername(name))[1] = auth.uid()::text)
        )
    );
