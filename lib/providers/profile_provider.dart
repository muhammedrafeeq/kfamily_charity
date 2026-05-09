import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';
import 'auth_provider.dart';

final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(profileServiceProvider).getProfile(user.id);
});

final allMembersProvider = FutureProvider<List<Profile>>((ref) async {
  return ref.read(profileServiceProvider).getAllMembers();
});
