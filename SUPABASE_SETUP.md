# Setup Supabase untuk Aplikasi SumTime

Panduan lengkap setup Supabase dan konfigurasi aplikasi.

## 📋 Persiapan

### 1. Buat Project Supabase
1. Buka [supabase.com](https://supabase.com)
2. Klik "New Project"
3. Isi informasi project:
   - **Name**: SumTime App
   - **Database Password**: Buat password yang kuat
   - **Region**: Singapore (atau region terdekat)
4. Tunggu project siap (5-10 menit)

### 2. Dapatkan Credentials
Setelah project siap:
1. Pergi ke **Settings** → **API**
2. Copy:
   - **Project URL**
   - **anon/public key**

## 🛠️ Setup Database

### Jalankan SQL Scripts
Di Supabase Dashboard → **SQL Editor**, jalankan file-file ini secara berurutan:

```sql
-- 1. Buat tabel dan struktur database
database_schema.sql

-- 2. Setup security policies
database_rls_policies.sql

-- 3. Setup storage buckets
storage_setup.sql

-- 4. Insert sample data
sample_data.sql
```

## 🔧 Konfigurasi Aplikasi

### 1. Nonaktifkan Email Confirmation (PENTING!)
**Untuk development/testing, matikan email confirmation:**

1. Pergi ke **Authentication** → **Settings**
2. Scroll ke **User Signups**
3. **Matikan** "Enable email confirmations"
4. **Aktifkan** "Enable email change confirmations" (opsional)
5. Klik **Save**

### 2. Update Supabase Config
Edit file `lib/supabase_config.dart`:

```dart
class SupabaseConfig {
  // Ganti dengan URL dan key dari Supabase project Anda
  static const String supabaseUrl = 'https://your-project-ref.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Jalankan Aplikasi
```bash
flutter run
```

## 🔐 Test Login

Gunakan akun test yang sudah dibuat:

### Admin Account
- **Email**: admin@sumtime.com
- **Password**: admin123

### User Accounts (Sample - untuk testing)
- **Email**: user1@sumtime.com
- **Password**: user123
- **Email**: user2@sumtime.com
- **Password**: user123
- **Email**: user3@sumtime.com
- **Password**: user123

### 🎯 **User Bisa Buat Akun Baru!**
**Sample data di atas HANYA untuk testing.** User bisa register akun baru dengan email apa saja:
- Email: `userbaru@gmail.com` (atau email lain)
- Password: `password123` (minimal 6 karakter)
- Username: `Nama User Baru`

Setelah register, user langsung bisa login tanpa perlu konfirmasi email.

## 📱 Fitur yang Sudah Bekerja

✅ **Authentication** - Login/Register dengan Supabase Auth
✅ **Load Products** - Produk dimuat dari database
✅ **Categories** - Kategori dinamis dari database
✅ **Search & Filter** - Pencarian dan filter produk
✅ **Security** - Row Level Security (RLS) policies

## 🔄 Selanjutnya (Opsional)

Untuk fitur lengkap, bisa lanjutkan dengan:
- Checkout system untuk save orders
- Profile management
- Order history
- Admin panel untuk manage data

## 🐛 Troubleshooting

### Error: "SupabaseConfig not found"
- Pastikan import `supabase_config.dart` di file yang menggunakan

### Error: "Table doesn't exist"
- Pastikan sudah menjalankan semua SQL scripts di Supabase

### Error: "Permission denied"
- Cek RLS policies sudah benar dijalankan

### Error saat Register: "Email not confirmed"
- **Solusi**: Matikan email confirmation di Supabase settings (lihat langkah 1 di atas)

### Error saat Register: "User already registered"
- User dengan email tersebut sudah ada
- Aplikasi akan otomatis mencoba login dengan kredensial tersebut

### Error saat Register: "Weak password"
- Password terlalu lemah, gunakan kombinasi huruf dan angka
- Minimal 6 karakter

### Produk tidak muncul
- Pastikan sudah ada data di tabel products
- Cek koneksi internet

### Login gagal setelah register
- Pastikan email confirmation dimatikan
- Coba restart aplikasi jika masih bermasalah

## 📞 Support

Jika ada masalah, cek:
1. Supabase dashboard logs
2. Flutter debug console
3. Network connectivity
