# SumTime - Food Ordering App

Aplikasi pemesanan makanan Flutter dengan sistem admin untuk mengelola menu dan pesanan.

## Features

### User Features
- ✅ Login/Register dengan autentikasi
- ✅ Melihat menu makanan
- ✅ Menambah item ke keranjang
- ✅ Checkout dan pembayaran
- ✅ Melihat riwayat pesanan
- ✅ Update profil pengguna

### Admin Features
- ✅ Login sebagai admin
- ✅ Mengelola menu makanan (tambah/edit/hapus)
- ✅ Upload poster menu
- ✅ Mengelola status pesanan
- ✅ Melihat laporan dan statistik

## Database Setup (Supabase)

### 1. Buat Project Supabase

1. Kunjungi [supabase.com](https://supabase.com)
2. Buat akun baru atau login
3. Klik "New Project"
4. Isi detail project dan tunggu sampai setup selesai

### 2. Setup Database

1. Buka Supabase Dashboard → SQL Editor
2. Copy dan paste seluruh isi file `supabase_schema.sql`
3. Jalankan query tersebut

### 3. Setup Storage Buckets

1. Buka Supabase Dashboard → Storage
2. Buat bucket baru dengan nama:
   - `menu` (untuk gambar menu)
   - `posters` (untuk poster menu)
   - `profiles` (untuk foto profil)

3. Set bucket policies ke public agar bisa diakses

### 4. Konfigurasi Aplikasi

1. Buka file `lib/services/supabase_config.dart`
2. Ganti `YOUR_SUPABASE_URL` dengan URL project Supabase Anda
3. Ganti `YOUR_SUPABASE_ANON_KEY` dengan anon key dari project Supabase Anda

### 5. Install Dependencies

```bash
flutter pub get
```

## Database Schema

### Tables Overview

1. **users** - Data pengguna dan admin
2. **menu_items** - Data menu makanan
3. **posters** - Data poster menu
4. **orders** - Data pesanan utama
5. **order_items** - Detail item dalam pesanan

### Key Features

- ✅ Auto-generated order IDs (ORD-XXXXX)
- ✅ Row Level Security (RLS) policies
- ✅ Automatic timestamps
- ✅ User role management
- ✅ Order status tracking

## API Integration

Aplikasi menggunakan service classes untuk berinteraksi dengan Supabase:

- `AuthService` - Authentication management
- `MenuService` - Menu dan poster management
- `OrderService` - Order management

## Running the App

```bash
flutter run
```

## Sample Data

Database sudah include sample data untuk testing:

- Admin user: admin@sumtime.com / admin123
- Sample menu items (Dimsum Ayam, Udang, dll)
- Sample poster

## File Structure

```
lib/
├── models/
│   ├── menu_item.dart      # MenuItem dan Poster models
│   └── order_item.dart     # OrderItem models
├── services/
│   ├── auth_service.dart   # Authentication service
│   ├── menu_service.dart   # Menu management service
│   ├── order_service.dart  # Order management service
│   └── supabase_config.dart # Supabase configuration
├── admin/                  # Admin pages
├── beranda.dart           # User home page
├── checkout.dart          # Checkout page
├── login.dart            # Login page
├── register.dart         # Register page
├── profile.dart          # Profile page
└── main.dart             # App entry point
```

## Security Notes

- Password hashing perlu diimplementasi di production
- RLS policies memastikan users hanya bisa akses data mereka sendiri
- Admin bisa akses semua data untuk management

## Support

Untuk pertanyaan atau issues, silakan buat issue di repository ini.