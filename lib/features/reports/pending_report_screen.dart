import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../models/profile.dart';
import '../../models/payment_contribution.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/notification_service.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_display.dart';

class PendingReportScreen extends ConsumerWidget {
  const PendingReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycleAsync = ref.watch(currentCycleProvider);
    final isAdmin = ref.watch(currentProfileProvider).valueOrNull?.isAdmin ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              ),
              title: const Text('Pending Report',
                  style: TextStyle(color: Colors.white, fontSize: 17,
                      fontWeight: FontWeight.w600)),
              titlePadding: const EdgeInsetsDirectional.fromSTEB(72, 0, 56, 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                tooltip: 'Export for WhatsApp',
                onPressed: () => _showWhatsAppExportDialog(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                tooltip: 'Export CSV',
                onPressed: () => _exportCsv(context, ref),
              ),
            ],
          ),
          cycleAsync.when(
            data: (cycle) {
              if (cycle == null) {
                return const SliverFillRemaining(
                  child: EmptyState(message: 'No active payment cycle'),
                );
              }
              final pendingAsync = ref.watch(pendingContributionsProvider(cycle.id));
              return pendingAsync.when(
                data: (pending) {
                  if (pending.isEmpty) {
                    return const SliverFillRemaining(
                      child: EmptyState(
                        message: 'All members have paid!',
                        icon: Icons.celebration_rounded,
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Summary banner
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: const Icon(Icons.pending_actions_rounded,
                                  color: AppColors.gold, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${pending.length} member${pending.length == 1 ? '' : 's'} pending',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    'For ${cycle.displayName}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // List items
                      ...pending.asMap().entries.map((entry) {
                        final c = entry.value;
                        final member = c.member;
                        return Container(
                          margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.heroGradient,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Center(
                                  child: Text(
                                    '${member?.memberNumber ?? '?'}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member?.fullName ?? 'Unknown',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.textPrimary),
                                    ),
                                    if (member?.phone != null)
                                      Text(member!.phone!,
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (isAdmin)
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(alpha: 0.15),
                                      borderRadius:
                                          const BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: const Icon(
                                        Icons.notifications_active_rounded,
                                        color: AppColors.gold,
                                        size: 16),
                                  ),
                                  onPressed: () async {
                                    if (member == null) return;
                                    await NotificationService().sendReminder(
                                      recipientId: member.id,
                                      cycleDisplay: cycle.displayName,
                                    );
                                    ref.invalidate(notificationsProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Reminder sent to ${member.fullName}'),
                                          backgroundColor: AppColors.statusApproved,
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 40),
                    ]),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent)),
                ),
                error: (e, _) =>
                    SliverFillRemaining(child: ErrorDisplay(message: e.toString())),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
            ),
            error: (e, _) =>
                SliverFillRemaining(child: ErrorDisplay(message: e.toString())),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final cycle = await ref.read(currentCycleProvider.future);
    if (cycle == null) return;
    final pending = await ref.read(pendingContributionsProvider(cycle.id).future);

    final lines = ['Member No,Name,Phone,Status'];
    for (final c in pending) {
      final m = c.member;
      lines.add('${m?.memberNumber},${m?.fullName},${m?.phone ?? ''},${c.status}');
    }
    final csv = lines.join('\n');
    await Share.share(csv, subject: 'Pending Report - ${cycle.displayName}');
  }

  void _showWhatsAppExportDialog(BuildContext context, WidgetRef ref) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );

    try {
      final cycle = await ref.read(currentCycleProvider.future);
      if (cycle == null) {
        if (context.mounted) Navigator.pop(context);
        return;
      }

      final allMembers = await ref.read(allMembersProvider.future);
      final contributions = await ref.read(contributionsForCycleProvider(cycle.id).future);

      if (context.mounted) Navigator.pop(context);

      final activeMembers = allMembers.where((m) => m.isActive).toList()
        ..sort((a, b) => a.memberNumber.compareTo(b.memberNumber));

      final paidMembers = <Profile>[];
      final unpaidMembers = <Profile>[];

      for (final member in activeMembers) {
        final contribution = contributions.cast<PaymentContribution?>().firstWhere(
          (c) => c?.memberId == member.id,
          orElse: () => null,
        );

        if (contribution != null && contribution.status == 'approved') {
          paidMembers.add(member);
        } else {
          unpaidMembers.add(member);
        }
      }

      final buffer = StringBuffer();
      buffer.writeln('● *KFamily Charity Fund* ●');
      buffer.writeln('*Collection Status: ${cycle.displayName}*');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln();
      
      buffer.writeln('✅ *PAID MEMBERS (${paidMembers.length})*');
      if (paidMembers.isEmpty) {
        buffer.writeln('_None yet_');
      } else {
        for (var i = 0; i < paidMembers.length; i++) {
          final m = paidMembers[i];
          buffer.writeln('${i + 1}. *[No. ${m.memberNumber}]* ${m.fullName}');
        }
      }
      buffer.writeln();

      buffer.writeln('❌ *NOT PAID MEMBERS (${unpaidMembers.length})*');
      if (unpaidMembers.isEmpty) {
        buffer.writeln('_All members have paid!_ 🎉');
      } else {
        for (var i = 0; i < unpaidMembers.length; i++) {
          final m = unpaidMembers[i];
          buffer.writeln('${i + 1}. *[No. ${m.memberNumber}]* ${m.fullName}');
        }
      }
      buffer.writeln();
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('*Summary:*');
      buffer.writeln('• Total: ${activeMembers.length} members');
      buffer.writeln('• Paid: ${paidMembers.length} (✅)');
      buffer.writeln('• Pending: ${unpaidMembers.length} (❌)');

      final shareText = buffer.toString();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => _WhatsAppShareDialog(
            shareText: shareText,
            cycleName: cycle.displayName,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: AppColors.statusRejected,
          ),
        );
      }
    }
  }
}

class _WhatsAppShareDialog extends StatefulWidget {
  final String shareText;
  final String cycleName;

  const _WhatsAppShareDialog({
    required this.shareText,
    required this.cycleName,
  });

  @override
  State<_WhatsAppShareDialog> createState() => _WhatsAppShareDialogState();
}

class _WhatsAppShareDialogState extends State<_WhatsAppShareDialog> {
  bool _copied = false;

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.shareText));
    if (mounted) setState(() => _copied = true);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _shareToWhatsApp() async {
    await Share.share(
      widget.shareText,
      subject: 'KFamily Charity Status - ${widget.cycleName}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.background,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'WhatsApp Export',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Preview Formatted Message:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E7F0), width: 1),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SelectableText(
                  widget.shareText,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: Color(0xFFD8DFEA), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Close'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _copied ? AppColors.statusApproved : AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: Icon(_copied ? Icons.check_circle_outline_rounded : Icons.copy_all_rounded, size: 18),
                    label: Text(_copied ? 'Copied! ✅' : 'Copy Text'),
                    onPressed: _copyToClipboard,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share Status Report'),
              onPressed: _shareToWhatsApp,
            ),
          ],
        ),
      ),
    );
  }
}
