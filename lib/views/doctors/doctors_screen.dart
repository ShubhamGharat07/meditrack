// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:meditrack/core/constants/app_text_style.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/responsive_helper.dart';
// import '../../models/doctor_model.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/doctor_provider.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/common/custom_button.dart';
// import '../../widgets/common/custom_card.dart';
// import '../../widgets/common/custom_text_field.dart';
// import '../../widgets/common/empty_state.dart';
// import '../../widgets/common/loading_indicator.dart';
// import '../../services/notification/notification_service.dart';

// class DoctorsScreen extends StatefulWidget {
//   const DoctorsScreen({super.key});

//   @override
//   State<DoctorsScreen> createState() => _DoctorsScreenState();
// }

// class _DoctorsScreenState extends State<DoctorsScreen> {
//   // ── Form controllers ──
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _specialityCtrl = TextEditingController();
//   final _clinicCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _addressCtrl = TextEditingController();
//   final _notesCtrl = TextEditingController();
//   final _dateCtrl = TextEditingController();
//   final _timeCtrl = TextEditingController();

//   // ── Reminder controllers (separate from appointment date/time) ──
//   final _reminderDateCtrl = TextEditingController();
//   final _reminderTimeCtrl = TextEditingController();

//   DateTime? _appointmentDate;
//   TimeOfDay? _appointmentTime;
//   DateTime? _reminderDate;
//   TimeOfDay? _reminderTime;

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(_loadDoctors);
//   }

//   Future<void> _loadDoctors() async {
//     final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
//     if (uid.isEmpty) return;
//     await context.read<DoctorProvider>().getDoctors(uid);
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _specialityCtrl.dispose();
//     _clinicCtrl.dispose();
//     _phoneCtrl.dispose();
//     _addressCtrl.dispose();
//     _notesCtrl.dispose();
//     _dateCtrl.dispose();
//     _timeCtrl.dispose();
//     _reminderDateCtrl.dispose();
//     _reminderTimeCtrl.dispose();
//     super.dispose();
//   }

//   // ── Date/Time pickers ──
//   Future<void> _pickDate({
//     required TextEditingController ctrl,
//     required void Function(DateTime) onPicked,
//     DateTime? initial,
//     bool futureOnly = true,
//   }) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial ?? DateTime.now(),
//       firstDate: futureOnly
//           ? DateTime.now().subtract(const Duration(days: 1))
//           : DateTime(2020),
//       lastDate: DateTime(2035),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: Theme.of(
//             ctx,
//           ).colorScheme.copyWith(primary: AppColors.primary),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) onPicked(picked);
//   }

//   Future<void> _pickTime({
//     required TextEditingController ctrl,
//     required void Function(TimeOfDay) onPicked,
//     TimeOfDay? initial,
//   }) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: initial ?? TimeOfDay.now(),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: Theme.of(
//             ctx,
//           ).colorScheme.copyWith(primary: AppColors.primary),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) onPicked(picked);
//   }

//   // ── Build full appointment DateTime ──
//   DateTime _buildDateTime(DateTime date, TimeOfDay time) =>
//       DateTime(date.year, date.month, date.day, time.hour, time.minute);

//   // ── Open form sheet ──
//   void _showAddSheet() {
//     _clearForm();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (_) => StatefulBuilder(
//         builder: (ctx, setSheetState) => _buildSheet(ctx, setSheetState),
//       ),
//     );
//   }

//   // ── Save appointment ──
//   Future<void> _saveDoctor(StateSetter setSheetState) async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_appointmentDate == null) {
//       _snack('Please select appointment date!', isError: true);
//       return;
//     }
//     if (_appointmentTime == null) {
//       _snack('Please select appointment time!', isError: true);
//       return;
//     }

//     final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
//     final apptDateTime = _buildDateTime(_appointmentDate!, _appointmentTime!);

//     final ok = await context.read<DoctorProvider>().addDoctor(
//       userId: uid,
//       doctorName: _nameCtrl.text.trim(),
//       speciality: _specialityCtrl.text.trim(),
//       clinicName: _clinicCtrl.text.trim(),
//       phone: _phoneCtrl.text.trim(),
//       address: _addressCtrl.text.trim(),
//       appointmentDate: apptDateTime,
//       notes: _notesCtrl.text.trim(),
//     );

//     if (!mounted) return;

//     if (ok) {
//       // Schedule custom reminder if user set one
//       if (_reminderDate != null && _reminderTime != null) {
//         final reminderDateTime = _buildDateTime(_reminderDate!, _reminderTime!);
//         await _scheduleCustomReminder(
//           doctorName: _nameCtrl.text.trim(),
//           clinicName: _clinicCtrl.text.trim(),
//           apptDateTime: apptDateTime,
//           reminderDateTime: reminderDateTime,
//         );
//       }
//       Navigator.pop(context);
//       _clearForm();
//       _snack(
//         'Appointment booked!${(_reminderDate != null) ? ' Reminder set ✅' : ''}',
//       );
//     } else {
//       _snack(context.read<DoctorProvider>().errorMessage, isError: true);
//     }
//   }

//   // ── Schedule a custom one-shot reminder ──
//   Future<void> _scheduleCustomReminder({
//     required String doctorName,
//     required String clinicName,
//     required DateTime apptDateTime,
//     required DateTime reminderDateTime,
//   }) async {
//     if (reminderDateTime.isBefore(DateTime.now())) {
//       _snack('Reminder time is in the past — skipped', isError: false);
//       return;
//     }
//     final notifId =
//         reminderDateTime.millisecondsSinceEpoch ~/ 1000 % 2000000000;
//     try {
//       await NotificationService().scheduleCustomReminder(
//         id: notifId,
//         title: '🏥 Appointment Reminder',
//         body: 'Dr. $doctorName at $clinicName — ${_formatTime(apptDateTime)}',
//         scheduledDateTime: reminderDateTime,
//       );
//       debugPrint('Custom reminder set for $reminderDateTime');
//     } catch (e) {
//       debugPrint('Custom reminder failed: $e');
//     }
//   }

//   // ── Mark appointment as done (delete) ──
//   Future<void> _markDone(DoctorModel doctor) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Appointment Complete?'),
//         content: Text(
//           'Mark appointment with Dr. ${doctor.doctorName} as completed?\n\n'
//           'This will remove it from your list.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: Text(
//               'Yes, Done',
//               style: TextStyle(color: AppColors.success),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true && mounted) {
//       final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
//       await context.read<DoctorProvider>().markAppointmentDone(
//         uid,
//         doctor.id ?? '',
//       );
//     }
//   }

//   // ── Delete appointment ──
//   Future<void> _deleteDoctor(DoctorModel doctor) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Cancel Appointment?'),
//         content: Text(
//           'Cancel appointment with Dr. ${doctor.doctorName}? This cannot be undone.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Keep'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: Text(
//               'Cancel Appointment',
//               style: TextStyle(color: AppColors.error),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true && mounted) {
//       final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
//       await context.read<DoctorProvider>().deleteDoctor(uid, doctor.id ?? '');
//     }
//   }

//   void _clearForm() {
//     _nameCtrl.clear();
//     _specialityCtrl.clear();
//     _clinicCtrl.clear();
//     _phoneCtrl.clear();
//     _addressCtrl.clear();
//     _notesCtrl.clear();
//     _dateCtrl.clear();
//     _timeCtrl.clear();
//     _reminderDateCtrl.clear();
//     _reminderTimeCtrl.clear();
//     setState(() {
//       _appointmentDate = null;
//       _appointmentTime = null;
//       _reminderDate = null;
//       _reminderTime = null;
//     });
//   }

//   void _snack(String msg, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? AppColors.error : AppColors.success,
//       ),
//     );
//   }

//   Future<void> _call(String phone) async {
//     final uri = Uri.parse('tel:$phone');
//     if (await canLaunchUrl(uri)) await launchUrl(uri);
//   }

//   // ─────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);
//     final dp = context.watch<DoctorProvider>();

//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(r, dp),
//             Expanded(
//               child: dp.isLoading
//                   ? const LoadingIndicator()
//                   : RefreshIndicator(
//                       onRefresh: _loadDoctors,
//                       child: SingleChildScrollView(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         padding: r.pagePadding,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: r.mediumSpace),
//                             if (dp.upcomingDoctors.isNotEmpty)
//                               _buildStatsBar(r, dp),
//                             SizedBox(height: r.mediumSpace),
//                             dp.upcomingDoctors.isEmpty
//                                 ? EmptyState(
//                                     message:
//                                         'No upcoming appointments!\nBook your next visit.',
//                                     icon: Icons.event_available_outlined,
//                                     buttonText: 'Book Appointment',
//                                     onButtonTap: _showAddSheet,
//                                   )
//                                 : Column(
//                                     children: dp.upcomingDoctors
//                                         .map(
//                                           (d) => Padding(
//                                             padding: EdgeInsets.only(
//                                               bottom: r.mediumSpace,
//                                             ),
//                                             child: _buildCard(r, d),
//                                           ),
//                                         )
//                                         .toList(),
//                                   ),
//                             SizedBox(height: r.largeSpace),
//                           ],
//                         ),
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showAddSheet,
//         backgroundColor: AppColors.primary,
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: Text(
//           'Book Appointment',
//           style: AppTextStyles.button.copyWith(fontSize: 13),
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────
//   // HEADER — fixed overflow with Expanded
//   // ─────────────────────────────────────

//   Widget _buildHeader(ResponsiveHelper r, DoctorProvider dp) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         r.wp(2),
//         r.smallSpace,
//         r.wp(4),
//         r.smallSpace,
//       ),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () => context.go(AppRoutes.dashboard),
//             icon: const Icon(Icons.arrow_back_ios),
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           SizedBox(width: r.wp(2)),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Doctors & Appointments',
//                   style: AppTextStyles.heading3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   '${dp.upcomingDoctors.length} upcoming',
//                   style: AppTextStyles.bodySmall,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── STATS BAR ──
//   Widget _buildStatsBar(ResponsiveHelper r, DoctorProvider dp) {
//     final todayCount = dp.upcomingDoctors
//         .where((d) => _isToday(d.appointmentDate))
//         .length;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: r.wp(4), vertical: r.hp(1.5)),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.06),
//         borderRadius: BorderRadius.circular(r.mediumRadius),
//         border: Border.all(color: AppColors.primary.withOpacity(0.15)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _statItem(
//             r,
//             '${dp.upcomingDoctors.length}',
//             'Upcoming',
//             AppColors.primary,
//           ),
//           Container(
//             width: 1,
//             height: 32,
//             color: AppColors.primary.withOpacity(0.2),
//           ),
//           _statItem(r, '$todayCount', 'Today', AppColors.warning),
//           Container(
//             width: 1,
//             height: 32,
//             color: AppColors.primary.withOpacity(0.2),
//           ),
//           _statItem(
//             r,
//             dp.upcomingDoctors
//                 .where((d) => _isTomorrow(d.appointmentDate))
//                 .length
//                 .toString(),
//             'Tomorrow',
//             AppColors.secondary,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statItem(
//     ResponsiveHelper r,
//     String value,
//     String label,
//     Color color,
//   ) {
//     return Column(
//       children: [
//         Text(value, style: AppTextStyles.heading3.copyWith(color: color)),
//         Text(label, style: AppTextStyles.bodySmall),
//       ],
//     );
//   }

//   // ─────────────────────────────────────
//   // APPOINTMENT CARD
//   // ─────────────────────────────────────

//   Widget _buildCard(ResponsiveHelper r, DoctorModel doctor) {
//     final countdown = _getCountdown(doctor.appointmentDate);
//     final isToday = _isToday(doctor.appointmentDate);
//     final isTomorrow = _isTomorrow(doctor.appointmentDate);
//     final badgeColor = isToday
//         ? AppColors.error
//         : isTomorrow
//         ? AppColors.warning
//         : AppColors.primary;

//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Top row ──
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Avatar circle
//               Container(
//                 width: r.wp(12),
//                 height: r.wp(12),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: AppColors.primary.withOpacity(0.3),
//                     width: 1.5,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     doctor.doctorName.isNotEmpty
//                         ? doctor.doctorName[0].toUpperCase()
//                         : 'D',
//                     style: AppTextStyles.heading3.copyWith(
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(width: r.wp(3)),

//               // Name + speciality + clinic
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Dr. ${doctor.doctorName}',
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     SizedBox(height: r.hp(0.3)),
//                     _iconRow(
//                       r,
//                       Icons.medical_services_outlined,
//                       doctor.speciality,
//                     ),
//                     SizedBox(height: r.hp(0.2)),
//                     _iconRow(
//                       r,
//                       Icons.local_hospital_outlined,
//                       doctor.clinicName,
//                     ),
//                   ],
//                 ),
//               ),

//               // Countdown badge
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: r.wp(2.5),
//                   vertical: r.hp(0.5),
//                 ),
//                 decoration: BoxDecoration(
//                   color: badgeColor.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(r.largeRadius),
//                   border: Border.all(color: badgeColor.withOpacity(0.4)),
//                 ),
//                 child: Text(
//                   countdown,
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: badgeColor,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 11,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           SizedBox(height: r.mediumSpace),
//           Divider(height: 1, color: const Color(0xFF9E9EAA).withOpacity(0.2)),
//           SizedBox(height: r.smallSpace),

//           // ── Date + Time chips ──
//           Row(
//             children: [
//               _chip(
//                 r,
//                 Icons.calendar_today_outlined,
//                 _formatDate(doctor.appointmentDate),
//                 AppColors.primary,
//               ),
//               SizedBox(width: r.wp(2)),
//               _chip(
//                 r,
//                 Icons.access_time_outlined,
//                 _formatTime(doctor.appointmentDate),
//                 AppColors.secondary,
//               ),
//             ],
//           ),

//           // ── Notes ──
//           if (doctor.notes != null && doctor.notes!.isNotEmpty) ...[
//             SizedBox(height: r.smallSpace),
//             Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: r.wp(3),
//                 vertical: r.hp(0.8),
//               ),
//               decoration: BoxDecoration(
//                 color: AppColors.info.withOpacity(0.06),
//                 borderRadius: BorderRadius.circular(r.smallRadius),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.notes_outlined,
//                     size: r.wp(3.5),
//                     color: AppColors.info,
//                   ),
//                   SizedBox(width: r.wp(2)),
//                   Expanded(
//                     child: Text(
//                       doctor.notes!,
//                       style: AppTextStyles.bodySmall,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],

//           SizedBox(height: r.smallSpace),

//           // ── Action buttons ──
//           Row(
//             children: [
//               // Call — only if phone exists
//               if (doctor.phone != null && doctor.phone!.isNotEmpty) ...[
//                 Expanded(
//                   child: _actionBtn(
//                     r,
//                     icon: Icons.call_outlined,
//                     label: 'Call',
//                     color: AppColors.success,
//                     onTap: () => _call(doctor.phone!),
//                   ),
//                 ),
//                 SizedBox(width: r.wp(2)),
//               ],

//               // Completed
//               Expanded(
//                 child: _actionBtn(
//                   r,
//                   icon: Icons.check_circle_outline,
//                   label: 'Completed',
//                   color: AppColors.primary,
//                   onTap: () => _markDone(doctor),
//                 ),
//               ),

//               SizedBox(width: r.wp(2)),

//               // Cancel appointment
//               Expanded(
//                 child: _actionBtn(
//                   r,
//                   icon: Icons.delete_outline,
//                   label: 'Cancel',
//                   color: AppColors.error,
//                   onTap: () => _deleteDoctor(doctor),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _iconRow(ResponsiveHelper r, IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: r.wp(3.5), color: const Color(0xFF9E9EAA)),
//         SizedBox(width: r.wp(1)),
//         Expanded(
//           child: Text(
//             text,
//             style: AppTextStyles.bodySmall,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _chip(ResponsiveHelper r, IconData icon, String label, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: r.wp(2.5), vertical: r.hp(0.6)),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(r.smallRadius),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: r.wp(3.5), color: color),
//           SizedBox(width: r.wp(1.5)),
//           Text(
//             label,
//             style: AppTextStyles.bodySmall.copyWith(
//               color: color,
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _actionBtn(
//     ResponsiveHelper r, {
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: r.hp(1.2)),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(r.smallRadius),
//           border: Border.all(color: color.withOpacity(0.25)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: r.wp(4), color: color),
//             SizedBox(width: r.wp(1.5)),
//             Text(
//               label,
//               style: AppTextStyles.bodySmall.copyWith(
//                 color: color,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────
//   // BOTTOM SHEET
//   // ─────────────────────────────────────

//   Widget _buildSheet(BuildContext ctx, StateSetter setSheetState) {
//     final r = ResponsiveHelper(ctx);
//     final dp = context.watch<DoctorProvider>();

//     return Padding(
//       padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
//       child: SingleChildScrollView(
//         padding: r.pagePadding,
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: r.mediumSpace),

//               // Handle bar
//               Center(
//                 child: Container(
//                   width: r.wp(10),
//                   height: r.hp(0.5),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF9E9EAA).withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(r.smallRadius),
//                   ),
//                 ),
//               ),
//               SizedBox(height: r.mediumSpace),

//               Text('Book Appointment', style: AppTextStyles.heading2),
//               SizedBox(height: r.largeSpace),

//               // ── Doctor Details ──
//               _sectionLabel(r, 'Doctor Details'),
//               SizedBox(height: r.smallSpace),

//               CustomTextField(
//                 controller: _nameCtrl,
//                 label: 'Doctor Name *',
//                 prefixIcon: Icons.person_outlined,
//                 textCapitalization: TextCapitalization.words,
//                 validator: (v) =>
//                     (v == null || v.isEmpty) ? 'Name is required!' : null,
//               ),
//               SizedBox(height: r.mediumSpace),

//               CustomTextField(
//                 controller: _specialityCtrl,
//                 label: 'Speciality *',
//                 prefixIcon: Icons.medical_services_outlined,
//                 textCapitalization: TextCapitalization.words,
//                 validator: (v) =>
//                     (v == null || v.isEmpty) ? 'Speciality is required!' : null,
//               ),
//               SizedBox(height: r.mediumSpace),

//               CustomTextField(
//                 controller: _clinicCtrl,
//                 label: 'Clinic / Hospital *',
//                 prefixIcon: Icons.local_hospital_outlined,
//                 textCapitalization: TextCapitalization.words,
//                 validator: (v) => (v == null || v.isEmpty)
//                     ? 'Clinic name is required!'
//                     : null,
//               ),
//               SizedBox(height: r.mediumSpace),

//               CustomTextField(
//                 controller: _phoneCtrl,
//                 label: 'Phone (Optional)',
//                 prefixIcon: Icons.phone_outlined,
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: r.mediumSpace),

//               CustomTextField(
//                 controller: _addressCtrl,
//                 label: 'Address (Optional)',
//                 prefixIcon: Icons.location_on_outlined,
//                 maxLines: 2,
//               ),

//               SizedBox(height: r.largeSpace),

//               // ── Appointment Date & Time ──
//               _sectionLabel(r, 'Appointment Date & Time'),
//               SizedBox(height: r.smallSpace),

//               Row(
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: CustomTextField(
//                       controller: _dateCtrl,
//                       label: 'Date *',
//                       prefixIcon: Icons.calendar_today_outlined,
//                       readOnly: true,
//                       onTap: () => _pickDate(
//                         ctrl: _dateCtrl,
//                         onPicked: (d) {
//                           setSheetState(() {
//                             _appointmentDate = d;
//                             _dateCtrl.text =
//                                 '${d.day.toString().padLeft(2, '0')}/'
//                                 '${d.month.toString().padLeft(2, '0')}/'
//                                 '${d.year}';
//                           });
//                         },
//                       ),
//                       validator: (v) =>
//                           (v == null || v.isEmpty) ? 'Select date' : null,
//                     ),
//                   ),
//                   SizedBox(width: r.wp(3)),
//                   Expanded(
//                     flex: 2,
//                     child: CustomTextField(
//                       controller: _timeCtrl,
//                       label: 'Time *',
//                       prefixIcon: Icons.access_time_outlined,
//                       readOnly: true,
//                       onTap: () => _pickTime(
//                         ctrl: _timeCtrl,
//                         onPicked: (t) {
//                           setSheetState(() {
//                             _appointmentTime = t;
//                             _timeCtrl.text = t.format(ctx);
//                           });
//                         },
//                       ),
//                       validator: (v) =>
//                           (v == null || v.isEmpty) ? 'Select time' : null,
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: r.mediumSpace),

//               CustomTextField(
//                 controller: _notesCtrl,
//                 label: 'Notes (Optional)',
//                 prefixIcon: Icons.notes_outlined,
//                 maxLines: 3,
//               ),

//               SizedBox(height: r.largeSpace),

//               // ── Custom Reminder ──
//               _sectionLabel(r, 'Set Reminder (Optional)'),
//               SizedBox(height: r.hp(0.5)),
//               Text(
//                 'Pick exactly when you want to be notified',
//                 style: AppTextStyles.bodySmall,
//               ),
//               SizedBox(height: r.smallSpace),

//               Row(
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: CustomTextField(
//                       controller: _reminderDateCtrl,
//                       label: 'Reminder Date',
//                       prefixIcon: Icons.notifications_outlined,
//                       readOnly: true,
//                       onTap: () => _pickDate(
//                         ctrl: _reminderDateCtrl,
//                         futureOnly: false,
//                         onPicked: (d) {
//                           setSheetState(() {
//                             _reminderDate = d;
//                             _reminderDateCtrl.text =
//                                 '${d.day.toString().padLeft(2, '0')}/'
//                                 '${d.month.toString().padLeft(2, '0')}/'
//                                 '${d.year}';
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: r.wp(3)),
//                   Expanded(
//                     flex: 2,
//                     child: CustomTextField(
//                       controller: _reminderTimeCtrl,
//                       label: 'Time',
//                       prefixIcon: Icons.alarm_outlined,
//                       readOnly: true,
//                       onTap: () => _pickTime(
//                         ctrl: _reminderTimeCtrl,
//                         onPicked: (t) {
//                           setSheetState(() {
//                             _reminderTime = t;
//                             _reminderTimeCtrl.text = t.format(ctx);
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               // Preview reminder
//               if (_reminderDate != null && _reminderTime != null) ...[
//                 SizedBox(height: r.smallSpace),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: r.wp(3),
//                     vertical: r.hp(1),
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.warning.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(r.smallRadius),
//                     border: Border.all(
//                       color: AppColors.warning.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.notifications_active_outlined,
//                         size: r.wp(4),
//                         color: AppColors.warning,
//                       ),
//                       SizedBox(width: r.wp(2)),
//                       Expanded(
//                         child: Text(
//                           'Reminder: ${_reminderDateCtrl.text} at ${_reminderTimeCtrl.text}',
//                           style: AppTextStyles.bodySmall.copyWith(
//                             color: AppColors.warning,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () => setSheetState(() {
//                           _reminderDate = null;
//                           _reminderTime = null;
//                           _reminderDateCtrl.clear();
//                           _reminderTimeCtrl.clear();
//                         }),
//                         child: Icon(
//                           Icons.close,
//                           size: r.wp(4),
//                           color: AppColors.warning,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],

//               SizedBox(height: r.largeSpace),

//               CustomButton(
//                 text: 'Book Appointment',
//                 onPressed: () => _saveDoctor(setSheetState),
//                 isLoading: dp.isLoading,
//                 icon: Icons.event_available,
//               ),

//               SizedBox(height: r.largeSpace),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _sectionLabel(ResponsiveHelper r, String title) {
//     return Row(
//       children: [
//         Container(
//           width: 3,
//           height: 14,
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         SizedBox(width: r.wp(2)),
//         Text(
//           title,
//           style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────
//   // HELPERS
//   // ─────────────────────────────────────

//   String _formatDate(DateTime dt) {
//     const m = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
//   }

//   String _formatTime(DateTime dt) {
//     final h = dt.hour;
//     final min = dt.minute.toString().padLeft(2, '0');
//     final suf = h >= 12 ? 'PM' : 'AM';
//     final disp = h > 12 ? h - 12 : (h == 0 ? 12 : h);
//     return '$disp:$min $suf';
//   }

//   bool _isToday(DateTime dt) {
//     final n = DateTime.now();
//     return dt.year == n.year && dt.month == n.month && dt.day == n.day;
//   }

//   bool _isTomorrow(DateTime dt) {
//     final t = DateTime.now().add(const Duration(days: 1));
//     return dt.year == t.year && dt.month == t.month && dt.day == t.day;
//   }

//   String _getCountdown(DateTime appt) {
//     final diff = appt.difference(DateTime.now());
//     if (diff.isNegative) return 'Overdue';
//     if (_isToday(appt)) {
//       if (diff.inHours < 1) return 'In ${diff.inMinutes}m';
//       return 'Today ${diff.inHours}h';
//     }
//     if (_isTomorrow(appt)) return 'Tomorrow';
//     if (diff.inDays < 7) return 'In ${diff.inDays}d';
//     if (diff.inDays < 30) return 'In ${(diff.inDays / 7).round()}w';
//     return 'In ${(diff.inDays / 30).round()}mo';
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:meditrack/views/doctors/doctor_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/doctor_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../services/notification/notification_service.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  // ── Form controllers ──
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _specialityCtrl = TextEditingController();
  final _clinicCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  // ── Reminder controllers (separate from appointment date/time) ──
  final _reminderDateCtrl = TextEditingController();
  final _reminderTimeCtrl = TextEditingController();

  DateTime? _appointmentDate;
  TimeOfDay? _appointmentTime;
  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDoctors);
  }

  Future<void> _loadDoctors() async {
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    await context.read<DoctorProvider>().getDoctors(uid);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specialityCtrl.dispose();
    _clinicCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _reminderDateCtrl.dispose();
    _reminderTimeCtrl.dispose();
    super.dispose();
  }

  // ── Date/Time pickers ──
  Future<void> _pickDate({
    required TextEditingController ctrl,
    required void Function(DateTime) onPicked,
    DateTime? initial,
    bool futureOnly = true,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: futureOnly
          ? DateTime.now().subtract(const Duration(days: 1))
          : DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickTime({
    required TextEditingController ctrl,
    required void Function(TimeOfDay) onPicked,
    TimeOfDay? initial,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  // ── Build full appointment DateTime ──
  DateTime _buildDateTime(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  // ── Open form sheet ──
  void _showAddSheet() {
    _clearForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => _buildSheet(ctx, setSheetState),
      ),
    );
  }

  // ── Save appointment ──
  Future<void> _saveDoctor(StateSetter setSheetState) async {
    if (!_formKey.currentState!.validate()) return;
    if (_appointmentDate == null) {
      _snack('Please select appointment date!', isError: true);
      return;
    }
    if (_appointmentTime == null) {
      _snack('Please select appointment time!', isError: true);
      return;
    }

    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    final apptDateTime = _buildDateTime(_appointmentDate!, _appointmentTime!);

    final ok = await context.read<DoctorProvider>().addDoctor(
      userId: uid,
      doctorName: _nameCtrl.text.trim(),
      speciality: _specialityCtrl.text.trim(),
      clinicName: _clinicCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      appointmentDate: apptDateTime,
      notes: _notesCtrl.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      // Schedule custom reminder if user set one
      if (_reminderDate != null && _reminderTime != null) {
        final reminderDateTime = _buildDateTime(_reminderDate!, _reminderTime!);
        await _scheduleCustomReminder(
          doctorName: _nameCtrl.text.trim(),
          clinicName: _clinicCtrl.text.trim(),
          apptDateTime: apptDateTime,
          reminderDateTime: reminderDateTime,
        );
      }
      Navigator.pop(context);
      _clearForm();
      _snack(
        'Appointment booked!${(_reminderDate != null) ? ' Reminder set ✅' : ''}',
      );
    } else {
      _snack(context.read<DoctorProvider>().errorMessage, isError: true);
    }
  }

  // ── Schedule a custom one-shot reminder ──
  Future<void> _scheduleCustomReminder({
    required String doctorName,
    required String clinicName,
    required DateTime apptDateTime,
    required DateTime reminderDateTime,
  }) async {
    if (reminderDateTime.isBefore(DateTime.now())) {
      _snack('Reminder time is in the past — skipped', isError: false);
      return;
    }
    final notifId =
        reminderDateTime.millisecondsSinceEpoch ~/ 1000 % 2000000000;
    try {
      await NotificationService().scheduleCustomReminder(
        id: notifId,
        title: '🏥 Appointment Reminder',
        body: 'Dr. $doctorName at $clinicName — ${_formatTime(apptDateTime)}',
        scheduledDateTime: reminderDateTime,
      );
      debugPrint('Custom reminder set for $reminderDateTime');
    } catch (e) {
      debugPrint('Custom reminder failed: $e');
    }
  }

  // ── Mark appointment as done (delete) ──
  Future<void> _markDone(DoctorModel doctor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Appointment Complete?'),
        content: Text(
          'Mark appointment with Dr. ${doctor.doctorName} as completed?\n\n'
          'This will remove it from your list.',
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

    if (confirm == true && mounted) {
      final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
      await context.read<DoctorProvider>().markAppointmentDone(
        uid,
        doctor.id ?? '',
      );
    }
  }

  // ── Delete appointment ──
  Future<void> _deleteDoctor(DoctorModel doctor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: Text(
          'Cancel appointment with Dr. ${doctor.doctorName}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Cancel Appointment',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
      await context.read<DoctorProvider>().deleteDoctor(uid, doctor.id ?? '');
    }
  }

  void _clearForm() {
    _nameCtrl.clear();
    _specialityCtrl.clear();
    _clinicCtrl.clear();
    _phoneCtrl.clear();
    _addressCtrl.clear();
    _notesCtrl.clear();
    _dateCtrl.clear();
    _timeCtrl.clear();
    _reminderDateCtrl.clear();
    _reminderTimeCtrl.clear();
    setState(() {
      _appointmentDate = null;
      _appointmentTime = null;
      _reminderDate = null;
      _reminderTime = null;
    });
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // ─────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final dp = context.watch<DoctorProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(r, dp),
            Expanded(
              child: dp.isLoading
                  ? const LoadingIndicator()
                  : RefreshIndicator(
                      onRefresh: _loadDoctors,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: r.pagePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: r.mediumSpace),
                            if (dp.upcomingDoctors.isNotEmpty)
                              _buildStatsBar(r, dp),
                            SizedBox(height: r.mediumSpace),
                            dp.upcomingDoctors.isEmpty
                                ? EmptyState(
                                    message:
                                        'No upcoming appointments!\nBook your next visit.',
                                    icon: Icons.event_available_outlined,
                                    buttonText: 'Book Appointment',
                                    onButtonTap: _showAddSheet,
                                  )
                                : Column(
                                    children: dp.upcomingDoctors
                                        .map(
                                          (d) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom: r.mediumSpace,
                                            ),
                                            child: _buildCard(r, d),
                                          ),
                                        )
                                        .toList(),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Book Appointment',
          style: AppTextStyles.button.copyWith(fontSize: 13),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // HEADER — fixed overflow with Expanded
  // ─────────────────────────────────────

  Widget _buildHeader(ResponsiveHelper r, DoctorProvider dp) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        r.wp(2),
        r.smallSpace,
        r.wp(4),
        r.smallSpace,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(AppRoutes.dashboard),
            icon: const Icon(Icons.arrow_back_ios),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: r.wp(2)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctors & Appointments',
                  style: AppTextStyles.heading3,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${dp.upcomingDoctors.length} upcoming',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STATS BAR ──
  Widget _buildStatsBar(ResponsiveHelper r, DoctorProvider dp) {
    final todayCount = dp.upcomingDoctors
        .where((d) => _isToday(d.appointmentDate))
        .length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.wp(4), vertical: r.hp(1.5)),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(r.mediumRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            r,
            '${dp.upcomingDoctors.length}',
            'Upcoming',
            AppColors.primary,
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.primary.withOpacity(0.2),
          ),
          _statItem(r, '$todayCount', 'Today', AppColors.warning),
          Container(
            width: 1,
            height: 32,
            color: AppColors.primary.withOpacity(0.2),
          ),
          _statItem(
            r,
            dp.upcomingDoctors
                .where((d) => _isTomorrow(d.appointmentDate))
                .length
                .toString(),
            'Tomorrow',
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    ResponsiveHelper r,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading3.copyWith(color: color)),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  // ─────────────────────────────────────
  // APPOINTMENT CARD
  // ─────────────────────────────────────

  Widget _buildCard(ResponsiveHelper r, DoctorModel doctor) {
    final countdown = _getCountdown(doctor.appointmentDate);
    final isToday = _isToday(doctor.appointmentDate);
    final isTomorrow = _isTomorrow(doctor.appointmentDate);
    final badgeColor = isToday
        ? AppColors.error
        : isTomorrow
        ? AppColors.warning
        : AppColors.primary;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doctor)),
      ),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar circle
                Container(
                  width: r.wp(12),
                  height: r.wp(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      doctor.doctorName.isNotEmpty
                          ? doctor.doctorName[0].toUpperCase()
                          : 'D',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: r.wp(3)),

                // Name + speciality + clinic
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${doctor.doctorName}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: r.hp(0.3)),
                      _iconRow(
                        r,
                        Icons.medical_services_outlined,
                        doctor.speciality,
                      ),
                      SizedBox(height: r.hp(0.2)),
                      _iconRow(
                        r,
                        Icons.local_hospital_outlined,
                        doctor.clinicName,
                      ),
                    ],
                  ),
                ),

                // Countdown badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.wp(2.5),
                    vertical: r.hp(0.5),
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(r.largeRadius),
                    border: Border.all(color: badgeColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    countdown,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: r.mediumSpace),
            Divider(height: 1, color: const Color(0xFF9E9EAA).withOpacity(0.2)),
            SizedBox(height: r.smallSpace),

            // ── Date + Time chips ──
            Row(
              children: [
                _chip(
                  r,
                  Icons.calendar_today_outlined,
                  _formatDate(doctor.appointmentDate),
                  AppColors.primary,
                ),
                SizedBox(width: r.wp(2)),
                _chip(
                  r,
                  Icons.access_time_outlined,
                  _formatTime(doctor.appointmentDate),
                  AppColors.secondary,
                ),
              ],
            ),

            // ── Notes ──
            if (doctor.notes != null && doctor.notes!.isNotEmpty) ...[
              SizedBox(height: r.smallSpace),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.wp(3),
                  vertical: r.hp(0.8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(r.smallRadius),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_outlined,
                      size: r.wp(3.5),
                      color: AppColors.info,
                    ),
                    SizedBox(width: r.wp(2)),
                    Expanded(
                      child: Text(
                        doctor.notes!,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: r.smallSpace),

            // ── Action buttons ──
            Row(
              children: [
                if (doctor.phone != null && doctor.phone!.isNotEmpty) ...[
                  Expanded(
                    child: _actionBtn(
                      r,
                      icon: Icons.call_outlined,
                      label: 'Call',
                      color: AppColors.success,
                      onTap: () => _call(doctor.phone!),
                    ),
                  ),
                  SizedBox(width: r.wp(2)),
                ],
                Expanded(
                  child: _actionBtn(
                    r,
                    icon: Icons.delete_outline,
                    label: 'Cancel',
                    color: AppColors.error,
                    onTap: () => _deleteDoctor(doctor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconRow(ResponsiveHelper r, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: r.wp(3.5), color: const Color(0xFF9E9EAA)),
        SizedBox(width: r.wp(1)),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _chip(ResponsiveHelper r, IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.wp(2.5), vertical: r.hp(0.6)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(r.smallRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.wp(3.5), color: color),
          SizedBox(width: r.wp(1.5)),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    ResponsiveHelper r, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: r.hp(1.2)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(r.smallRadius),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: r.wp(4), color: color),
            SizedBox(width: r.wp(1.5)),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // BOTTOM SHEET
  // ─────────────────────────────────────

  Widget _buildSheet(BuildContext ctx, StateSetter setSheetState) {
    final r = ResponsiveHelper(ctx);
    final dp = context.watch<DoctorProvider>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: r.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.mediumSpace),

              // Handle bar
              Center(
                child: Container(
                  width: r.wp(10),
                  height: r.hp(0.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9E9EAA).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(r.smallRadius),
                  ),
                ),
              ),
              SizedBox(height: r.mediumSpace),

              Text('Book Appointment', style: AppTextStyles.heading2),
              SizedBox(height: r.largeSpace),

              // ── Doctor Details ──
              _sectionLabel(r, 'Doctor Details'),
              SizedBox(height: r.smallSpace),

              CustomTextField(
                controller: _nameCtrl,
                label: 'Doctor Name *',
                prefixIcon: Icons.person_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Name is required!' : null,
              ),
              SizedBox(height: r.mediumSpace),

              CustomTextField(
                controller: _specialityCtrl,
                label: 'Speciality *',
                prefixIcon: Icons.medical_services_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Speciality is required!' : null,
              ),
              SizedBox(height: r.mediumSpace),

              CustomTextField(
                controller: _clinicCtrl,
                label: 'Clinic / Hospital *',
                prefixIcon: Icons.local_hospital_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Clinic name is required!'
                    : null,
              ),
              SizedBox(height: r.mediumSpace),

              CustomTextField(
                controller: _phoneCtrl,
                label: 'Phone (Optional)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: r.mediumSpace),

              CustomTextField(
                controller: _addressCtrl,
                label: 'Address (Optional)',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
              ),

              SizedBox(height: r.largeSpace),

              // ── Appointment Date & Time ──
              _sectionLabel(r, 'Appointment Date & Time'),
              SizedBox(height: r.smallSpace),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _dateCtrl,
                      label: 'Date *',
                      prefixIcon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: () => _pickDate(
                        ctrl: _dateCtrl,
                        onPicked: (d) {
                          setSheetState(() {
                            _appointmentDate = d;
                            _dateCtrl.text =
                                '${d.day.toString().padLeft(2, '0')}/'
                                '${d.month.toString().padLeft(2, '0')}/'
                                '${d.year}';
                          });
                        },
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Select date' : null,
                    ),
                  ),
                  SizedBox(width: r.wp(3)),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _timeCtrl,
                      label: 'Time *',
                      prefixIcon: Icons.access_time_outlined,
                      readOnly: true,
                      onTap: () => _pickTime(
                        ctrl: _timeCtrl,
                        onPicked: (t) {
                          setSheetState(() {
                            _appointmentTime = t;
                            _timeCtrl.text = t.format(ctx);
                          });
                        },
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Select time' : null,
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.mediumSpace),

              CustomTextField(
                controller: _notesCtrl,
                label: 'Notes (Optional)',
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
              ),

              SizedBox(height: r.largeSpace),

              // ── Custom Reminder ──
              _sectionLabel(r, 'Set Reminder (Optional)'),
              SizedBox(height: r.hp(0.5)),
              Text(
                'Pick exactly when you want to be notified',
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: r.smallSpace),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _reminderDateCtrl,
                      label: 'Reminder Date',
                      prefixIcon: Icons.notifications_outlined,
                      readOnly: true,
                      onTap: () => _pickDate(
                        ctrl: _reminderDateCtrl,
                        futureOnly: false,
                        onPicked: (d) {
                          setSheetState(() {
                            _reminderDate = d;
                            _reminderDateCtrl.text =
                                '${d.day.toString().padLeft(2, '0')}/'
                                '${d.month.toString().padLeft(2, '0')}/'
                                '${d.year}';
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: r.wp(3)),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _reminderTimeCtrl,
                      label: 'Time',
                      prefixIcon: Icons.alarm_outlined,
                      readOnly: true,
                      onTap: () => _pickTime(
                        ctrl: _reminderTimeCtrl,
                        onPicked: (t) {
                          setSheetState(() {
                            _reminderTime = t;
                            _reminderTimeCtrl.text = t.format(ctx);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Preview reminder
              if (_reminderDate != null && _reminderTime != null) ...[
                SizedBox(height: r.smallSpace),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.wp(3),
                    vertical: r.hp(1),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(r.smallRadius),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: r.wp(4),
                        color: AppColors.warning,
                      ),
                      SizedBox(width: r.wp(2)),
                      Expanded(
                        child: Text(
                          'Reminder: ${_reminderDateCtrl.text} at ${_reminderTimeCtrl.text}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setSheetState(() {
                          _reminderDate = null;
                          _reminderTime = null;
                          _reminderDateCtrl.clear();
                          _reminderTimeCtrl.clear();
                        }),
                        child: Icon(
                          Icons.close,
                          size: r.wp(4),
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: r.largeSpace),

              CustomButton(
                text: 'Book Appointment',
                onPressed: () => _saveDoctor(setSheetState),
                isLoading: dp.isLoading,
                icon: Icons.event_available,
              ),

              SizedBox(height: r.largeSpace),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(ResponsiveHelper r, String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: r.wp(2)),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────

  String _formatDate(DateTime dt) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final suf = h >= 12 ? 'PM' : 'AM';
    final disp = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$disp:$min $suf';
  }

  bool _isToday(DateTime dt) {
    final n = DateTime.now();
    return dt.year == n.year && dt.month == n.month && dt.day == n.day;
  }

  bool _isTomorrow(DateTime dt) {
    final t = DateTime.now().add(const Duration(days: 1));
    return dt.year == t.year && dt.month == t.month && dt.day == t.day;
  }

  String _getCountdown(DateTime appt) {
    final diff = appt.difference(DateTime.now());
    if (diff.isNegative) return 'Overdue';
    if (_isToday(appt)) {
      if (diff.inHours < 1) return 'In ${diff.inMinutes}m';
      return 'Today ${diff.inHours}h';
    }
    if (_isTomorrow(appt)) return 'Tomorrow';
    if (diff.inDays < 7) return 'In ${diff.inDays}d';
    if (diff.inDays < 30) return 'In ${(diff.inDays / 7).round()}w';
    return 'In ${(diff.inDays / 30).round()}mo';
  }
}
