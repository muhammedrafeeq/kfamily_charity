import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../shared/widgets/confirmation_dialog.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  Profile? _profile;
  bool _loading = true;
  bool _saving = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final all = await ref.read(allMembersProvider.future);
    final p = all.where((m) => m.id == widget.memberId).firstOrNull;
    if (p != null) {
      _nameCtrl.text = p.fullName;
      _phoneCtrl.text = p.phone ?? '';
    }
    if (mounted) setState(() { _profile = p; _loading = false; });
  }

  Future<void> _save() async {
    if (_profile == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileServiceProvider).updateProfile(
        userId: _profile!.id,
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );
      ref.invalidate(allMembersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated'),
              backgroundColor: AppColors.statusApproved),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deactivate() async {
    final ok = await showConfirmationDialog(context,
        title: 'Deactivate Member',
        message: 'Remove ${_profile?.fullName} from active members?',
        confirmLabel: 'Deactivate',
        isDestructive: true);
    if (ok != true || _profile == null) return;
    await ref.read(profileServiceProvider).deactivateMember(_profile!.id);
    ref.invalidate(allMembersProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    }

    final p = _profile;
    final initials = p != null && p.fullName.isNotEmpty
        ? p.fullName[0].toUpperCase()
        : '?';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(p?.fullName ?? 'Member',
                style: const TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_remove_rounded, color: Colors.white70),
                tooltip: 'Deactivate Member',
                onPressed: _deactivate,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: const BorderRadius.all(Radius.circular(22)),
                        boxShadow: [BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: Text(initials,
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w800, fontSize: 28)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(p?.fullName ?? 'Member',
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 4),
                    if (p != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Text(
                          'Member #${p.memberNumber}  •  ${p.role.toUpperCase()}',
                          style: const TextStyle(
                              color: AppColors.accent, fontSize: 11,
                              fontWeight: FontWeight.w700, letterSpacing: 1),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionLabel('Edit Profile'),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primary,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                    icon: _saving
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary))
                        : const Icon(Icons.save_rounded),
                    label: Text(_saving ? 'Saving…' : 'Save Changes',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
                if (ref.watch(currentProfileProvider).valueOrNull?.memberNumber == 0) ...[
                  const SizedBox(height: 24),
                  const _SectionLabel('Admin Access'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: p?.role == 'admin' 
                          ? AppColors.accent.withValues(alpha: 0.05) 
                          : AppColors.surface,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(
                        color: p?.role == 'admin' 
                            ? AppColors.accent.withValues(alpha: 0.3) 
                            : const Color(0xFFEEF1F7),
                      ),
                    ),
                    child: SwitchListTile(
                      activeColor: AppColors.accent,
                      title: const Text('Admin Privileges',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        p?.role == 'admin' 
                            ? 'This member has full administrative access' 
                            : 'Grant administrative access to this member',
                        style: const TextStyle(fontSize: 11),
                      ),
                      value: p?.role == 'admin',
                      onChanged: (val) async {
                        final ok = await showConfirmationDialog(
                          context,
                          title: val ? 'Promote to Admin' : 'Revoke Admin Access',
                          message: val 
                              ? 'Are you sure you want to give administrative access to ${p?.fullName}?' 
                              : 'Are you sure you want to remove admin access for ${p?.fullName}?',
                          confirmLabel: val ? 'Promote' : 'Revoke',
                        );
                        if (ok == true) {
                          setState(() => _saving = true);
                          try {
                            await ref.read(profileServiceProvider).updateProfile(
                              userId: widget.memberId,
                              role: val ? 'admin' : 'member',
                            );
                            await _load();
                            ref.invalidate(allMembersProvider);
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('Danger Zone'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.statusRejected.withValues(alpha: 0.06),
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      border: Border.all(
                          color: AppColors.statusRejected.withValues(alpha: 0.2)),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.statusRejected.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Icon(Icons.person_remove_rounded,
                            color: AppColors.statusRejected, size: 20),
                      ),
                      title: const Text('Deactivate Member',
                          style: TextStyle(color: AppColors.statusRejected,
                              fontWeight: FontWeight.w600)),
                      subtitle: const Text('Remove from active members',
                          style: TextStyle(fontSize: 12,
                              color: AppColors.textSecondary)),
                      onTap: _deactivate,
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.textSecondary, letterSpacing: 1.2)),
    );
  }
}
