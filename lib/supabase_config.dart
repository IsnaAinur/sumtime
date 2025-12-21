import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://lsvcyitzzhesuqxnsvwt.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_EXxDSuLqnfO3LiZ0r3xI9Q_ykP-gMWz';

  // Inisialisasi Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Getter untuk Supabase client
  static SupabaseClient get client => Supabase.instance.client;
}
