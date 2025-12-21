# Database Setup untuk Aplikasi SumTime

Panduan lengkap setup database Supabase untuk aplikasi SumTime (Food Ordering App).

## 📋 Daftar Isi
- [Struktur Database](#struktur-database)
- [Cara Setup](#cara-setup)
- [File-file SQL](#file-file-sql)
- [API Endpoints](#api-endpoints)
- [Testing](#testing)

## 🏗️ Struktur Database

### Tabel Utama:
1. **users** - Data user dan admin
2. **profiles** - Profil lengkap user
3. **categories** - Kategori produk (Dimsum, Minuman)
4. **products** - Menu items
5. **posters** - Banner/poster di homepage
6. **orders** - Header pesanan
7. **order_items** - Detail item dalam pesanan
8. **payments** - Data pembayaran

### Storage Buckets:
1. **products** - Gambar menu items
2. **profiles** - Foto profil user
3. **posters** - Gambar banner/poster

## 🚀 Cara Setup

### Langkah 1: Buat Project Supabase
1. Buka [supabase.com](https://supabase.com)
2. Buat project baru
3. Catat URL dan API keys (anon public key)

### Langkah 2: Setup Database
1. Buka **SQL Editor** di Supabase Dashboard
2. Jalankan file-file SQL berikut secara berurutan:

#### Urutan Eksekusi:
```sql
-- 1. Schema database
database_schema.sql

-- 2. Row Level Security policies
database_rls_policies.sql

-- 3. Storage buckets & policies
storage_setup.sql

-- 4. Sample data untuk testing
sample_data.sql
```

### Langkah 3: Konfigurasi Authentication
1. Pergi ke **Authentication > Settings**
2. Setup email templates jika perlu
3. Configure password requirements

## 📁 File-file SQL

### 1. `database_schema.sql`
- Membuat semua tabel dengan constraints
- Indexes untuk performa
- Triggers untuk auto-update timestamp

### 2. `database_rls_policies.sql`
- Row Level Security policies
- Function untuk generate order number
- Policies untuk user access control

### 3. `storage_setup.sql`
- Storage buckets untuk upload gambar
- Storage policies untuk access control

### 4. `sample_data.sql`
- Data testing untuk development
- Sample users, products, orders
- Queries untuk verifikasi data

## 🔗 API Endpoints

### Authentication
```dart
// Login
supabase.auth.signInWithPassword(email: email, password: password)

// Register
supabase.auth.signUp(email: email, password: password)

// Logout
supabase.auth.signOut()
```

### Products
```dart
// Get all products
final products = await supabase
    .from('products')
    .select('*, categories(*)')
    .eq('is_available', true);

// Get products by category
final dimsumProducts = await supabase
    .from('products')
    .select('*, categories(*)')
    .eq('category_id', categoryId)
    .eq('is_available', true);
```

### Orders
```dart
// Create new order
final order = await supabase
    .from('orders')
    .insert({
      'user_id': userId,
      'order_number': generateOrderNumber(),
      'delivery_address': address,
      'delivery_phone': phone,
      'subtotal': subtotal,
      'total_amount': total,
      'status': 0
    })
    .select()
    .single();

// Add order items
await supabase
    .from('order_items')
    .insert(orderItems);
```

### File Upload
```dart
// Upload product image
final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
await supabase.storage
    .from('products')
    .upload(fileName, imageFile);

// Get public URL
final imageUrl = supabase.storage
    .from('products')
    .getPublicUrl(fileName);
```

## 🧪 Testing

### Data Testing
Setelah setup, Anda akan memiliki:
- **1 Admin user**: admin@sumtime.com / admin123
- **3 Regular users**: user1, user2, user3
- **8 Products**: 4 dimsum + 4 minuman
- **3 Sample orders** dengan berbagai status

### Test Cases
1. **User Login/Registration**
2. **Browse Products** - Filter by category
3. **Add to Cart & Checkout**
4. **Order History** - View order status
5. **Admin Panel** - Manage products, orders
6. **File Upload** - Product images, profile photos

## 🔐 Security Features

### Row Level Security (RLS)
- Users hanya bisa akses data sendiri
- Admin bisa akses semua data
- Public access untuk products dan categories

### Storage Policies
- Public read untuk gambar
- Authenticated upload untuk profiles
- Admin-only untuk products dan posters

## 📊 Monitoring & Analytics

### Useful Queries untuk Dashboard Admin:
```sql
-- Total orders hari ini
SELECT COUNT(*) as total_orders_today
FROM orders
WHERE DATE(order_date) = CURRENT_DATE;

-- Total revenue bulan ini
SELECT SUM(total_amount) as monthly_revenue
FROM orders
WHERE DATE_TRUNC('month', order_date) = DATE_TRUNC('month', CURRENT_DATE);

-- Top products
SELECT p.name, SUM(oi.quantity) as total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.id
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 10;
```

## 🛠️ Troubleshooting

### Common Issues:
1. **Error: null value in column "image_url" of relation "posters"**
   - **Solusi**: Jalankan `fix_schema_update.sql` untuk memperbaiki schema
   - Atau update manual: `ALTER TABLE posters ALTER COLUMN image_url DROP NOT NULL;`

2. **Error: syntax error at or near "current_date"**
   - **Penyebab**: `current_date` adalah reserved keyword di PostgreSQL
   - **Solusi**: Sudah diperbaiki di `database_rls_policies.sql` (menggunakan `current_date_str`)

3. **RLS blocking queries** - Pastikan user sudah login

4. **Storage upload failed** - Check bucket policies

5. **Order number duplicate** - Check generate_order_number function

6. **Inconsistent prices in order items**
   - Pastikan harga di order_items sesuai dengan harga di tabel products
   - Gunakan snapshot harga saat order dibuat

### Debug Queries:
```sql
-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public';

-- Check storage buckets
SELECT id, name, public, file_size_limit
FROM storage.buckets;
```

## 📝 Notes

- Gunakan environment variables untuk API keys
- Implement proper error handling di Flutter app
- Regular backup database untuk production
- Monitor storage usage untuk cost optimization

## 🤝 Support

Jika ada pertanyaan atau masalah dalam setup, silakan cek:
1. Supabase documentation
2. Flutter Supabase packages
3. Error logs di aplikasi
