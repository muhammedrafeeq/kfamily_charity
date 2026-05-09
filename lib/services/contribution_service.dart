import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/payment_contribution.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

class ContributionService {
  final _client = SupabaseService.client;
  final _storageService = StorageService();

  Future<List<PaymentContribution>> getContributionsForCycle(String cycleId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.contributionsTable)
          .select('*, member:profiles!payment_contributions_member_id_fkey(*)')
          .eq('cycle_id', cycleId)
          .order('created_at', ascending: false);
      return data.map((e) => PaymentContribution.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load contributions: $e');
    }
  }

  Future<PaymentContribution?> getMyContribution({
    required String cycleId,
    required String memberId,
  }) async {
    try {
      final data = await _client
          .from(SupabaseConstants.contributionsTable)
          .select()
          .eq('cycle_id', cycleId)
          .eq('member_id', memberId)
          .maybeSingle();
      return data != null ? PaymentContribution.fromJson(data) : null;
    } catch (e) {
      throw DatabaseException('Failed to load contribution: $e');
    }
  }

  Future<PaymentContribution> submitPayment({
    required String cycleId,
    required String memberId,
    required double amount,
    required XFile screenshotFile,
    required int year,
    required int month,
    String? notes,
  }) async {
    final path = await _storageService.uploadScreenshot(
      file: screenshotFile,
      year: year,
      month: month,
      memberId: memberId,
    );

    final signedUrl = await _storageService.getSignedUrl(path);

    try {
      final existing = await getMyContribution(cycleId: cycleId, memberId: memberId);

      if (existing != null) {
        // Delete old screenshot if resubmitting
        if (existing.screenshotPath != null) {
          await _storageService.deleteScreenshot(existing.screenshotPath!);
        }

        final data = await _client
            .from(SupabaseConstants.contributionsTable)
            .update({
              'amount': amount,
              'status': 'submitted',
              'screenshot_url': signedUrl,
              'screenshot_path': path,
              'submitted_at': DateTime.now().toIso8601String(),
              'notes': notes,
              'rejection_reason': null,
            })
            .eq('id', existing.id)
            .select()
            .single();
        return PaymentContribution.fromJson(data);
      } else {
        final data = await _client
            .from(SupabaseConstants.contributionsTable)
            .insert({
              'cycle_id': cycleId,
              'member_id': memberId,
              'amount': amount,
              'status': 'submitted',
              'screenshot_url': signedUrl,
              'screenshot_path': path,
              'submitted_at': DateTime.now().toIso8601String(),
              'notes': notes,
            })
            .select()
            .single();
        return PaymentContribution.fromJson(data);
      }
    } catch (e) {
      throw DatabaseException('Failed to submit payment: $e');
    }
  }

  // Cashier directly records a cash payment as approved — no screenshot required
  Future<PaymentContribution> cashierSubmitPayment({
    required String cycleId,
    required String memberId,
    required double amount,
    String? notes,
  }) async {
    try {
      final cashierId = SupabaseService.auth.currentUser!.id;
      final existing = await getMyContribution(cycleId: cycleId, memberId: memberId);
      if (existing != null) {
        final data = await _client
            .from(SupabaseConstants.contributionsTable)
            .update({
              'amount': amount,
              'status': 'approved',
              'submitted_at': DateTime.now().toIso8601String(),
              'reviewed_at': DateTime.now().toIso8601String(),
              'reviewed_by': cashierId,
              'notes': notes ?? 'Recorded by cashier',
              'rejection_reason': null,
            })
            .eq('id', existing.id)
            .select()
            .single();
        return PaymentContribution.fromJson(data);
      } else {
        final data = await _client
            .from(SupabaseConstants.contributionsTable)
            .insert({
              'cycle_id': cycleId,
              'member_id': memberId,
              'amount': amount,
              'status': 'approved',
              'submitted_at': DateTime.now().toIso8601String(),
              'reviewed_at': DateTime.now().toIso8601String(),
              'reviewed_by': cashierId,
              'notes': notes ?? 'Recorded by cashier',
            })
            .select()
            .single();
        return PaymentContribution.fromJson(data);
      }
    } catch (e) {
      throw DatabaseException('Failed to record cash payment: $e');
    }
  }

  Future<PaymentContribution> approveContribution(String contributionId) async {
    try {
      final reviewerId = SupabaseService.auth.currentUser!.id;
      final data = await _client
          .from(SupabaseConstants.contributionsTable)
          .update({
            'status': 'approved',
            'reviewed_at': DateTime.now().toIso8601String(),
            'reviewed_by': reviewerId,
          })
          .eq('id', contributionId)
          .select()
          .single();
      return PaymentContribution.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to approve contribution: $e');
    }
  }

  Future<PaymentContribution> rejectContribution({
    required String contributionId,
    required String reason,
  }) async {
    try {
      final reviewerId = SupabaseService.auth.currentUser!.id;
      final data = await _client
          .from(SupabaseConstants.contributionsTable)
          .update({
            'status': 'rejected',
            'rejection_reason': reason,
            'reviewed_at': DateTime.now().toIso8601String(),
            'reviewed_by': reviewerId,
          })
          .eq('id', contributionId)
          .select()
          .single();
      return PaymentContribution.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to reject contribution: $e');
    }
  }

  Future<List<PaymentContribution>> getPendingContributions(String cycleId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.contributionsTable)
          .select('*, member:profiles!payment_contributions_member_id_fkey(*)')
          .eq('cycle_id', cycleId)
          .inFilter('status', ['pending', 'submitted'])
          .order('created_at');
      return data.map((e) => PaymentContribution.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load pending contributions: $e');
    }
  }
}
