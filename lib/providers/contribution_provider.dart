import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_contribution.dart';
import '../services/contribution_service.dart';
import '../services/supabase_service.dart';
import '../core/constants/supabase_constants.dart';
import 'auth_provider.dart';
import 'cycle_provider.dart';
import 'report_provider.dart';

final contributionServiceProvider =
    Provider<ContributionService>((ref) => ContributionService());

final contributionsForCycleProvider =
    FutureProvider.family<List<PaymentContribution>, String>((ref, cycleId) async {
  return ref.read(contributionServiceProvider).getContributionsForCycle(cycleId);
});

final myContributionProvider = FutureProvider<PaymentContribution?>((ref) async {
  final user = ref.watch(currentUserProvider);
  final cycle = await ref.watch(currentCycleProvider.future);
  if (user == null || cycle == null) return null;
  return ref
      .read(contributionServiceProvider)
      .getMyContribution(cycleId: cycle.id, memberId: user.id);
});

final pendingContributionsProvider =
    FutureProvider.family<List<PaymentContribution>, String>((ref, cycleId) async {
  return ref.read(contributionServiceProvider).getPendingContributions(cycleId);
});

final recentApprovedPaymentsProvider = FutureProvider<List<PaymentContribution>>((ref) async {
  return ref.read(contributionServiceProvider).getRecentApprovedPayments();
});

final contributionSubscriptionProvider = Provider.family<void, String>((ref, cycleId) {
  final channel = SupabaseService.client
      .channel('${SupabaseConstants.contributionsChannel}:$cycleId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: SupabaseConstants.contributionsTable,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'cycle_id',
          value: cycleId,
        ),
        callback: (_) {
          ref.invalidate(contributionsForCycleProvider(cycleId));
          ref.invalidate(myContributionProvider);
          ref.invalidate(monthlyTrendsProvider);
          ref.invalidate(totalCollectionsProvider);
          ref.invalidate(recentApprovedPaymentsProvider);
        },
      )
      .subscribe();

  ref.onDispose(() => SupabaseService.client.removeChannel(channel));
});
