import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_utils.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required String recipient,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? payload,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(snakeToCamel(json));
}
