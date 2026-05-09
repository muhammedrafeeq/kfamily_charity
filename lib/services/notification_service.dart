import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/notification_item.dart';
import 'supabase_service.dart';

class NotificationService {
  final _client = SupabaseService.client;

  Future<List<NotificationItem>> getNotifications(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.notificationsTable)
          .select()
          .eq('recipient', userId)
          .order('created_at', ascending: false)
          .limit(50);
      return data.map((e) => NotificationItem.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load notifications: $e');
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.notificationsTable)
          .select()
          .eq('recipient', userId)
          .eq('is_read', false);
      return (data as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from(SupabaseConstants.notificationsTable)
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw DatabaseException('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from(SupabaseConstants.notificationsTable)
          .update({'is_read': true})
          .eq('recipient', userId)
          .eq('is_read', false);
    } catch (e) {
      throw DatabaseException('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> sendReminder({
    required String recipientId,
    required String cycleDisplay,
  }) async {
    try {
      await _client.from(SupabaseConstants.notificationsTable).insert({
        'recipient': recipientId,
        'title': 'Payment Reminder',
        'body': 'Please submit your payment for $cycleDisplay before the 10th.',
        'type': 'reminder',
      });
    } catch (e) {
      throw DatabaseException('Failed to send reminder: $e');
    }
  }

  Future<void> notifyPaymentStatus({
    required String recipientId,
    required String status,
    required String cycleDisplay,
    String? rejectionReason,
  }) async {
    final isApproved = status == 'approved';
    await _client.from(SupabaseConstants.notificationsTable).insert({
      'recipient': recipientId,
      'title': isApproved ? 'Payment Approved' : 'Payment Rejected',
      'body': isApproved
          ? 'Your payment for $cycleDisplay has been approved.'
          : 'Your payment for $cycleDisplay was rejected. Reason: $rejectionReason',
      'type': isApproved ? 'payment_approved' : 'payment_rejected',
    });
  }
}
