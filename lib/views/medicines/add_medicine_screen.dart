import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddMedicineScreen extends StatefulWidget {
  // null = for main user, non-null = for family member
  final String? memberId;

  const AddMedicineScreen({super.key, this.memberId});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'Tablet';
  String _selectedFrequency = 'Once a day';
  String _selectedPriority = 'Medium';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  List<String> _reminderTimes = ['08:00 AM'];

  final List<String> _types = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Drops',
    'Other',
  ];

  final List<String> _frequencies = [
    'Once a day',
    'Twice a day',
    'Three times a day',
    'Every 6 hours',
    'Every 8 hours',
    'As needed',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _addReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final timeString = '$hour:$minute $period';
      setState(() {
        if (!_reminderTimes.contains(timeString)) {
          _reminderTimes.add(timeString);
        }
      });
    }
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';

    final success = await context.read<MedicineProvider>().addMedicine(
      userId: userId,
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      type: _selectedType,
      frequency: _selectedFrequency,
      startDate: _startDate,
      endDate: _endDate,
      reminderTimes: _reminderTimes,
      priority: _selectedPriority,
      notes: _notesController.text.trim(),
      memberId: widget.memberId, // ← pass for family member
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Came from family member — back to detail screen
      // Came from main user — to medicines list
      if (widget.memberId != null) {
        context.pop();
      } else {
        context.go(AppRoutes.medicines);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<MedicineProvider>().errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final medicines = context.watch<MedicineProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: r.pagePadding,
              child: Column(
                children: [
                  SizedBox(height: r.mediumSpace),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios),
                        padding: EdgeInsets.zero,
                      ),
                      SizedBox(width: r.wp(2)),
                      Text('Add Medicine', style: AppTextStyles.heading2),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: r.pagePadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: 'Medicine Name',
                        prefixIcon: Icons.medication_outlined,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Medicine name is required!';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: r.mediumSpace),
                      CustomTextField(
                        controller: _dosageController,
                        label: 'Dosage (e.g. 500mg)',
                        prefixIcon: Icons.science_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Dosage is required!';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: r.mediumSpace),
                      _buildLabel(r, 'Medicine Type'),
                      SizedBox(height: r.smallSpace),
                      _buildDropdown(
                        r,
                        value: _selectedType,
                        items: _types,
                        onChanged: (value) =>
                            setState(() => _selectedType = value!),
                      ),
                      SizedBox(height: r.mediumSpace),
                      _buildLabel(r, 'Frequency'),
                      SizedBox(height: r.smallSpace),
                      _buildDropdown(
                        r,
                        value: _selectedFrequency,
                        items: _frequencies,
                        onChanged: (value) =>
                            setState(() => _selectedFrequency = value!),
                      ),
                      SizedBox(height: r.mediumSpace),
                      _buildLabel(r, 'Priority'),
                      SizedBox(height: r.smallSpace),
                      Row(
                        children: _priorities.map((priority) {
                          final isSelected = _selectedPriority == priority;
                          return Padding(
                            padding: EdgeInsets.only(right: r.wp(2)),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPriority = priority),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: r.wp(4),
                                  vertical: r.hp(0.8),
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _priorityColor(priority)
                                      : Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(
                                    r.largeRadius,
                                  ),
                                  border: Border.all(
                                    color: _priorityColor(priority),
                                  ),
                                ),
                                child: Text(
                                  priority,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isSelected
                                        ? AppColors.textWhite
                                        : _priorityColor(priority),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: r.mediumSpace),
                      _buildLabel(r, 'Start Date'),
                      SizedBox(height: r.smallSpace),
                      _buildDatePicker(
                        r,
                        date: _startDate,
                        onTap: () => _pickDate(true),
                      ),
                      SizedBox(height: r.mediumSpace),
                      _buildLabel(r, 'End Date (Optional)'),
                      SizedBox(height: r.smallSpace),
                      _buildDatePicker(
                        r,
                        date: _endDate,
                        onTap: () => _pickDate(false),
                        hint: 'No end date',
                      ),
                      SizedBox(height: r.mediumSpace),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel(r, 'Reminder Times'),
                          TextButton.icon(
                            onPressed: _addReminderTime,
                            icon: Icon(
                              Icons.add,
                              size: r.smallIcon,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              'Add Time',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: r.smallSpace),
                      Wrap(
                        spacing: r.wp(2),
                        runSpacing: r.hp(0.5),
                        children: _reminderTimes.map((time) {
                          return Chip(
                            label: Text(time, style: AppTextStyles.bodySmall),
                            deleteIcon: Icon(Icons.close, size: r.wp(3)),
                            onDeleted: _reminderTimes.length > 1
                                ? () => setState(
                                    () => _reminderTimes.remove(time),
                                  )
                                : null,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: r.mediumSpace),
                      CustomTextField(
                        controller: _notesController,
                        label: 'Notes (Optional)',
                        prefixIcon: Icons.notes,
                        maxLines: 3,
                      ),
                      SizedBox(height: r.largeSpace),
                      CustomButton(
                        text: 'Save Medicine',
                        onPressed: _saveMedicine,
                        isLoading: medicines.isLoading,
                        icon: Icons.save,
                      ),
                      SizedBox(height: r.largeSpace),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(ResponsiveHelper r, String text) =>
      Text(text, style: AppTextStyles.label);

  Widget _buildDropdown(
    ResponsiveHelper r, {
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.wp(4)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(r.mediumRadius),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: AppTextStyles.bodyMedium),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    ResponsiveHelper r, {
    DateTime? date,
    required VoidCallback onTap,
    String? hint,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.wp(4), vertical: r.hp(2)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(r.mediumRadius),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              size: r.smallIcon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: r.wp(3)),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : (hint ?? 'Select date'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: date != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }
}
