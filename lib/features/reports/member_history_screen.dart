import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/double_extensions.dart';
import '../../models/member_yearly_summary.dart';
import '../../providers/profile_provider.dart';
import '../../providers/report_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_display.dart';

class MemberHistoryScreen extends ConsumerStatefulWidget {
  const MemberHistoryScreen({super.key});

  @override
  ConsumerState<MemberHistoryScreen> createState() => _MemberHistoryScreenState();
}

class _MemberHistoryScreenState extends ConsumerState<MemberHistoryScreen> {
  String? _selectedMemberId;

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final isAdmin = profileAsync.valueOrNull?.isAdmin ?? false;

    if (!isAdmin) {
      _selectedMemberId = profileAsync.valueOrNull?.id;
    }

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
                  decoration: const BoxDecoration(gradient: AppColors.heroGradient)),
              title: const Text('Member History',
                  style: TextStyle(color: Colors.white, fontSize: 17,
                      fontWeight: FontWeight.w600)),
              titlePadding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          if (isAdmin)
            SliverToBoxAdapter(
              child: membersAsync.when(
                data: (members) => Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedMemberId,
                    hint: const Text('Select a member'),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline_rounded),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                    ),
                    items: members
                        .map((m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(
                                  '${m.memberNumber}. ${m.fullName}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMemberId = v),
                  ),
                ),
                loading: () => const SizedBox(
                    height: 4, child: LinearProgressIndicator()),
                error: (e, _) => ErrorDisplay(message: e.toString()),
              ),
            ),

          if (_selectedMemberId == null)
            const SliverFillRemaining(
              child: EmptyState(
                message: 'Select a member to view history',
                icon: Icons.person_search_rounded,
              ),
            )
          else
            _MemberHistorySliver(memberId: _selectedMemberId!),
        ],
      ),
    );
  }
}

class _MemberHistorySliver extends ConsumerWidget {
  final String memberId;
  const _MemberHistorySliver({required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(memberHistoryProvider(memberId));

    return historyAsync.when(
      data: (years) {
        if (years.isEmpty) {
          return const SliverFillRemaining(
              child: EmptyState(message: 'No history found.'));
        }

        final totalPaid = years.fold(0.0, (a, b) => a + b.totalPaid);
        final totalMonths = years.fold(0, (a, b) => a + b.monthsPaid);

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Summary header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: _HeaderStat('Total Paid', totalPaid.toCurrency())),
                    Container(
                        width: 1, height: 40,
                        color: Colors.white.withValues(alpha: 0.2)),
                    Expanded(
                        child: _HeaderStat('Months Paid', '$totalMonths')),
                    Container(
                        width: 1, height: 40,
                        color: Colors.white.withValues(alpha: 0.2)),
                    Expanded(
                        child: _HeaderStat('Years Active', '${years.length}')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const _SectionLabel('Yearly Breakdown'),
              const SizedBox(height: 10),

              ...years.map((y) => _YearCard(summary: y)),
            ]),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (e, _) =>
          SliverFillRemaining(child: ErrorDisplay(message: e.toString())),
    );
  }
}

class _YearCard extends StatelessWidget {
  final MemberYearlySummary summary;
  const _YearCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final rate = summary.reliabilityRate;
    final rateColor = rate >= 0.8
        ? AppColors.statusApproved
        : rate >= 0.5
            ? AppColors.gold
            : AppColors.statusRejected;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Text('${summary.year}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.accent)),
              ),
              const Spacer(),
              Text(summary.totalPaid.toCurrency(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 7,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(rateColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${summary.monthsPaid} of 12 months paid',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const Spacer(),
              Text('${(rate * 100).toStringAsFixed(0)}% reliability',
                  style: TextStyle(
                      color: rateColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeaderStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.textSecondary, letterSpacing: 1.2));
  }
}
