// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationItemImpl _$$NotificationItemImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationItemImpl(
      id: json['id'] as String,
      recipient: json['recipient'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$NotificationItemImplToJson(
        _$NotificationItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipient': instance.recipient,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'payload': instance.payload,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };
