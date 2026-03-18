import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/doctor_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../widgets/common/custom_card.dart';
import 'package:provider/provider.dart';

class DoctorDetailScreen extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  String _formatDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final suf = h >= 12 ? 'PM' : 'AM';
    final disp = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$disp:$min $suf';
  }

  String _getCountdown(DateTime appt) {
    final diff = appt.difference(DateTime.now());
    if (diff.isNegative) {
      final past = DateTime.now().difference(appt);
      if (past.inDays == 0) return 'Today (past)';
      if (past.inDays == 1) return 'Yesterday';
      return '${past.inDays} days ago';
    }
    final n = DateTime.now();
    final isToday =
        appt.year == n.year && appt.month == n.month && appt.day == n.day;
    final isTomorrow =
        appt.year == n.add(const Duration(days: 1)).year &&
        appt.month == n.add(const Duration(days: 1)).month &&
        appt.day == n.add(const Duration(days: 1)).day;
    if (isToday) {
      if (diff.inHours < 1) return 'In ${diff.inMinutes} minutes';
      return 'Today in ${diff.inHours} hours';
    }
    if (isTomorrow) return 'Tomorrow';
    if (diff.inDays < 7) return 'In ${diff.inDays} days';
    if (diff.inDays < 30) return 'In ${(diff.inDays / 7).round()} weeks';
    return 'In ${(diff.inDays / 30).round()} months';
  }

  Color _countdownColor(DateTime appt) {
    final diff = appt.difference(DateTime.now());
    if (diff.isNegative) return AppColors.error;
    final n = DateTime.now();
    final isToday =
        appt.year == n.year && appt.month == n.month && appt.day == n.day;
    final isTomorrow =
        appt.year == n.add(const Duration(days: 1)).year &&
        appt.month == n.add(const Duration(days: 1)).month &&
        appt.day == n.add(const Duration(days: 1)).day;
    if (isToday) return AppColors.error;
    if (isTomorrow) return AppColors.warning;
    return AppColors.primary;
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _markDone(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Appointment Complete?', style: AppTextStyles.heading3),
        content: Text(
          'Dr. ${doctor.doctorName} ke saath appointment complete mark karna hai?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Yes, Done',
              style: TextStyle(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
      await context.read<DoctorProvider>().markAppointmentDone(uid, doctor.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteDoctor(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancel Appointment?', style: AppTextStyles.heading3),
        content: Text(
          'Dr. ${doctor.doctorName} ka appointment cancel karna hai?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
      await context.read<DoctorProvider>().deleteDoctor(uid, doctor.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final countdown = _getCountdown(doctor.appointmentDate);
    final countdownColor = _countdownColor(doctor.appointmentDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Detail', style: AppTextStyles.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.mediumSpace),

              // ── Doctor Avatar + Name Hero ──
              CustomCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Big Avatar
                        Container(
                          width: r.wp(18),
                          height: r.wp(18),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              doctor.doctorName.isNotEmpty
                                  ? doctor.doctorName[0].toUpperCase()
                                  : 'D',
                              style: AppTextStyles.heading1.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: r.wp(4)),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. ${doctor.doctorName}',
                                style: AppTextStyles.heading2,
                              ),
                              SizedBox(height: r.hp(0.4)),
                              Row(
                                children: [
                                  Icon(
                                    Icons.medical_services_outlined,
                                    size: r.wp(4),
                                    color: AppColors.secondary,
                                  ),
                                  SizedBox(width: r.wp(1.5)),
                                  Expanded(
                                    child: Text(
                                      doctor.speciality,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: r.hp(0.4)),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_hospital_outlined,
                                    size: r.wp(4),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  SizedBox(width: r.wp(1.5)),
                                  Expanded(
                                    child: Text(
                                      doctor.clinicName,
                                      style: AppTextStyles.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: r.mediumSpace),

                    // Status badge
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: r.hp(1)),
                      decoration: BoxDecoration(
                        color: doctor.isUpcoming
                            ? countdownColor.withOpacity(0.1)
                            : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(r.smallRadius),
                        border: Border.all(
                          color: doctor.isUpcoming
                              ? countdownColor.withOpacity(0.3)
                              : AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            doctor.isUpcoming
                                ? Icons.schedule_outlined
                                : Icons.check_circle_outline,
                            size: r.wp(4),
                            color: doctor.isUpcoming
                                ? countdownColor
                                : AppColors.success,
                          ),
                          SizedBox(width: r.wp(2)),
                          Text(
                            doctor.isUpcoming ? countdown : 'Completed',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: doctor.isUpcoming
                                  ? countdownColor
                                  : AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: r.mediumSpace),

              // ── Appointment Date & Time ──
              Text('Appointment Info', style: AppTextStyles.heading3),
              SizedBox(height: r.smallSpace),

              CustomCard(
                child: Column(
                  children: [
                    _detailRow(
                      r,
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: _formatDate(doctor.appointmentDate),
                      color: AppColors.primary,
                    ),
                    const Divider(height: 1),
                    _detailRow(
                      r,
                      context,
                      icon: Icons.access_time_outlined,
                      label: 'Time',
                      value: _formatTime(doctor.appointmentDate),
                      color: AppColors.secondary,
                    ),
                    if (doctor.address != null &&
                        doctor.address!.isNotEmpty) ...[
                      const Divider(height: 1),
                      _detailRow(
                        r,
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: doctor.address!,
                        color: AppColors.warning,
                      ),
                    ],
                    if (doctor.phone != null && doctor.phone!.isNotEmpty) ...[
                      const Divider(height: 1),
                      _detailRow(
                        r,
                        context,
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: doctor.phone!,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),

              // ── Notes ──
              if (doctor.notes != null && doctor.notes!.isNotEmpty) ...[
                SizedBox(height: r.mediumSpace),
                Text('Notes', style: AppTextStyles.heading3),
                SizedBox(height: r.smallSpace),
                CustomCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes_outlined,
                        color: AppColors.info,
                        size: r.smallIcon,
                      ),
                      SizedBox(width: r.wp(3)),
                      Expanded(
                        child: Text(
                          doctor.notes!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: r.largeSpace),

              // ── Action Buttons ──
              if (doctor.isUpcoming) ...[
                // Call button
                if (doctor.phone != null && doctor.phone!.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    height: r.hp(6.5),
                    child: ElevatedButton.icon(
                      onPressed: () => _call(doctor.phone!),
                      icon: const Icon(
                        Icons.call_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Call Dr. ${doctor.doctorName}',
                        style: AppTextStyles.button,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.mediumRadius),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: r.mediumSpace),
                ],

                // Mark complete
                SizedBox(
                  width: double.infinity,
                  height: r.hp(6.5),
                  child: ElevatedButton.icon(
                    onPressed: () => _markDone(context),
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Mark as Completed',
                      style: AppTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: r.mediumSpace),

                // Cancel appointment
                SizedBox(
                  width: double.infinity,
                  height: r.hp(6.5),
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteDoctor(context),
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    label: Text(
                      'Cancel Appointment',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Past appointment — only delete
                SizedBox(
                  width: double.infinity,
                  height: r.hp(6.5),
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteDoctor(context),
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    label: Text(
                      'Remove from History',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: r.largeSpace),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    ResponsiveHelper r,
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.hp(1.2)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.wp(2)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.smallRadius),
            ),
            child: Icon(icon, color: color, size: r.smallIcon),
          ),
          SizedBox(width: r.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
