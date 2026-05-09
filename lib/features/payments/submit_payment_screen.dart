import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';

class SubmitPaymentScreen extends ConsumerStatefulWidget {
  const SubmitPaymentScreen({super.key});

  @override
  ConsumerState<SubmitPaymentScreen> createState() => _SubmitPaymentScreenState();
}

class _SubmitPaymentScreenState extends ConsumerState<SubmitPaymentScreen> {
  final _amountCtrl = TextEditingController();
  XFile? _image;
  Uint8List? _imageBytes;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1200);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() { _image = picked; _imageBytes = bytes; });
    }
  }

  void _showImageSourceSheet() {
    final l10n = ref.read(l10nProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: const BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.accent),
              ),
              title: Text(l10n.takePhoto,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.statusSubmitted.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.statusSubmitted),
              ),
              title: Text(l10n.chooseFromGallery,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount.');
      return;
    }
    if (_image == null) {
      _showError('Please attach a payment screenshot.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      final cycle = await ref.read(currentCycleProvider.future);
      final profile = await ref.read(currentProfileProvider.future);

      if (cycle == null) { _showError('No active payment cycle.'); return; }
      if (profile == null) { _showError('Profile not loaded. Sign out and back in.'); return; }

      await ref.read(contributionServiceProvider).submitPayment(
        cycleId: cycle.id,
        memberId: profile.id,
        amount: amount,
        screenshotFile: _image!,
        year: cycle.year,
        month: cycle.month,
      );
      ref.invalidate(myContributionProvider);
      ref.invalidate(contributionsForCycleProvider(cycle.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment submitted!'),
              backgroundColor: AppColors.statusApproved),
        );
        Navigator.pop(context);
      }
    } catch (e, st) {
      debugPrint('SUBMIT ERROR: $e\n$st');
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    setState(() => _error = msg);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg),
            backgroundColor: AppColors.statusRejected,
            duration: const Duration(seconds: 6)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final myContribAsync = ref.watch(myContributionProvider);
    final isApproved = myContribAsync.valueOrNull?.status == 'approved';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 24),
                      Icon(Icons.cloud_upload_rounded, color: AppColors.accent, size: 32),
                      SizedBox(height: 8),
                      Text(l10n.submitPayment,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              title: Text(l10n.submitPayment,
                  style: const TextStyle(color: Colors.white, fontSize: 17,
                      fontWeight: FontWeight.w600)),
              titlePadding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Error banner
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.statusRejected.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      border: Border.all(
                          color: AppColors.statusRejected.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.statusRejected, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: AppColors.statusRejected, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                // Payment window info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.all(Radius.circular(14)),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: const Icon(Icons.info_outline_rounded,
                            color: AppColors.accent, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(l10n.paymentWindow,
                            style: const TextStyle(color: AppColors.accent,
                                fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                if (isApproved)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.statusApproved.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      border: Border.all(color: AppColors.statusApproved.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.statusApproved, size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('You have already paid for this month.',
                              style: TextStyle(color: AppColors.statusApproved,
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Amount field
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.paymentAmount,
                          style: const TextStyle(fontWeight: FontWeight.w700,
                              fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          prefixText: '₹ ',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Screenshot section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.paymentScreenshot,
                          style: const TextStyle(fontWeight: FontWeight.w700,
                              fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 200,
                          decoration: BoxDecoration(
                            color: _imageBytes != null
                                ? Colors.transparent
                                : AppColors.surfaceVariant,
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            border: Border.all(
                              color: _imageBytes != null
                                  ? AppColors.accent.withValues(alpha: 0.4)
                                  : AppColors.textHint.withValues(alpha: 0.3),
                              width: _imageBytes != null ? 2 : 1,
                            ),
                          ),
                          child: _imageBytes != null
                              ? ClipRRect(
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(16)),
                                  child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.add_photo_alternate_rounded,
                                          size: 32, color: AppColors.accent),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(l10n.tapToAddScreenshot,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.accent, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(l10n.cameraOrGallery,
                                        style: const TextStyle(
                                            color: AppColors.textHint, fontSize: 12)),
                                  ],
                                ),
                        ),
                      ),
                      if (_image != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _showImageSourceSheet,
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: Text(l10n.changePhoto),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: (_loading || isApproved) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primary,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                    icon: _loading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary))
                        : const Icon(Icons.cloud_upload_rounded),
                    label: Text(_loading ? l10n.submitting : l10n.submitPayment,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
