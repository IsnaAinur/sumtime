-- Fix untuk database yang sudah ada
-- Jalankan jika sudah menjalankan schema lama dan mendapat error di sample data

-- 1. Ubah kolom image_url di tabel posters agar bisa NULL
ALTER TABLE posters ALTER COLUMN image_url DROP NOT NULL;

-- 2. Update sample posters dengan image URL (jika belum ada)
UPDATE posters
SET image_url = CASE
    WHEN title = 'Promo Dimsum Spesial'
    THEN 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop'
    WHEN title = 'Menu Baru - Dimsum Sayuran'
    THEN 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&auto=format&fit=crop'
    ELSE image_url
END
WHERE image_url IS NULL;
