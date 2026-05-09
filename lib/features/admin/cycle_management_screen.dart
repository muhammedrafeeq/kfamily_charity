import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/datetime_extensions.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/error_display.dart';

class CycleManagementScreen extends ConsumerWidget {
  const CycleManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cyclesAsync = ref.watch(allCyclesProvider);
    final currentAsync = ref.watch(currentCycleProvider);

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
              title: const Text('Cycle Management',
                  style: TextStyle(color: Colors.white, fontSize: 17,
                      fontWeight: FontWeight.w600)),
              titlePadding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          cyclesAsync.when(
            data: (cycles) {
              if (cycles.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.calendar_month_rounded,
                              size: 48, color: AppColors.accent),
                        ),
                        const SizedBox(height: 16),
                        const Text('No payment cycles yet',
                            style: TextStyle(fontWeight: FontWeight.w700,
                                fontSize: 16, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const Text('Open the first cycle to start collecting',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => _openCycle(context, ref),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.primary),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Open First Cycle',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final c = cycles[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          border: c.isOpen
                              ? Border.all(
                                  color: AppColors.accent.withValues(alpha: 0.4))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: c.isOpen
                                    ? AppColors.accentGradient
                                    : null,
                                color: c.isOpen
                                    ? null
                                    : AppColors.surfaceVariant,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(14)),
                              ),
                              child: Center(
                                child: Icon(
                                  c.isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                                  color: c.isOpen ? Colors.white : AppColors.textHint,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(c.displayName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: AppColors.textPrimary)),
                                      const SizedBox(width: 8),
                                      if (c.isOpen)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withValues(alpha: 0.15),
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(6)),
                                          ),
                                          child: const Text('OPEN',
                                              style: TextStyle(
                                                  color: AppColors.accent,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    c.isOpen
                                        ? 'Opened ${c.createdAt.toDisplayDate()}'
                                        : 'Closed ${c.closedAt?.toDisplayDate() ?? ''}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (c.isOpen)
                              TextButton(
                                onPressed: () => _closeCycle(
                                    context, ref, c.id, c.displayName),
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.statusRejected),
                                child: const Text('Close',
                                    style: TextStyle(fontWeight: FontWeight.w600)),
                              )
                            else
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.statusApproved, size: 20),
                          ],
                        ),
                      );
                    },
                    childCount: cycles.length,
                  ),
                ),
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
      floatingActionButton: currentAsync.valueOrNull == null
          ? FloatingActionButton.extended(
              onPressed: () => _openCycle(context, ref),
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Open New Cycle',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }

  Future<void> _openCycle(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    int selectedYear = now.year;
    int selectedMonth = now.month;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Open New Cycle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedYear,
                decoration: const InputDecoration(labelText: 'Year'),
                items: [now.year - 1, now.year, now.year + 1]
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (v) => setState(() => selectedYear = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedMonth,
                decoration: const InputDecoration(labelText: 'Month'),
                items: List.generate(12, (i) => i + 1)
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(DateFormat('MMMM').format(DateTime(2000, m))),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedMonth = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Open')),
          ],
        ),
      ),
    );

    if (ok != true) return;
    try {
      await ref.read(cycleServiceProvider).openCycle(
          year: selectedYear, month: selectedMonth);
      ref.invalidate(allCyclesProvider);
      ref.invalidate(currentCycleProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: AppColors.statusRejected),
        );
      }
    }
  }

  Future<void> _closeCycle(BuildContext context, WidgetRef ref, String cycleId,
      String displayName) async {
    final pending =
        await ref.read(pendingContributionsProvider(cycleId).future);
    if (!context.mounted) return;

    final ok = await showConfirmationDialog(
      context,
      title: 'Close Cycle',
      message: pending.isEmpty
          ? 'Close "$displayName"? All members have paid.'
          : 'Close "$displayName"? ${pending.length} member(s) still have pending payments.',
      confirmLabel: 'Close Cycle',
      isDestructive: true,
    );

    if (ok != true) return;
    try {
      await ref.read(cycleServiceProvider).closeCycle(cycleId);
      ref.invalidate(allCyclesProvider);
      ref.invalidate(currentCycleProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: AppColors.statusRejected),
        );
      }
    }
  }
}
