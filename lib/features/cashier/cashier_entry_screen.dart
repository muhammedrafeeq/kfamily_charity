import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/profile.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/payment_contribution.dart';
import '../../shared/widgets/error_display.dart';

class CashierEntryScreen extends ConsumerStatefulWidget {
  const CashierEntryScreen({super.key});

  @override
  ConsumerState<CashierEntryScreen> createState() => _CashierEntryScreenState();
}

class _CashierEntryScreenState extends ConsumerState<CashierEntryScreen> {
  final Map<String, TextEditingController> _amountCtrls = {};
  final Set<String> _selected = {};
  bool _loading = false;
  bool _showPaid = false;
  String? _sameAmount;
  final _sameAmountCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in _amountCtrls.values) { c.dispose(); }
    _sameAmountCtrl.dispose();
    super.dispose();
  }

  void _toggleMember(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
        _amountCtrls.putIfAbsent(id, () => TextEditingController(text: _sameAmount ?? ''));
      }
    });
  }

  void _applySameAmount(String value) {
    setState(() {
      _sameAmount = value;
      for (final id in _selected) {
        _amountCtrls[id]?.text = value;
      }
    });
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      _snack('Select at least one member.', error: true);
      return;
    }
    for (final id in _selected) {
      final amt = double.tryParse(_amountCtrls[id]?.text.trim() ?? '');
      if (amt == null || amt <= 0) {
        _snack('Enter a valid amount for all selected members.', error: true);
        return;
      }
    }

    final cycle = await ref.read(currentCycleProvider.future);
    if (cycle == null) { _snack('No active payment cycle.', error: true); return; }

    setState(() => _loading = true);
    try {
      final service = ref.read(contributionServiceProvider);
      for (final id in _selected) {
        final amount = double.parse(_amountCtrls[id]!.text.trim());
        await service.cashierSubmitPayment(
          cycleId: cycle.id,
          memberId: id,
          amount: amount,
        );
      }
      ref.invalidate(contributionsForCycleProvider(cycle.id));
      ref.invalidate(myContributionProvider);
      ref.invalidate(totalCollectionsProvider);
      ref.invalidate(monthlyTrendsProvider);
      _snack('${_selected.length} payment(s) recorded!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
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
    final membersAsync = ref.watch(allMembersProvider);
    final cycleAsync = ref.watch(currentCycleProvider);
    final contributionsAsync = cycleAsync.when(
      data: (cycle) => cycle == null
          ? const AsyncValue.data(<PaymentContribution>[])
          : ref.watch(contributionsForCycleProvider(cycle.id)),
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    );

    final paidMemberIds = contributionsAsync.valueOrNull
            ?.where((c) => c.status == 'approved')
            .map((c) => c.memberId)
            .toSet() ?? {};

    return Scaffold(
      body: Column(
        children: [
          // Gradient header
          Container(
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // AppBar row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text('Quick Cash Entry',
                              style: TextStyle(color: Colors.white, fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                        ),
                        cycleAsync.when(
                          data: (cycle) => cycle == null
                              ? const SizedBox.shrink()
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.2),
                                    borderRadius:
                                        const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Text(cycle.displayName,
                                      style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Row(
                      children: [
                        _StatChip(
                          label: 'Selected',
                          value: '${_selected.length}',
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          label: 'Total',
                          value: _selected.isEmpty
                              ? '—'
                              : '${_selected.fold(0.0, (sum, id) {
                                  final v = double.tryParse(
                                      _amountCtrls[id]?.text.trim() ?? '');
                                  return sum + (v ?? 0);
                                }).toStringAsFixed(0)}',
                          color: AppColors.gold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Same amount bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sameAmountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Apply same amount to all selected',
                      prefixIcon: Icon(Icons.currency_rupee_rounded),
                      isDense: true,
                    ),
                    onChanged: _applySameAmount,
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () => _applySameAmount(_sameAmountCtrl.text),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // Show Paid Toggle Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text(
                  'Show already paid members',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Switch.adaptive(
                  value: _showPaid,
                  activeColor: AppColors.accent,
                  onChanged: (val) => setState(() => _showPaid = val),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: membersAsync.when(
              data: (members) {
                final filteredMembers = members.where((m) => _showPaid || !paidMemberIds.contains(m.id)).toList();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filteredMembers.length,
                  itemBuilder: (_, i) {
                    final member = filteredMembers[i];
                    final isPaid = paidMemberIds.contains(member.id);
                    return _MemberEntryTile(
                      member: member,
                      selected: _selected.contains(member.id),
                      isPaid: isPaid,
                      controller: _amountCtrls[member.id],
                      onToggle: () => _toggleMember(member.id),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => ErrorDisplay(message: e.toString()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _loading || _selected.isEmpty ? null : _submit,
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
                  : const Icon(Icons.check_circle_rounded),
              label: Text(
                _selected.isEmpty
                    ? 'Select members to record'
                    : 'Record ${_selected.length} Payment${_selected.length == 1 ? '' : 's'}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12)),
          const SizedBox(width: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    );
  }
}

class _MemberEntryTile extends StatelessWidget {
  final Profile member;
  final bool selected;
  final bool isPaid;
  final TextEditingController? controller;
  final VoidCallback onToggle;

  const _MemberEntryTile({
    required this.member,
    required this.selected,
    required this.isPaid,
    required this.controller,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected 
              ? AppColors.accent.withValues(alpha: 0.08) 
              : (isPaid ? AppColors.statusApproved.withValues(alpha: 0.02) : AppColors.surface),
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          border: Border.all(
            color: selected 
                ? AppColors.accent 
                : (isPaid ? AppColors.statusApproved.withValues(alpha: 0.15) : const Color(0xFFEEF1F7)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: selected ? AppColors.accentGradient : null,
                color: selected 
                    ? null 
                    : (isPaid ? AppColors.statusApproved.withValues(alpha: 0.1) : AppColors.surfaceVariant),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: Text('${member.memberNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: selected 
                          ? Colors.white 
                          : (isPaid ? AppColors.statusApproved : AppColors.textSecondary),
                    )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(member.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: selected ? AppColors.primary : AppColors.textPrimary,
                      )),
                  if (isPaid) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.statusApproved.withValues(alpha: 0.8),
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Approved Payment',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusApproved.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (selected && controller != null) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixText: '₹ ',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onTap: () {},
                ),
              ),
            ] else
              Icon(
                selected 
                    ? Icons.check_circle_rounded 
                    : (isPaid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded),
                color: selected 
                    ? AppColors.accent 
                    : (isPaid ? AppColors.statusApproved.withValues(alpha: 0.7) : AppColors.textHint),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
