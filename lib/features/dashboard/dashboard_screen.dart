import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/double_extensions.dart';
import '../../core/router/app_routes.dart';
import '../../models/payment_contribution.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/withdrawal_provider.dart';
import '../../shared/widgets/error_display.dart';
import '../../shared/widgets/status_badge.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycleAsync = ref.watch(currentCycleProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final myContribAsync = ref.watch(myContributionProvider);
    final trendsAsync = ref.watch(monthlyTrendsProvider);
    final totalCollectionsAsync = ref.watch(totalCollectionsProvider);
    final totalWithdrawnAsync = ref.watch(totalWithdrawnProvider);
    final l10n = ref.watch(l10nProvider);
    final profile = profileAsync.valueOrNull;

    // Real-time updates
    if (cycleAsync.hasValue && cycleAsync.value != null) {
      ref.watch(contributionSubscriptionProvider(cycleAsync.value!.id));
    }

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          ref.invalidate(currentCycleProvider);
          ref.invalidate(myContributionProvider);
          ref.invalidate(monthlyTrendsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Premium hero app bar
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              centerTitle: false,
              title: Text(
                l10n.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () => context.push(AppRoutes.notifications),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
                const SizedBox(width: 4),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Total collections + balance card
                  _TotalsCard(
                    totalCollected: totalCollectionsAsync.valueOrNull ?? 0,
                    totalWithdrawn: totalWithdrawnAsync.valueOrNull ?? 0,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 16),

                  const _RecentPaymentsTicker(),

                  const SizedBox(height: 16),

                  // Payment window banner
                  if (DateTime.now().day <= 10) ...[
                    _PaymentWindowBanner(),
                    const SizedBox(height: 16),
                  ],

                  // Cycle card
                  cycleAsync.when(
                    data: (cycle) {
                      if (cycle == null) {
                        return _EmptyCycleCard(
                          isAdmin: profile?.isAdmin == true,
                          onTap: () => context.push(AppRoutes.adminCycles),
                        );
                      }
                      return trendsAsync.when(
                        data: (trends) {
                          final summary =
                              trends.where((t) => t.cycleId == cycle.id).firstOrNull;
                          final paid = summary?.paidCount ?? 0;
                          const total = 15;
                          final collected = summary?.totalCollected ?? 0.0;
                          final progress = paid / total;
                          return _CycleHeroCard(
                            cycleName: cycle.displayName,
                            isOpen: cycle.isOpen,
                            collected: collected,
                            paid: paid,
                            total: total,
                            pending: total - paid,
                            rejected: summary?.rejectedCount ?? 0,
                            progress: progress,
                          );
                        },
                        loading: () => const _CardShimmer(),
                        error: (e, _) => ErrorDisplay(message: e.toString()),
                      );
                    },
                    loading: () => const _CardShimmer(),
                    error: (e, _) => ErrorDisplay(message: e.toString()),
                  ),

                  const SizedBox(height: 16),

                  // My payment card
                  myContribAsync.when(
                    data: (contrib) => _MyPaymentCard(
                      contribution: contrib,
                      onSubmit: () => context.push(AppRoutes.submitPayment),
                    ),
                    loading: () => const _CardShimmer(height: 100),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Admin shortcut
                  if (profile?.isAdmin == true) ...[
                    const SizedBox(height: 16),
                    _AdminShortcut(onTap: () => context.push(AppRoutes.adminCycles)),
                  ],

                  // Cashier shortcuts
                  if (profile?.isAdmin == true || profile?.role == 'cashier') ...[
                    const SizedBox(height: 16),
                    _CashierShortcuts(
                      onEntry: () => context.push(AppRoutes.cashierEntry),
                      onWithdraw: () => context.push(AppRoutes.withdrawals),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ── Cycle hero card ─────────────────────────────────────────────────────────
class _CycleHeroCard extends StatelessWidget {
  final String cycleName;
  final bool isOpen;
  final double collected;
  final int paid;
  final int total;
  final int pending;
  final int rejected;
  final double progress;

  const _CycleHeroCard({
    required this.cycleName,
    required this.isOpen,
    required this.collected,
    required this.paid,
    required this.total,
    required this.pending,
    required this.rejected,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(cycleName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen
                      ? AppColors.accent.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    color: isOpen
                        ? AppColors.accent.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOpen ? AppColors.accent : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOpen ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isOpen ? AppColors.accent : Colors.grey.shade400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            collected.toCurrency(),
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
          ),
          const Text('Total Collected',
              style: TextStyle(color: AppColors.textOnDarkSub, fontSize: 13)),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$paid of $total members paid  ·  ${(progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: AppColors.textOnDarkSub, fontSize: 12),
          ),
          const SizedBox(height: 20),
          // Stat row
          Row(
            children: [
              _StatPill(label: 'Paid', value: '$paid', color: AppColors.statusApproved),
              const SizedBox(width: 8),
              _StatPill(label: 'Pending', value: '$pending', color: AppColors.statusPending),
              const SizedBox(width: 8),
              _StatPill(label: 'Rejected', value: '$rejected', color: AppColors.statusRejected),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Payment window banner ────────────────────────────────────────────────────
class _PaymentWindowBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deadline = DateFormat('MMM d').format(
        DateTime(DateTime.now().year, DateTime.now().month, 10));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFFDE7)],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.access_time_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment Window Open',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF5D3E00))),
                Text('Submit your payment before $deadline',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8B5E00))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── My payment card ──────────────────────────────────────────────────────────
class _MyPaymentCard extends StatelessWidget {
  final PaymentContribution? contribution;
  final VoidCallback onSubmit;
  const _MyPaymentCard({required this.contribution, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('My Payment',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          if (contribution == null) ...[
            const Text('No payment submitted yet for this month.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            if (DateTime.now().day <= 10) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: const Text(AppStrings.submit),
                ),
              ),
            ],
          ] else ...[
            Row(
              children: [
                StatusBadge(status: contribution!.status),
                const Spacer(),
                if (contribution!.amount > 0)
                  Text(contribution!.amount.toCurrency(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 22,
                          color: AppColors.primary)),
              ],
            ),
            if (contribution!.isRejected && contribution!.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusRejected.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.statusRejected, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${contribution!.rejectionReason}',
                          style: const TextStyle(
                              color: AppColors.statusRejected, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Resubmit'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Admin shortcut ───────────────────────────────────────────────────────────
class _AdminShortcut extends StatelessWidget {
  final VoidCallback onTap;
  const _AdminShortcut({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: const Row(
          children: [
            Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cycle Management',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                          color: AppColors.primary)),
                  Text('Open or close payment cycles',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Empty cycle ──────────────────────────────────────────────────────────────
class _EmptyCycleCard extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onTap;
  const _EmptyCycleCard({required this.isAdmin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_busy_outlined,
                size: 36, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text('No active payment cycle',
              style: TextStyle(fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary, fontSize: 15)),
          if (isAdmin) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(AppStrings.openCycle),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Shimmer placeholder ──────────────────────────────────────────────────────
class _TotalsCard extends StatelessWidget {
  final double totalCollected;
  final double totalWithdrawn;
  final AppLocalizations l10n;
  const _TotalsCard({
    required this.totalCollected,
    required this.totalWithdrawn,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final balance = totalCollected - totalWithdrawn;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: AppColors.gold, size: 20),
              ),
              const SizedBox(width: 12),
              Text(l10n.fundOverview,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  label: l10n.totalCollected,
                  value: totalCollected.toCurrency(),
                  color: AppColors.statusApproved,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              Container(width: 1, height: 48, color: const Color(0xFFEEF1F7)),
              Expanded(
                child: _OverviewStat(
                  label: l10n.withdrawn,
                  value: totalWithdrawn.toCurrency(),
                  color: AppColors.statusRejected,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              Container(width: 1, height: 48, color: const Color(0xFFEEF1F7)),
              Expanded(
                child: _OverviewStat(
                  label: l10n.balance,
                  value: balance.toCurrency(),
                  color: balance >= 0 ? AppColors.accent : AppColors.statusRejected,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _OverviewStat({
    required this.label, required this.value,
    required this.color, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ── Cashier shortcuts ─────────────────────────────────────────────────────────
class _CashierShortcuts extends StatelessWidget {
  final VoidCallback onEntry;
  final VoidCallback onWithdraw;
  const _CashierShortcuts({required this.onEntry, required this.onWithdraw});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShortcutTile(
            label: 'Cash Entry',
            subtitle: 'Record payments',
            icon: Icons.point_of_sale_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4AA), Color(0xFF00A882)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: onEntry,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ShortcutTile(
            label: 'Withdraw',
            subtitle: 'Record withdrawal',
            icon: Icons.money_off_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFFBF360C), Color(0xFF7B2D00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: onWithdraw,
          ),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _ShortcutTile({
    required this.label, required this.subtitle,
    required this.icon, required this.gradient, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75), fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPaymentsTicker extends ConsumerStatefulWidget {
  const _RecentPaymentsTicker();

  @override
  ConsumerState<_RecentPaymentsTicker> createState() => _RecentPaymentsTickerState();
}

class _RecentPaymentsTickerState extends ConsumerState<_RecentPaymentsTicker> {
  int _currentIndex = 0;
  late final Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _timerStream = Stream.periodic(const Duration(seconds: 4), (i) => i);
  }

  @override
  Widget build(BuildContext context) {
    final recentAsync = ref.watch(recentApprovedPaymentsProvider);

    return recentAsync.when(
      data: (payments) {
        if (payments.isEmpty) return const SizedBox.shrink();

        return StreamBuilder<int>(
          stream: _timerStream,
          builder: (context, snapshot) {
            if (payments.isNotEmpty) {
              _currentIndex = (snapshot.data ?? 0) % payments.length;
            }
            final payment = payments[_currentIndex];
            final memberName = payment.member?.fullName ?? 'Someone';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.statusApproved.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: AppColors.statusApproved, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey<int>(_currentIndex),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              children: [
                                TextSpan(text: memberName,
                                    style: const TextStyle(fontWeight: FontWeight.w700)),
                                const TextSpan(text: ' just contributed '),
                                TextSpan(text: payment.amount.toCurrency(),
                                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.statusApproved)),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, h:mm a').format(
                              payment.reviewedAt?.toLocal() ?? 
                              payment.submittedAt?.toLocal() ?? 
                              payment.createdAt.toLocal()
                            ),
                            style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _CardShimmer extends StatelessWidget {
  final double height;
  const _CardShimmer({this.height = 220});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}
