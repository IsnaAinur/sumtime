import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'services/supabase_service.dart';

class TestSupabaseConnection extends StatefulWidget {
  const TestSupabaseConnection({super.key});

  @override
  State<TestSupabaseConnection> createState() => _TestSupabaseConnectionState();
}

class _TestSupabaseConnectionState extends State<TestSupabaseConnection> {
  String _status = 'Initializing...';
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      setState(() {
        _status = 'Testing Supabase connection...';
        _isLoading = true;
      });

      // Test 1: Basic connection
      final client = SupabaseConfig.client;
      setState(() {
        _status = '✅ Supabase client initialized';
      });

      // Test 2: Test database connection
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _status = 'Testing database connection...';
      });

      final response = await client.from('categories').select('count').limit(1);
      setState(() {
        _status = '✅ Database connection successful';
      });

      // Test 3: Test auth
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _status = 'Testing authentication...';
      });

      final currentUser = SupabaseConfig.client.auth.currentUser;
      if (currentUser != null) {
        setState(() {
          _status = '✅ User authenticated: ${currentUser.email}';
        });
      } else {
        setState(() {
          _status = 'ℹ️ No user currently authenticated';
        });
      }

      // Test 4: Test products loading
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _status = 'Testing products loading...';
      });

      final supabaseService = SupabaseService();
      final products = await supabaseService.getProducts();

      setState(() {
        _status = '✅ All tests passed! Products loaded: ${products.length}';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status = '❌ Connection failed';
        _errorMessage = e.toString();
        _isLoading = false;
      });

      // Print to console for debugging
      print('Supabase Connection Error: $e');
      print('Error details: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Supabase Connection'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supabase Connection Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Status indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isLoading ? Colors.yellow.shade100 : (_errorMessage.isEmpty ? Colors.green.shade100 : Colors.red.shade100),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isLoading ? Colors.yellow : (_errorMessage.isEmpty ? Colors.green : Colors.red),
                ),
              ),
              child: Row(
                children: [
                  _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _errorMessage.isEmpty ? Icons.check_circle : Icons.error,
                          color: _errorMessage.isEmpty ? Colors.green : Colors.red,
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _status,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Error Details:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: const Text('Test Again'),
            ),

            const SizedBox(height: 20),
            const Text(
              'Debug Info:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('URL: ${SupabaseConfig.supabaseUrl}'),
            Text('Key: ${SupabaseConfig.supabaseAnonKey.substring(0, 20)}...'),
          ],
        ),
      ),
    );
  }
}
