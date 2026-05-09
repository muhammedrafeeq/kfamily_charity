import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/member_yearly_summary.dart';
import '../models/monthly_summary.dart';
import 'supabase_service.dart';

class ReportService {
  final _client = SupabaseService.client;

  Future<List<MonthlySummary>> getMonthlySummaries({int limit = 12}) async {
    try {
      final data = await _client
          .from(SupabaseConstants.monthlySummaryView)
          .select()
          .order('year', ascending: false)
          .order('month', ascending: false)
          .limit(limit);
      return data.map((e) => MonthlySummary.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load monthly summaries: $e');
    }
  }

  Future<MonthlySummary?> getSummaryForCycle(String cycleId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.monthlySummaryView)
          .select()
          .eq('cycle_id', cycleId)
          .maybeSingle();
      return data != null ? MonthlySummary.fromJson(data) : null;
    } catch (e) {
      throw DatabaseException('Failed to load cycle summary: $e');
    }
  }

  Future<List<MemberYearlySummary>> getMemberYearlySummaries(int year) async {
    try {
      final data = await _client
          .from(SupabaseConstants.memberYearlySummaryView)
          .select()
          .eq('year', year)
          .order('months_paid', ascending: false);
      return data.map((e) => MemberYearlySummary.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load yearly summaries: $e');
    }
  }

  Future<List<MemberYearlySummary>> getMemberHistory(String memberId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.memberYearlySummaryView)
          .select()
          .eq('member_id', memberId)
          .order('year', ascending: false);
      return data.map((e) => MemberYearlySummary.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load member history: $e');
    }
  }
}
