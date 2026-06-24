import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/specialty.dart';
import '../../state/doctor_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/search_field.dart';
import '../../widgets/specialty_chip.dart';
import 'doctor_detail_screen.dart';
import 'filter_sheet.dart';

class DoctorListScreen extends StatefulWidget {
  final bool autofocusSearch;

  const DoctorListScreen({super.key, this.autofocusSearch = false});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late final TextEditingController _search =
      TextEditingController(text: context.read<DoctorProvider>().query);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.autofocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DoctorProvider>();
    final doctors = provider.doctors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find doctors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SearchField(
              controller: _search,
              filtersActive: provider.hasActiveFilters,
              onChanged: provider.setQuery,
              onFilterTap: () => showFilterSheet(context),
            ),
          ),
          // Specialty pills
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: Specialties.all.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return FilterPill(
                    label: 'All',
                    selected: provider.specialtyId == null,
                    onTap: () => provider.setSpecialty(null),
                  );
                }
                final s = Specialties.all[i - 1];
                return FilterPill(
                  label: s.name,
                  icon: s.icon,
                  selected: provider.specialtyId == s.id,
                  onTap: () => provider.setSpecialty(s.id),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Result count + sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${doctors.length} doctor${doctors.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => showFilterSheet(context),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        provider.sort.label,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: doctors.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No doctors found',
                    message:
                        'Try a different speciality or clear your filters to '
                        'see more results.',
                    action: TextButton.icon(
                      onPressed: () {
                        provider.clearFilters();
                        _search.clear();
                        provider.setQuery('');
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Clear filters'),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final d = doctors[i];
                      return FadeIn(
                        key: ValueKey(d.id),
                        delay: Duration(milliseconds: (i.clamp(0, 8)) * 40),
                        duration: AppTheme.fast,
                        child: DoctorCard(
                          doctor: d,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DoctorDetailScreen(doctor: d),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
