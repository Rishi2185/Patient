import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/doctor.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/primary_button.dart';
import 'payment_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Doctor doctor;
  final DateTime date;
  final String slot;

  const PatientDetailsScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.slot,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedBloodGroup = 'O+';
  String _selectedType = 'opd';

  String? _nameError;
  String? _ageError;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null && _nameController.text.isEmpty) {
        _nameController.text = user.username;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();

    String? nameErr;
    if (name.isEmpty) {
      nameErr = 'Patient name is required';
    }

    String? ageErr;
    final age = int.tryParse(ageText);
    if (ageText.isEmpty) {
      ageErr = 'Age is required';
    } else if (age == null || age <= 0 || age > 120) {
      ageErr = 'Enter a valid age (1-120)';
    }

    setState(() {
      _nameError = nameErr;
      _ageError = ageErr;
    });

    if (nameErr != null || ageErr != null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          doctor: widget.doctor,
          date: widget.date,
          slot: widget.slot,
          patientName: name,
          patientAge: age!,
          patientBloodGroup: _selectedBloodGroup,
          patientType: _selectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          FadeIn(
            child: AppTextField(
              label: 'Patient Name',
              hint: 'Full name of the patient',
              controller: _nameController,
              prefixIcon: Icons.person_outline_rounded,
              errorText: _nameError,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
          ),
          const SizedBox(height: 18),
          FadeIn(
            delay: const Duration(milliseconds: 60),
            child: AppTextField(
              label: 'Patient Age',
              hint: 'Age in years',
              controller: _ageController,
              prefixIcon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              errorText: _ageError,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_ageError != null) setState(() => _ageError = null);
              },
            ),
          ),
          const SizedBox(height: 18),
          FadeIn(
            delay: const Duration(milliseconds: 120),
            child: _buildBloodGroupDropdown(),
          ),
          const SizedBox(height: 24),
          FadeIn(
            delay: const Duration(milliseconds: 180),
            child: _buildTypeSelection(),
          ),
        ],
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: PrimaryButton(
            label: 'Next',
            icon: Icons.arrow_forward_rounded,
            onPressed: _onNext,
          ),
        ),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blood Group',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBloodGroup,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary, size: 28),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              items: _bloodGroups.map((String bg) {
                return DropdownMenuItem<String>(
                  value: bg,
                  child: Text(bg),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _selectedBloodGroup = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appointment Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                type: 'opd',
                title: 'OPD',
                subtitle: 'Outpatient Department',
                icon: Icons.people_outline_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                type: 'ipd',
                title: 'IPD',
                subtitle: 'Inpatient Department',
                icon: Icons.hotel_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: AppTheme.fast,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softGreenTint : AppColors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected ? AppColors.softShadow : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
