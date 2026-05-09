import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../core/errors/app_exception.dart';
import 'supabase_service.dart';

class AuthService {
  final _auth = SupabaseService.auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  String _phoneToEmail(String phone) => '${phone.replaceAll(RegExp(r'\D'), '')}@kfamily.local';

  Future<void> signIn({required String phone, required String password}) async {
    try {
      final identifier = phone.contains('@') ? phone : _phoneToEmail(phone);
      await _auth.signInWithPassword(
        email: identifier,
        password: password,
      );
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String identifier) async {
    try {
      if (identifier.contains('@')) {
        await _auth.resetPasswordForEmail(identifier);
      } else {
        await _auth.signInWithOtp(phone: identifier);
      }
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<void> inviteUser({
    required String phone,
    required String fullName,
    required int memberNumber,
    required String password,
  }) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'create-member',
        body: {
          'phone': phone,
          'fullName': fullName,
          'memberNumber': memberNumber,
          'password': password,
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Failed to create member';
        throw AppAuthException(error);
      }
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }
}
