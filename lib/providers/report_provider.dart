import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member_yearly_summary.dart';
import '../models/monthly_summary.dart';
import '../services/report_service.dart';

final reportServiceProvider = Provider<ReportService>((ref) => ReportService());

final totalCollectionsProvider = FutureProvider<double>((ref) async {
  final summaries = await ref.read(reportServiceProvider).getMonthlySummaries(limit: 999);
  double total = 0.0;
  for (final s in summaries) { total += s.totalCollected; }
  return total;
});

final monthlyTrendsProvider = FutureProvider<List<MonthlySummary>>((ref) async {
  return ref.read(reportServiceProvider).getMonthlySummaries(limit: 12);
});

final yearlySummaryProvider =
    FutureProvider.family<List<MemberYearlySummary>, int>((ref, year) async {
  return ref.read(reportServiceProvider).getMemberYearlySummaries(year);
});

final memberHistoryProvider =
    FutureProvider.family<List<MemberYearlySummary>, String>((ref, memberId) async {
  return ref.read(reportServiceProvider).getMemberHistory(memberId);
});
