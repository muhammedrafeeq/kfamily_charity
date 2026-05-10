import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/payment_cycle.dart';
import 'supabase_service.dart';

class CycleService {
  final _client = SupabaseService.client;

  Future<PaymentCycle?> getCurrentOpenCycle() async {
    try {
      final data = await _client
          .from(SupabaseConstants.cyclesTable)
          .select()
          .eq('status', 'open')
          .maybeSingle();
      return data != null ? PaymentCycle.fromJson(data) : null;
    } catch (e) {
      throw DatabaseException('Failed to load current cycle: $e');
    }
  }

  Future<List<PaymentCycle>> getAllCycles() async {
    try {
      final data = await _client
          .from(SupabaseConstants.cyclesTable)
          .select()
          .order('year', ascending: false)
          .order('month', ascending: false);
      return data.map((e) => PaymentCycle.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load cycles: $e');
    }
  }

  Future<PaymentCycle> openCycle({
    required int year,
    required int month,
    DateTime? endDate,
  }) async {
    try {
      final userId = SupabaseService.auth.currentUser!.id;
      final data = await _client
          .from(SupabaseConstants.cyclesTable)
          .insert({
            'year': year,
            'month': month,
            'status': 'open',
            'created_by': userId,
            if (endDate != null) 'end_date': endDate.toIso8601String(),
          })
          .select()
          .single();
      return PaymentCycle.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to open cycle: $e');
    }
  }

  Future<void> updateCycleEndDate(String cycleId, DateTime newEndDate) async {
    try {
      await _client
          .from(SupabaseConstants.cyclesTable)
          .update({'end_date': newEndDate.toIso8601String()})
          .eq('id', cycleId);
    } catch (e) {
      throw DatabaseException('Failed to update cycle end date: $e');
    }
  }

  Future<PaymentCycle> closeCycle(String cycleId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.cyclesTable)
          .update({'status': 'closed', 'closed_at': DateTime.now().toIso8601String()})
          .eq('id', cycleId)
          .select()
          .single();
      return PaymentCycle.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to close cycle: $e');
    }
  }
}
