import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/double_extensions.dart';
import '../../providers/report_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_display.dart';

class MonthlyTrendsScreen extends ConsumerWidget {
  const MonthlyTrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(monthlyTrendsProvider);

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
              title: const Text('Monthly Trends',
                  style: TextStyle(color: Colors.white, fontSize: 17,
                      fontWeight: FontWeight.w600)),
              titlePadding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          trendsAsync.when(
            data: (summaries) {
              if (summaries.isEmpty) {
                return const SliverFillRemaining(
                    child: EmptyState(message: 'No data yet.'));
              }
              final reversed = summaries.reversed.toList();
              final maxY = summaries
                  .map((s) => s.totalCollected)
                  .fold(0.0, (a, b) => a > b ? a : b);

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Bar chart card
                    _ChartCard(
                      title: 'Total Collected per Month',
                      icon: Icons.bar_chart_rounded,
                      iconColor: AppColors.accent,
                      height: 230,
                      child: BarChart(
                        BarChartData(
                          maxY: (maxY * 1.2).ceilToDouble(),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: AppColors.textHint.withValues(alpha: 0.15),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 48,
                                getTitlesWidget: (v, _) => Text(
                                  v.toInt().toString(),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textHint),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (v, _) {
                                  final i = v.toInt();
                                  if (i < 0 || i >= reversed.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final s = reversed[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      DateFormat('MMM').format(
                                          DateTime(s.year, s.month)),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          barGroups: reversed.asMap().entries.map((e) {
                            return BarChartGroupData(x: e.key, barRods: [
                              BarChartRodData(
                                toY: e.value.totalCollected,
                                gradient: AppColors.accentGradient,
                                width: 18,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Line chart card
                    _ChartCard(
                      title: 'Paid Members per Month',
                      icon: Icons.show_chart_rounded,
                      iconColor: AppColors.gold,
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: AppColors.textHint.withValues(alpha: 0.15),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (v, _) => Text(
                                  v.toInt().toString(),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textHint),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (v, _) {
                                  final i = v.toInt();
                                  if (i < 0 || i >= reversed.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final s = reversed[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      DateFormat('MMM').format(
                                          DateTime(s.year, s.month)),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: reversed
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(),
                                      e.value.paidCount.toDouble()))
                                  .toList(),
                              isCurved: true,
                              color: AppColors.gold,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.gold.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const _SectionLabel('Month-by-Month Breakdown'),
                    const SizedBox(height: 8),

                    ...summaries.map((s) {
                      final pct =
                          (s.collectionRate * 100).toStringAsFixed(0);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('MMMM yyyy').format(
                                            DateTime(s.year, s.month)),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.textPrimary),
                                      ),
                                      Text(
                                          '${s.paidCount}/${s.totalMembers} members paid',
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(s.totalCollected.toCurrency(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                            fontSize: 15)),
                                    Text('$pct%',
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: LinearProgressIndicator(
                                value: s.collectionRate,
                                minHeight: 5,
                                backgroundColor: AppColors.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation(
                                  s.collectionRate >= 0.8
                                      ? AppColors.statusApproved
                                      : s.collectionRate >= 0.5
                                          ? AppColors.gold
                                          : AppColors.statusRejected,
                                ),
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

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final double height;
  final Widget child;
  const _ChartCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700,
                      fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: height, child: child),
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
    return Text(title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.textSecondary, letterSpacing: 1.2));
  }
}
