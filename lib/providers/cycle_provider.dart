import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_cycle.dart';
import '../services/cycle_service.dart';

final cycleServiceProvider = Provider<CycleService>((ref) => CycleService());

final currentCycleProvider = FutureProvider<PaymentCycle?>((ref) async {
  return ref.read(cycleServiceProvider).getCurrentOpenCycle();
});

final allCyclesProvider = FutureProvider<List<PaymentCycle>>((ref) async {
  return ref.read(cycleServiceProvider).getAllCycles();
});
