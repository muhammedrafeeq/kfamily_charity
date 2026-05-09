import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/profile.dart';
import 'supabase_service.dart';

class ProfileService {
  final _client = SupabaseService.client;

  Future<Profile> getProfile(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) throw DatabaseException('Profile not found for user $userId');
      return Profile.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to load profile: $e');
    }
  }

  Future<List<Profile>> getAllMembers() async {
    try {
      final data = await _client
          .from(SupabaseConstants.profilesTable)
          .select()
          .eq('is_active', true)
          .order('member_number');
      return data.map((e) => Profile.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load members: $e');
    }
  }

  Future<Profile> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final data = await _client
          .from(SupabaseConstants.profilesTable)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      return Profile.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to update profile: $e');
    }
  }

  Future<void> deactivateMember(String memberId) async {
    try {
      await _client
          .from(SupabaseConstants.profilesTable)
          .update({'is_active': false})
          .eq('id', memberId);
    } catch (e) {
      throw DatabaseException('Failed to deactivate member: $e');
    }
  }
}
