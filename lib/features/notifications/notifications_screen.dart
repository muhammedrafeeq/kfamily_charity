import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/datetime_extensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_display.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              ),
              title: const Text('Notifications',
                  style: TextStyle(color: Colors.white, fontSize: 17,
                      fontWeight: FontWeight.w600)),
              titlePadding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () async {
                      await ref.read(notificationServiceProvider).markAllAsRead(user.id);
                      ref.invalidate(notificationsProvider);
                      ref.invalidate(unreadCountProvider);
                    },
                    child: const Text('Mark all read',
                        style: TextStyle(color: AppColors.accent, fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
          notifAsync.when(
            data: (notifs) {
              if (notifs.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    message: 'No notifications yet',
                    icon: Icons.notifications_none,
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final n = notifs[i];
                      final color = _iconColor(n.type);
                      return GestureDetector(
                        onTap: n.isRead
                            ? null
                            : () async {
                                await ref.read(notificationServiceProvider).markAsRead(n.id);
                                ref.invalidate(notificationsProvider);
                                ref.invalidate(unreadCountProvider);
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? AppColors.surface
                                : color.withValues(alpha: 0.06),
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            border: Border.all(
                              color: n.isRead
                                  ? Colors.transparent
                                  : color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Icon(_iconData(n.type), color: color, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(n.title,
                                              style: TextStyle(
                                                fontWeight: n.isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.w700,
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              )),
                                        ),
                                        if (!n.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(n.body,
                                        style: const TextStyle(
                                            color: AppColors.textSecondary, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Text(n.createdAt.toDisplayDateTime(),
                                        style: const TextStyle(
                                            color: AppColors.textHint, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: notifs.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
            ),
            error: (e, _) => SliverFillRemaining(child: ErrorDisplay(message: e.toString())),
          ),
        ],
      ),
    );
  }

  IconData _iconData(String type) => switch (type) {
        'payment_approved' => Icons.check_circle_rounded,
        'payment_rejected' => Icons.cancel_rounded,
        'reminder' => Icons.alarm_rounded,
        _ => Icons.notifications_rounded,
      };

  Color _iconColor(String type) => switch (type) {
        'payment_approved' => AppColors.statusApproved,
        'payment_rejected' => AppColors.statusRejected,
        'reminder' => AppColors.gold,
        _ => AppColors.accent,
      };
}
