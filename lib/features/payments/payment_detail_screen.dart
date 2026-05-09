import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/datetime_extensions.dart';
import '../../core/extensions/double_extensions.dart';
import '../../models/payment_contribution.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/report_provider.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/status_badge.dart';

class PaymentDetailScreen extends ConsumerStatefulWidget {
  final String contributionId;
  const PaymentDetailScreen({super.key, required this.contributionId});

  @override
  ConsumerState<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends ConsumerState<PaymentDetailScreen> {
  PaymentContribution? _contribution;
  String? _signedUrl;
  bool _loading = true;
  bool _actionLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final cycle = await ref.read(currentCycleProvider.future);
      if (cycle == null) return;
      final all = await ref.read(contributionServiceProvider).getContributionsForCycle(cycle.id);
      final c = all.where((c) => c.id == widget.contributionId).firstOrNull;
      if (c == null) return;
      String? url;
      if (c.screenshotPath != null) {
        url = await StorageService().getSignedUrl(c.screenshotPath!);
      }
      if (mounted) setState(() { _contribution = c; _signedUrl = url; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _approve() async {
    final ok = await showConfirmationDialog(context,
        title: 'Approve Payment',
        message: 'Approve ${_contribution!.amount.toCurrency()} from ${_contribution!.member?.fullName}?',
        confirmLabel: 'Approve');
    if (ok != true) return;
    setState(() => _actionLoading = true);
    try {
      await ref.read(contributionServiceProvider).approveContribution(widget.contributionId);
      await NotificationService().notifyPaymentStatus(
        recipientId: _contribution!.memberId,
        status: 'approved',
        cycleDisplay: _contribution!.cycle?.displayName ?? 'this month',
      );
      ref.invalidate(notificationsProvider);
      ref.invalidate(totalCollectionsProvider);
      ref.invalidate(monthlyTrendsProvider);
      if (_contribution?.cycleId != null) {
        ref.invalidate(contributionsForCycleProvider(_contribution!.cycleId));
      }
      await _load();
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _reject() async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Payment'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Reason for rejection'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusRejected),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (ok != true || reasonCtrl.text.trim().isEmpty) return;
    setState(() => _actionLoading = true);
    try {
      await ref.read(contributionServiceProvider).rejectContribution(
        contributionId: widget.contributionId,
        reason: reasonCtrl.text.trim(),
      );
      await NotificationService().notifyPaymentStatus(
        recipientId: _contribution!.memberId,
        status: 'rejected',
        cycleDisplay: _contribution!.cycle?.displayName ?? 'this month',
        rejectionReason: reasonCtrl.text.trim(),
      );
      ref.invalidate(notificationsProvider);
      ref.invalidate(totalCollectionsProvider);
      ref.invalidate(monthlyTrendsProvider);
      if (_contribution?.cycleId != null) {
        ref.invalidate(contributionsForCycleProvider(_contribution!.cycleId));
      }
      await _load();
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(currentProfileProvider).valueOrNull?.isAdmin ?? false;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }
    final c = _contribution!;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Member header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Center(
                      child: Text('${c.member?.memberNumber ?? '?'}',
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800, fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.member?.fullName ?? 'Member',
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w700, fontSize: 18)),
                        if (c.member?.phone != null)
                          Text(c.member!.phone!,
                              style: const TextStyle(
                                  color: AppColors.textOnDarkSub, fontSize: 13)),
                      ],
                    ),
                  ),
                  StatusBadge(status: c.status),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Amount & dates
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.amount > 0) ...[
                    Text(c.amount.toCurrency(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                    const SizedBox(height: 4),
                    const Text('Payment Amount',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],
                  if (c.submittedAt != null)
                    _InfoRow(Icons.upload_rounded, 'Submitted',
                        c.submittedAt!.toDisplayDateTime()),
                  if (c.reviewedAt != null)
                    _InfoRow(Icons.verified_rounded, 'Reviewed',
                        c.reviewedAt!.toDisplayDateTime()),
                  if (c.rejectionReason != null)
                    _InfoRow(Icons.info_outline_rounded, 'Rejection Reason',
                        c.rejectionReason!, color: AppColors.statusRejected),
                  if (c.notes != null)
                    _InfoRow(Icons.sticky_note_2_outlined, 'Notes', c.notes!),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Screenshot
            if (_signedUrl != null) ...[
              const Text('Payment Screenshot',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _showFullScreen(context, _signedUrl!),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: _signedUrl!,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(height: 260,
                        color: AppColors.surfaceVariant,
                        child: const Center(child: CircularProgressIndicator(
                            color: AppColors.accent))),
                    errorWidget: (_, __, ___) => Container(height: 260,
                        color: AppColors.surfaceVariant,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined,
                                size: 48, color: AppColors.textHint),
                            SizedBox(height: 8),
                            Text('Screenshot unavailable',
                                style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.touch_app_outlined,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  const Text('Tap to view full screen',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Admin actions
            if (isAdmin && c.isSubmitted) ...[
              if (_actionLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.accent))
              else
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _approve,
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusApproved),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _reject,
                          icon: const Icon(Icons.cancel_rounded),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusRejected),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFullScreen(BuildContext context, String url) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: InteractiveViewer(
        child: Center(child: CachedNetworkImage(imageUrl: url)),
      ),
    )));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  const _InfoRow(this.icon, this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 10),
          SizedBox(width: 110,
              child: Text(label, style: TextStyle(color: c, fontSize: 13,
                  fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }
}
