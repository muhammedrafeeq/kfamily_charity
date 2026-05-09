import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/double_extensions.dart';
import '../../providers/report_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_display.dart';

class YearlySummaryScreen extends ConsumerStatefulWidget {
  const YearlySummaryScreen({super.key});

  @override
  ConsumerState<YearlySummaryScreen> createState() => _YearlySummaryScreenState();
}

class _YearlySummaryScreenState extends ConsumerState<YearlySummaryScreen> {
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(yearlySummaryProvider(_year));

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
              title: const Text('Yearly Summary',
                  style: TextStyle(color: Colors.white, fontSize: 17,
                      fontWeight: FontWeight.w600)),
              titlePadding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Year picker
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _year--),
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: AppColors.accent, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text('$_year',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _year < DateTime.now().year
                        ? () => setState(() => _year++)
                        : null,
                    icon: Icon(Icons.chevron_right_rounded,
                        color: _year < DateTime.now().year
                            ? AppColors.accent
                            : AppColors.textHint,
                        size: 28),
                  ),
                ],
              ),
            ),
          ),

          summaryAsync.when(
            data: (summaries) {
              if (summaries.isEmpty) {
                return const SliverFillRemaining(
                    child: EmptyState(message: 'No data for this year.'));
              }

              final totalPaid =
                  summaries.fold(0.0, (a, b) => a + b.totalPaid);
              final totalMonthsPaid =
                  summaries.fold(0, (a, b) => a + b.monthsPaid);
              final totalMonthsPending =
                  summaries.fold(0, (a, b) => a + b.monthsPending);
              final totalMonthsRejected = summaries.length * 12 -
                  totalMonthsPaid -
                  totalMonthsPending;

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Top stats row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Total Collected',
                            value: totalPaid.toCurrency(),
                            color: AppColors.accent,
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: 'Members',
                            value: '${summaries.length}',
                            color: AppColors.gold,
                            icon: Icons.people_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Pie chart
                    Container(
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
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppColors.statusSubmitted
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: const Icon(Icons.pie_chart_rounded,
                                    color: AppColors.statusSubmitted, size: 16),
                              ),
                              const SizedBox(width: 10),
                              const Text('Contribution Distribution',
                                  style: TextStyle(fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: PieChart(PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: totalMonthsPaid.toDouble(),
                                  color: AppColors.chartPaid,
                                  title: 'Paid\n$totalMonthsPaid',
                                  radius: 85,
                                  titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                PieChartSectionData(
                                  value: totalMonthsPending.toDouble(),
                                  color: AppColors.chartPending,
                                  title: 'Pending\n$totalMonthsPending',
                                  radius: 85,
                                  titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                if (totalMonthsRejected > 0)
                                  PieChartSectionData(
                                    value: totalMonthsRejected.toDouble(),
                                    color: AppColors.chartRejected,
                                    title: 'Rejected\n$totalMonthsRejected',
                                    radius: 85,
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                              ],
                              centerSpaceRadius: 30,
                              sectionsSpace: 2,
                            )),
                          ),
                          const SizedBox(height: 12),
                          // Legend
                          Wrap(
                            spacing: 16,
                            children: [
                              _Legend('Paid', AppColors.chartPaid),
                              _Legend('Pending', AppColors.chartPending),
                              if (totalMonthsRejected > 0)
                                _Legend('Rejected', AppColors.chartRejected),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const _SectionLabel('Member Reliability'),
                    const SizedBox(height: 10),

                    ...summaries.map((s) {
                      final rate = s.reliabilityRate;
                      final rateColor = rate >= 0.8
                          ? AppColors.statusApproved
                          : rate >= 0.5
                              ? AppColors.gold
                              : AppColors.statusRejected;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                gradient: AppColors.heroGradient,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              child: Center(
                                child: Text('${s.memberNumber}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(s.fullName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: AppColors.textPrimary)),
                                      ),
                                      Text(s.totalPaid.toCurrency(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                              fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius:
                                        const BorderRadius.all(Radius.circular(4)),
                                    child: LinearProgressIndicator(
                                      value: rate,
                                      minHeight: 5,
                                      backgroundColor: AppColors.surfaceVariant,
                                      valueColor:
                                          AlwaysStoppedAnimation(rateColor),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${s.monthsPaid}/12 months  •  ${(rate * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                        color: rateColor, fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800, color: color)),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(
            fontSize: 12, color: AppColors.textSecondary)),
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
