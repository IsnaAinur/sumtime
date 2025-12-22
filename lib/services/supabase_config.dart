import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://bhqjfytcdgsajvomomqf.supabase.co'; // Replace with your Supabase URL
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJocWpmeXRjZGdzYWp2b21vbXFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzNTgyMDMsImV4cCI6MjA4MTkzNDIwM30.6CKJd_GuzBa6IySN5j5YnhK3g-d5QSp0J_RnOxTweoI'; // Replace with your Supabase Anon Key

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
