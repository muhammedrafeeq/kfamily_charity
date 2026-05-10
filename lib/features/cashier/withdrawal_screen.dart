import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/double_extensions.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/withdrawal_provider.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/error_display.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  Profile? _selectedMember;
  bool _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _snack('Enter a valid amount.', error: true); return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      _snack('Please provide a reason.', error: true); return;
    }
    if (_selectedMember == null) {
      _snack('Please select a member.', error: true); return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(withdrawalServiceProvider).addWithdrawal(
        amount: amount,
        reason: _reasonCtrl.text.trim(),
        userId: _selectedMember!.id,
      );
      ref.invalidate(withdrawalsProvider);
      ref.invalidate(totalWithdrawnProvider);
      _amountCtrl.clear();
      _reasonCtrl.clear();
      setState(() => _selectedMember = null);
      _snack('Withdrawal recorded.');
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _clearHistory() async {
    final ok = await showConfirmationDialog(
      context,
      title: 'Clear History?',
      message: 'This will permanently delete all withdrawal records and reset the total withdrawn amount to zero. This cannot be undone.',
      confirmLabel: 'Clear All',
      isDestructive: true,
    );
    if (ok == true) {
      setState(() => _loading = true);
      try {
        await ref.read(withdrawalServiceProvider).clearAllWithdrawals();
        ref.invalidate(withdrawalsProvider);
        ref.invalidate(totalWithdrawnProvider);
        _snack('Withdrawal history cleared.');
      } catch (e) {
        _snack(e.toString(), error: true);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.statusRejected : AppColors.statusApproved,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalsAsync = ref.watch(withdrawalsProvider);
    final totalAsync = ref.watch(totalWithdrawnProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient header with total
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(l10n.withdrawn,
                style: const TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w700)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A0000), Color(0xFF8B1A1A), Color(0xFF7B2D00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40), // Push down to avoid pinned title
                    const Text('Total Withdrawn',
                        style: TextStyle(color: Colors.white54, fontSize: 12,
                            fontWeight: FontWeight.w500, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    totalAsync.when(
                      data: (total) => Text(total.toCurrency(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 32,
                              fontWeight: FontWeight.w800)),
                      loading: () => const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Entry form
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.recordWithdrawal,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: l10n.withdrawalAmount,
                      prefixIcon: const Icon(Icons.currency_rupee_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ref.watch(allMembersProvider).when(
                    data: (members) => DropdownButtonFormField<Profile>(
                      value: _selectedMember,
                      decoration: InputDecoration(
                        labelText: l10n.selectMember,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                      items: members.map((m) => DropdownMenuItem(
                        value: m,
                        child: Text('${m.fullName} (${m.memberNumber})'),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedMember = v),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error loading members: $e', 
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _reasonCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: l10n.reason,
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusRejected,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14))),
                      ),
                      icon: _loading
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.remove_circle_rounded),
                      label: Text(_loading ? 'Recording…' : 'Record Withdrawal',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.withdrawalHistory,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                          color: AppColors.textSecondary, letterSpacing: 1)),
                  if (withdrawalsAsync.valueOrNull?.isNotEmpty == true &&
                      ref.watch(currentProfileProvider).valueOrNull?.memberNumber == 0)
                    TextButton.icon(
                      onPressed: _loading ? null : _clearHistory,
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                      label: const Text('Clear History', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.statusRejected,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // History list
          withdrawalsAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('No withdrawals yet.',
                          style: TextStyle(color: AppColors.textHint, fontSize: 14)),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final w = list[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppColors.statusRejected.withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                              ),
                              child: const Icon(Icons.arrow_upward_rounded,
                                  color: AppColors.statusRejected, size: 18),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(w.reason,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${w.withdrawnByProfile?.fullName ?? 'Unknown'} • ${DateFormat('dd MMM yyyy').format(w.createdAt.toLocal())}',
                                    style: const TextStyle(
                                        color: AppColors.textHint, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Text(w.amount.toCurrency(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.statusRejected,
                                    fontSize: 15)),
                          ],
                        ),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.accent),
              )),
            ),
            error: (e, _) =>
                SliverToBoxAdapter(child: ErrorDisplay(message: e.toString())),
          ),
        ],
      ),
    );
  }
}
