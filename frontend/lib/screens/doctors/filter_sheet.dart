import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/doctor_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<DoctorProvider>(),
      child: const _FilterSheet(),
    ),
  );
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DoctorProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter & sort',
                  style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: provider.clearFilters,
                child: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _SectionLabel('Sort by'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: DoctorSort.values.map((s) {
              final selected = provider.sort == s;
              return _ChoiceChip(
                label: s.label,
                selected: selected,
                onTap: () => provider.setSort(s),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          const _SectionLabel('Minimum rating'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [0.0, 4.0, 4.5, 4.8].map((r) {
              final selected = provider.minRating == r;
              return _ChoiceChip(
                label: r == 0 ? 'Any' : '$r+ ★',
                selected: selected,
                onTap: () => provider.setMinRating(r),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.softGreenTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_available_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Available today only',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: provider.availableTodayOnly,
                  activeThumbColor: AppColors.primary,
                  onChanged: provider.setAvailableTodayOnly,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Show ${provider.doctors.length} results',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.mint,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
