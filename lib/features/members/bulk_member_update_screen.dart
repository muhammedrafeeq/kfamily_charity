import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';

class BulkMemberUpdateScreen extends ConsumerStatefulWidget {
  const BulkMemberUpdateScreen({super.key});

  @override
  ConsumerState<BulkMemberUpdateScreen> createState() => _BulkMemberUpdateScreenState();
}

class _BulkMemberUpdateScreenState extends ConsumerState<BulkMemberUpdateScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAll(List<Profile> members) async {
    setState(() => _saving = true);
    try {
      final service = ref.read(profileServiceProvider);
      int count = 0;
      for (final m in members) {
        final newPhone = _controllers[m.id]?.text.trim() ?? '';
        if (newPhone != (m.phone ?? '')) {
          await service.updateProfile(
            userId: m.id,
            phone: newPhone.isEmpty ? null : newPhone,
          );
          count++;
        }
      }
      ref.invalidate(allMembersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated $count member(s)'),
              backgroundColor: AppColors.statusApproved),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()),
              backgroundColor: AppColors.statusRejected),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Update Phone Numbers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: membersAsync.when(
        data: (members) {
          // Initialize controllers
          for (final m in members) {
            _controllers.putIfAbsent(m.id, () => TextEditingController(text: m.phone ?? ''));
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.gold.withValues(alpha: 0.1),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.gold, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Update phone numbers for all members below. Only changed numbers will be saved.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final m = members[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardShadow.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                            child: Text('${m.memberNumber}',
                                style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(m.role.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _controllers[m.id],
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : () => _saveAll(members),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primary,
                    ),
                    child: _saving
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : const Text('Save All Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
      ),
    );
  }
}
