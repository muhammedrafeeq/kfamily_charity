import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/double_extensions.dart';
import '../../core/router/app_routes.dart';
import '../../models/payment_contribution.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/profile_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_display.dart';
import '../../shared/widgets/month_selector.dart';
import '../../shared/widgets/status_badge.dart';

class PaymentListScreen extends ConsumerStatefulWidget {
  const PaymentListScreen({super.key});

  @override
  ConsumerState<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends ConsumerState<PaymentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String? _selectedCycleId;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cyclesAsync = ref.watch(allCyclesProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final isAdmin = profileAsync.valueOrNull?.isAdmin ?? false;

    return cyclesAsync.when(
      data: (cycles) {
        _selectedCycleId ??= cycles.isNotEmpty ? cycles.first.id : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Payments'),
            bottom: TabBar(
              controller: _tabCtrl,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
              ],
            ),
          ),
          floatingActionButton: isAdmin
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => context.push(AppRoutes.submitPayment),
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('Submit'),
                ),
          body: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MonthSelector(
                  cycles: cycles,
                  selectedCycleId: _selectedCycleId,
                  onSelected: (id) => setState(() => _selectedCycleId = id),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _selectedCycleId == null
                    ? const EmptyState(message: 'No payment cycles yet')
                    : TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _ContributionList(
                            cycleId: _selectedCycleId!,
                            statuses: const ['pending', 'submitted'],
                            isAdmin: isAdmin,
                            currentUserId: profileAsync.valueOrNull?.id,
                          ),
                          _ContributionList(
                            cycleId: _selectedCycleId!,
                            statuses: const ['approved'],
                            isAdmin: isAdmin,
                            currentUserId: profileAsync.valueOrNull?.id,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: ErrorDisplay(message: e.toString())),
    );
  }
}

class _ContributionList extends ConsumerWidget {
  final String cycleId;
  final List<String> statuses;
  final bool isAdmin;
  final String? currentUserId;

  const _ContributionList({
    required this.cycleId,
    required this.statuses,
    required this.isAdmin,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contribAsync = ref.watch(contributionsForCycleProvider(cycleId));

    return contribAsync.when(
      data: (all) {
        final filtered = all.where((c) {
          if (!statuses.contains(c.status)) return false;
          if (!isAdmin && c.memberId != currentUserId) return false;
          return true;
        }).toList();

        if (filtered.isEmpty) {
          return EmptyState(
            message: statuses.contains('approved') ? 'No approved payments' : 'No pending payments',
            icon: Icons.check_circle_outline,
          );
        }

        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async => ref.invalidate(contributionsForCycleProvider(cycleId)),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) =>
                _ContributionTile(contribution: filtered[i], isAdmin: isAdmin),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorDisplay(message: e.toString()),
    );
  }
}

class _ContributionTile extends StatelessWidget {
  final PaymentContribution contribution;
  final bool isAdmin;

  const _ContributionTile({required this.contribution, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final member = contribution.member;
    final num = member?.memberNumber ?? 0;

    // Color per status
    final statusColor = switch (contribution.status) {
      'approved' => AppColors.statusApproved,
      'rejected' => AppColors.statusRejected,
      'submitted' => AppColors.statusSubmitted,
      _ => AppColors.statusPending,
    };

    return GestureDetector(
      onTap: () => context.push('/payments/${contribution.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: const Color(0xFFEEF1F7)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Center(
                child: Text(
                  '$num',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name & amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member?.fullName ?? 'Member',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    contribution.amount > 0
                        ? contribution.amount.toCurrency()
                        : 'Amount not set',
                    style: TextStyle(
                        color: contribution.amount > 0
                            ? AppColors.textSecondary
                            : AppColors.textHint,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: StatusBadge(status: contribution.status),
            ),
          ],
        ),
      ),
    );
  }
}
