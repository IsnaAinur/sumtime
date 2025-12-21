# Panduan Registrasi User Baru

## ✅ **User Bisa Buat Akun Baru!**

**Bukan hanya menggunakan sample data yang sudah ada.** Sistem sudah mendukung pendaftaran user baru secara real-time.

---

## 🚀 **Cara User Register Akun Baru**

### **1. Buka Aplikasi**
- Jalankan aplikasi SumTime
- Klik menu **Register** atau **Daftar**

### **2. Isi Form Registrasi**
```
📧 Email: userbaru@gmail.com (bisa email apa saja)
🔒 Password: password123 (min 6 karakter)
👤 Username: Nama User Baru
```

### **3. Klik "Register/Daftar"**
- Sistem akan buat akun di Supabase
- Profile user otomatis dibuat
- User langsung bisa login (tanpa konfirmasi email)

### **4. Login dengan Akun Baru**
- Kembali ke halaman login
- Masukkan email & password yang baru didaftarkan
- Klik login → masuk ke aplikasi

---

## 🎯 **Sample Data Hanya untuk Testing**

### **Akun Sample (sudah ada):**
- **Admin**: `admin@sumtime.com` / `admin123`
- **User1**: `user1@sumtime.com` / `user123`
- **User2**: `user2@sumtime.com` / `user123`
- **User3**: `user3@sumtime.com` / `user123`

### **Akun Baru (dibuat user):**
- **Email**: Bebas (gmail.com, yahoo.com, dll)
- **Password**: Minimal 6 karakter
- **Role**: Otomatis user biasa (bukan admin)

---

## 🔧 **Yang Terjadi Saat Register**

### **Di Database:**
1. **Tabel `users`**: User baru dibuat dengan role 'user'
2. **Tabel `profiles`**: Profile otomatis dibuat dengan data dasar
3. **Authentication**: User terdaftar di Supabase Auth

### **Flow Sistem:**
```
Register Form → Supabase Auth → Database Insert → Profile Create → Success
```

---

## 📱 **Testing Registration**

### **Step 1: Setup Supabase**
```bash
# Pastikan sudah setup Supabase:
# 1. Project dibuat
# 2. SQL scripts dijalankan
# 3. Email confirmation DIMATIKAN
```

### **Step 2: Test Register**
```bash
# 1. Jalankan aplikasi
flutter run -d chrome

# 2. Buka halaman register
# 3. Isi form dengan email baru
# 4. Klik register
# 5. Kembali ke login dan coba login
```

### **Step 3: Verifikasi**
- ✅ Register berhasil tanpa error
- ✅ User bisa login dengan akun baru
- ✅ Profile user dibuat otomatis
- ✅ User masuk sebagai role 'user' (bukan admin)

---

## 🐛 **Troubleshooting**

### **Error: "Email not confirmed"**
```
Solusi: Matikan email confirmation di Supabase settings
```

### **Error: "User already registered"**
```
Solusi: Sistem akan auto-login jika email sudah terdaftar
```

### **Error: "Weak password"**
```
Solusi: Gunakan password minimal 6 karakter
```

### **Error: "Invalid email"**
```
Solusi: Pastikan format email benar (@gmail.com, @yahoo.com, dll)
```

---

## 📊 **Database Structure**

### **Setelah Register Berhasil:**
```sql
-- Tabel users
INSERT INTO users (email, username, role) VALUES ('userbaru@gmail.com', 'User Baru', 'user');

-- Tabel profiles
INSERT INTO profiles (user_id, full_name) VALUES ('user-uuid', 'User Baru');
```

### **Data yang Dibuat:**
- ✅ User authentication di Supabase
- ✅ Record di tabel `users`
- ✅ Record di tabel `profiles`
- ✅ Role otomatis 'user'
- ✅ Profile dengan data dasar

---

## 🎉 **Kesimpulan**

**YA, user bisa buat akun baru!** 🚀

- Sample data hanya untuk testing awal
- User bisa register dengan email apa saja
- Sistem fully mendukung user baru
- Tidak perlu konfirmasi email (sudah dimatikan)
- User langsung bisa login setelah register

**Coba register akun baru sekarang dan test flow-nya!** 🎯
