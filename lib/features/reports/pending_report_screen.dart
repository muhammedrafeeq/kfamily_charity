import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
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
}
