-- Menghapus data order spesifik (005, 006, 007)
-- Pastikan untuk menjalankan ini di Supabase SQL Editor

-- 1. Hapus item pesanan terkait terlebih dahulu (jika tidak cascade delete)
DELETE FROM order_items
WHERE order_id IN (
    SELECT id FROM orders WHERE order_id IN ('005', '006', '007')
);

-- 2. Hapus pesanan itu sendiri
DELETE FROM orders
WHERE order_id IN ('005', '006', '007');

-- Verifikasi penghapusan
SELECT order_id, status FROM orders WHERE order_id IN ('005', '006', '007');
