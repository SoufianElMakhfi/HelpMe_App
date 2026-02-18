import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient client = Supabase.instance.client;

  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  // Example: Check if user profile exists
  Future<bool> profileExists(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response != null;
  }

  // Example: Create user profile
  Future<void> createProfile({
    required String userId,
    required String role, // 'customer' or 'craftsman'
  }) async {
    await client.from('profiles').insert({
      'id': userId,
      'role': role,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
