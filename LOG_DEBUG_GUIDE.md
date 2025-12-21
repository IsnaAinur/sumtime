# Panduan Melihat Log Error Flutter

## 🎯 Cara Melihat Log Error

### 1. **TERMINAL (PALING MUDAH & DIREKOMENDASIKAN)**
```bash
# Jalankan aplikasi dengan mode debug
flutter run --debug

# Atau untuk verbose logging
flutter run --verbose
```
**Keuntungan**: Log muncul real-time di terminal saat aplikasi berjalan

---

### 2. **DEBUG CONSOLE di VS Code/Cursor**
```
1. Buka aplikasi di VS Code/Cursor
2. Tekan: Ctrl + Shift + Y
   Atau: View → Debug Console
3. Jalankan aplikasi dengan F5
4. Log akan muncul di panel bawah
```

---

### 3. **ANDROID STUDIO / IntelliJ IDEA**
```
1. Buka Android Studio
2. Buka project Flutter
3. Run → Debug
4. Lihat tab "Run" di panel bawah
```

---

### 4. **UNTUK ANDROID DEVICE**
```bash
# Di terminal/command prompt baru (selama app berjalan)
adb logcat flutter:V
```

---

### 5. **UNTUK iOS DEVICE**
```bash
# Di terminal/command prompt
flutter logs
```

---

## 🔍 Jenis Log Yang Akan Terlihat

### ✅ **Log Normal (Hijau/Biru)**
```
flutter: User login successful
flutter: Products loaded: 8 items
```

### ❌ **Log Error (Merah)**
```
flutter: Error: Invalid login credentials
flutter: Exception: Table 'products' doesn't exist
flutter: PlatformException: NETWORK_ERROR
```

### ℹ️ **Log Info (Putih)**
```
flutter: Initializing Supabase...
flutter: Loading categories...
```

---

## 🛠️ Debug Tips

### **Untuk Error Register/Login:**
1. Jalankan `flutter run --debug`
2. Coba register/login
3. Lihat log yang muncul di terminal

### **Untuk Error Database:**
```
flutter: Error: relation "users" does not exist
flutter: Error: permission denied for table users
```
→ **Solusi**: Jalankan SQL scripts di Supabase

### **Untuk Error Network:**
```
flutter: Error: Connection timeout
flutter: Error: Network request failed
```
→ **Solusi**: Cek koneksi internet & Supabase URL

### **Untuk Error Authentication:**
```
flutter: Error: Invalid API key
flutter: Error: Project not found
```
→ **Solusi**: Cek `supabase_config.dart`

---

## 📱 Cara Debug di Device Fisik

### **Android:**
```bash
# Terminal 1: Run app
flutter run --debug

# Terminal 2: View logs
adb logcat flutter:V
```

### **iOS:**
```bash
# Terminal 1: Run app
flutter run --debug

# Terminal 2: View device logs
flutter logs
```

---

## 🔧 Advanced Debugging

### **Menggunakan DevTools:**
```bash
flutter run --debug --devtools
```
→ Buka browser untuk debugging advance

### **Hot Reload dengan Logging:**
```bash
flutter run --debug --hot
```

---

## 🚨 Error Umum & Solusinya

### **"SupabaseConfig not found"**
```bash
flutter: Error: The getter 'SupabaseConfig' isn't defined
```
→ Tambahkan `import 'supabase_config.dart';`

### **"Table doesn't exist"**
```bash
flutter: Error: relation "products" does not exist
```
→ Jalankan `database_schema.sql` di Supabase

### **"Network error"**
```bash
flutter: Error: Connection failed
```
→ Cek internet & Supabase credentials

### **"Auth failed"**
```bash
flutter: Error: Invalid login credentials
```
→ Cek email/password & Supabase auth settings

---

## 📋 Checklist Debug

- [ ] `flutter doctor` - cek Flutter setup
- [ ] `flutter pub get` - install dependencies
- [ ] Supabase project aktif
- [ ] SQL scripts sudah dijalankan
- [ ] Credentials benar di `supabase_config.dart`
- [ ] Email confirmation dimatikan (untuk development)
- [ ] Internet connection stabil

---

## 🎯 Quick Start

1. **Buka Terminal** di project folder
2. **Jalankan**: `flutter run --debug`
3. **Lihat log** saat aplikasi berjalan
4. **Coba fitur** yang bermasalah
5. **Copy error message** untuk troubleshooting

**Selamat debugging!** 🐛✨
