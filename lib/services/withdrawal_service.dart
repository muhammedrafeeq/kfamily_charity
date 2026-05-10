import '../core/errors/app_exception.dart';
import '../models/withdrawal.dart';
import 'supabase_service.dart';

class WithdrawalService {
  final _client = SupabaseService.client;

  Future<List<Withdrawal>> getWithdrawals() async {
    try {
      final data = await _client
          .from('withdrawals')
          .select('*, withdrawn_by_profile:profiles!withdrawals_withdrawn_by_fkey(*)')
          .order('created_at', ascending: false);
      return data.map((e) => Withdrawal.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load withdrawals: $e');
    }
  }

  Future<double> getTotalWithdrawn() async {
    try {
      final data = await _client.from('withdrawals').select('amount');
      double total = 0.0;
      for (final row in data as List) {
        total += (row['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  Future<Withdrawal> addWithdrawal({
    required double amount,
    required String reason,
    required String userId,
  }) async {
    try {
      final data = await _client
          .from('withdrawals')
          .insert({
            'amount': amount,
            'reason': reason,
            'withdrawn_by': userId,
          })
          .select()
          .single();
      return Withdrawal.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to add withdrawal: $e');
    }
  }

  Future<void> clearAllWithdrawals() async {
    try {
      await _client.from('withdrawals').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e) {
      throw DatabaseException('Failed to clear withdrawals: $e');
    }
  }
}
