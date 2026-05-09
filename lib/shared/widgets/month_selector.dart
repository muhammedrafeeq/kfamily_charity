import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/payment_cycle.dart';

class MonthSelector extends StatelessWidget {
  final List<PaymentCycle> cycles;
  final String? selectedCycleId;
  final ValueChanged<String> onSelected;

  const MonthSelector({
    super.key,
    required this.cycles,
    required this.selectedCycleId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cycles.length,
        itemBuilder: (context, i) {
          final cycle = cycles[i];
          final isSelected = cycle.id == selectedCycleId;
          final label = DateFormat('MMM yy').format(DateTime(cycle.year, cycle.month));
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelected(cycle.id),
            ),
          );
        },
      ),
    );
  }
}
