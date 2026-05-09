import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/router/app_routes.dart';
import '../../shared/widgets/confirmation_dialog.dart';

final _themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final themeMode = ref.watch(_themeModeProvider);
    final language = ref.watch(languageProvider);
    final l10n = ref.watch(l10nProvider);
    final profile = profileAsync.valueOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
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
                          child: Text(
                            profile != null && profile.fullName.isNotEmpty
                                ? profile.fullName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w800, fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(profile?.fullName ?? 'Loading…',
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Text(profile?.role.toUpperCase() ?? '',
                            style: const TextStyle(color: AppColors.accent,
                                fontSize: 11, fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                      ),
                    ],
                  ),
                ),
              ),
              title: Text(l10n.settings,
                  style: const TextStyle(color: Colors.white, fontSize: 17,
                      fontWeight: FontWeight.w600)),
              titlePadding: const EdgeInsetsDirectional.fromSTEB(72, 0, 0, 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionLabel(l10n.appearance),
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  iconColor: AppColors.statusSubmitted,
                  title: l10n.theme,
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    underline: const SizedBox.shrink(),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    ],
                    onChanged: (v) {
                      if (v != null) ref.read(_themeModeProvider.notifier).state = v;
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  iconColor: AppColors.gold,
                  title: l10n.languageStr,
                  trailing: DropdownButton<AppLanguage>(
                    value: language,
                    underline: const SizedBox.shrink(),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    items: const [
                      DropdownMenuItem(value: AppLanguage.english, child: Text('English')),
                      DropdownMenuItem(value: AppLanguage.malayalam, child: Text('മലയാളം')),
                    ],
                    onChanged: (v) {
                      if (v != null) ref.read(languageProvider.notifier).state = v;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _SectionLabel(l10n.account),
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.accent,
                  title: l10n.editProfile,
                  onTap: profile == null ? null : () => context.push('/members/${profile.id}'),
                ),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  iconColor: AppColors.gold,
                  title: l10n.changePassword,
                  onTap: () => _changePassword(context, ref),
                ),
                const SizedBox(height: 16),
                if (profile?.isAdmin ?? false) ...[
                  const _SectionLabel('Admin Tools'),
                  _SettingsTile(
                    icon: Icons.group_add_outlined,
                    iconColor: AppColors.primary,
                    title: 'Bulk Update Phone Numbers',
                    onTap: () => context.push(AppRoutes.bulkUpdateMembers),
                  ),
                  _SettingsTile(
                    icon: Icons.history_rounded,
                    iconColor: AppColors.primary,
                    title: 'Cycle Management',
                    onTap: () => context.push(AppRoutes.adminCycles),
                  ),
                  const SizedBox(height: 16),
                ],
                _SectionLabel(l10n.about),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.textSecondary,
                  title: 'KFamily Charity',
                  subtitle: 'Version 1.0.0',
                ),
                const SizedBox(height: 16),
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
                      child: const Icon(Icons.logout_rounded,
                          color: AppColors.statusRejected, size: 20),
                    ),
                    title: Text(l10n.signOut,
                        style: const TextStyle(color: AppColors.statusRejected,
                            fontWeight: FontWeight.w600)),
                    onTap: () async {
                      final ok = await showConfirmationDialog(context,
                          title: 'Sign Out',
                          message: 'Are you sure you want to sign out?',
                          confirmLabel: 'Sign Out',
                          isDestructive: true);
                      if (ok == true) {
                        await ref.read(authServiceProvider).signOut();
                      }
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (ctrl.text.length < 6) return;
              await ref.read(authServiceProvider).updatePassword(ctrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.textSecondary, letterSpacing: 1.2)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint, size: 20)
                : null),
      ),
    );
  }
}
