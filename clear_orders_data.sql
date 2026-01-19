-- Hapus semua data dari tabel order_items (detail pesanan) terlebih dahulu
DELETE FROM order_items;

-- Hapus semua data dari tabel orders (pesanan utama)
DELETE FROM orders;

-- Cek apakah data sudah kosong
SELECT * FROM orders;
SELECT * FROM order_items;
