import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/withdrawal.dart';
import '../services/withdrawal_service.dart';

final withdrawalServiceProvider = Provider<WithdrawalService>((ref) => WithdrawalService());

final withdrawalsProvider = FutureProvider<List<Withdrawal>>((ref) async {
  return ref.read(withdrawalServiceProvider).getWithdrawals();
});

final totalWithdrawnProvider = FutureProvider<double>((ref) async {
  return ref.read(withdrawalServiceProvider).getTotalWithdrawn();
});
