// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:provider/provider.dart';
// // import '../../core/constants/app_colors.dart';
// // import '../../core/constants/app_text_style.dart';
// // import '../../core/utils/responsive_helper.dart';
// // import '../../providers/theme_provider.dart';
// // import '../../routes/app_routes.dart';
// // import '../../widgets/common/custom_card.dart';

// // class SettingsScreen extends StatelessWidget {
// //   const SettingsScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final r = ResponsiveHelper(context);
// //     final themeProvider = context.watch<ThemeProvider>();

// //     return Scaffold(
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: r.pagePadding,
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               SizedBox(height: r.mediumSpace),

// //               // Header
// //               Row(
// //                 children: [
// //                   IconButton(
// //                     onPressed: () => context.go(AppRoutes.profile),
// //                     icon: const Icon(Icons.arrow_back_ios),
// //                     padding: EdgeInsets.zero,
// //                   ),
// //                   SizedBox(width: r.wp(2)),
// //                   Text('Settings', style: AppTextStyles.heading2),
// //                 ],
// //               ),

// //               SizedBox(height: r.largeSpace),

// //               // Appearance
// //               Text('Appearance', style: AppTextStyles.heading3),
// //               SizedBox(height: r.mediumSpace),
// //               CustomCard(
// //                 child: Row(
// //                   children: [
// //                     Container(
// //                       padding: EdgeInsets.all(r.wp(2)),
// //                       decoration: BoxDecoration(
// //                         color: AppColors.primary.withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(r.smallRadius),
// //                       ),
// //                       child: Icon(
// //                         themeProvider.isDarkMode
// //                             ? Icons.dark_mode
// //                             : Icons.light_mode,
// //                         color: AppColors.primary,
// //                         size: r.smallIcon,
// //                       ),
// //                     ),
// //                     SizedBox(width: r.wp(3)),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Dark Mode',
// //                             style: AppTextStyles.bodyMedium.copyWith(
// //                               fontWeight: FontWeight.w500,
// //                             ),
// //                           ),
// //                           Text(
// //                             themeProvider.isDarkMode
// //                                 ? 'Dark theme is on'
// //                                 : 'Light theme is on',
// //                             style: AppTextStyles.bodySmall,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     Switch(
// //                       value: themeProvider.isDarkMode,
// //                       onChanged: (_) => themeProvider.toggleTheme(),
// //                       activeColor: AppColors.primary,
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               SizedBox(height: r.largeSpace),

// //               // Notifications
// //               Text('Notifications', style: AppTextStyles.heading3),
// //               SizedBox(height: r.mediumSpace),
// //               CustomCard(
// //                 child: Column(
// //                   children: [
// //                     _buildSettingRow(
// //                       r,
// //                       icon: Icons.notifications_outlined,
// //                       iconColor: AppColors.secondary,
// //                       title: 'Medicine Reminders',
// //                       subtitle: 'Get notified for medicines',
// //                       trailing: Switch(
// //                         value: true,
// //                         onChanged: (_) {},
// //                         activeColor: AppColors.primary,
// //                       ),
// //                     ),
// //                     Divider(
// //                       height: 1,
// //                       color: const Color(0xFF9E9EAA).withOpacity(0.1),
// //                     ),
// //                     _buildSettingRow(
// //                       r,
// //                       icon: Icons.calendar_month_outlined,
// //                       iconColor: AppColors.success,
// //                       title: 'Appointment Reminders',
// //                       subtitle: 'Get notified for appointments',
// //                       trailing: Switch(
// //                         value: true,
// //                         onChanged: (_) {},
// //                         activeColor: AppColors.primary,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               SizedBox(height: r.largeSpace),

// //               // Data
// //               Text('Data', style: AppTextStyles.heading3),
// //               SizedBox(height: r.mediumSpace),
// //               CustomCard(
// //                 child: Column(
// //                   children: [
// //                     _buildSettingRow(
// //                       r,
// //                       icon: Icons.sync,
// //                       iconColor: AppColors.primary,
// //                       title: 'Auto Sync',
// //                       subtitle: 'Sync data with cloud',
// //                       trailing: Switch(
// //                         value: true,
// //                         onChanged: (_) {},
// //                         activeColor: AppColors.primary,
// //                       ),
// //                     ),
// //                     Divider(
// //                       height: 1,
// //                       color: const Color(0xFF9E9EAA).withOpacity(0.1),
// //                     ),
// //                     _buildSettingRow(
// //                       r,
// //                       icon: Icons.storage_outlined,
// //                       iconColor: AppColors.warning,
// //                       title: 'Clear Cache',
// //                       subtitle: 'Clear local stored data',
// //                       trailing: Icon(
// //                         Icons.arrow_forward_ios,
// //                         size: r.wp(3.5),
// //                         color: const Color(0xFF9E9EAA),
// //                       ),
// //                       onTap: () => _showClearCacheDialog(context),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               SizedBox(height: r.largeSpace),

// //               // About
// //               Text('About', style: AppTextStyles.heading3),
// //               SizedBox(height: r.mediumSpace),
// //               CustomCard(
// //                 child: Column(
// //                   children: [
// //                     _buildSettingRow(
// //                       r,
// //                       icon: Icons.info_outline,
// //                       iconColor: AppColors.secondary,
// //                       title: 'App Version',
// //                       subtitle: 'MediTrack v1.0.0',
// //                       trailing: const SizedBox(),
// //                     ),
// //                     Divider(
// //                       height: 1,
// //                       color: const Color(0xFF9E9EAA).withOpacity(0.1),
// //                     ),
// //                     _buildSettingRow(
// //                       r,
// //                       icon: Icons.privacy_tip_outlined,
// //                       iconColor: AppColors.success,
// //                       title: 'Privacy Policy',
// //                       subtitle: 'Read our privacy policy',
// //                       trailing: Icon(
// //                         Icons.arrow_forward_ios,
// //                         size: r.wp(3.5),
// //                         color: const Color(0xFF9E9EAA),
// //                       ),
// //                       onTap: () {},
// //                     ),
// //                     Divider(
// //                       height: 1,
// //                       color: const Color(0xFF9E9EAA).withOpacity(0.1),
// //                     ),
// //                     _buildSettingRow(
// //                       r,
// //                       icon: Icons.description_outlined,
// //                       iconColor: AppColors.warning,
// //                       title: 'Terms of Service',
// //                       subtitle: 'Read our terms',
// //                       trailing: Icon(
// //                         Icons.arrow_forward_ios,
// //                         size: r.wp(3.5),
// //                         color: const Color(0xFF9E9EAA),
// //                       ),
// //                       onTap: () {},
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               SizedBox(height: r.largeSpace),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // Reusable setting row
// //   Widget _buildSettingRow(
// //     ResponsiveHelper r, {
// //     required IconData icon,
// //     required Color iconColor,
// //     required String title,
// //     required String subtitle,
// //     required Widget trailing,
// //     VoidCallback? onTap,
// //   }) {
// //     return InkWell(
// //       onTap: onTap,
// //       child: Padding(
// //         padding: EdgeInsets.symmetric(vertical: r.hp(1.5)),
// //         child: Row(
// //           children: [
// //             Container(
// //               padding: EdgeInsets.all(r.wp(2)),
// //               decoration: BoxDecoration(
// //                 color: iconColor.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(r.smallRadius),
// //               ),
// //               child: Icon(icon, color: iconColor, size: r.smallIcon),
// //             ),
// //             SizedBox(width: r.wp(3)),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     title,
// //                     style: AppTextStyles.bodyMedium.copyWith(
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                   Text(subtitle, style: AppTextStyles.bodySmall),
// //                 ],
// //               ),
// //             ),
// //             trailing,
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // Clear cache dialog
// //   void _showClearCacheDialog(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text('Clear Cache', style: AppTextStyles.heading3),
// //         content: Text(
// //           'This will clear all locally stored data. Cloud data will not be affected.',
// //           style: AppTextStyles.bodyMedium,
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text(
// //               'Cancel',
// //               style: AppTextStyles.bodyMedium.copyWith(
// //                 color: const Color(0xFF9E9EAA),
// //               ),
// //             ),
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               Navigator.pop(context);
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(
// //                   content: Text('Cache cleared!'),
// //                   backgroundColor: AppColors.success,
// //                 ),
// //               );
// //             },
// //             child: Text(
// //               'Clear',
// //               style: AppTextStyles.bodyMedium.copyWith(
// //                 color: AppColors.error,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/constants/app_text_style.dart';
// import '../../core/utils/responsive_helper.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/doctor_provider.dart';
// import '../../providers/medicine_provider.dart';
// import '../../providers/theme_provider.dart';
// import '../../routes/app_routes.dart';
// import '../../services/notification/notification_service.dart';
// import '../../widgets/common/custom_card.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   // ── Notification toggle states ──
//   bool _medicineNotifs = true;
//   bool _appointmentNotifs = true;

//   // SharedPrefs keys
//   static const _keyMedicine = 'notif_medicine_enabled';
//   static const _keyAppointment = 'notif_appointment_enabled';

//   @override
//   void initState() {
//     super.initState();
//     _loadPrefs();
//   }

//   // ── Load saved preferences ──
//   Future<void> _loadPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _medicineNotifs = prefs.getBool(_keyMedicine) ?? true;
//       _appointmentNotifs = prefs.getBool(_keyAppointment) ?? true;
//     });
//   }

//   // ── Toggle Medicine Notifications ──
//   Future<void> _toggleMedicineNotifs(bool value) async {
//     setState(() => _medicineNotifs = value);

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyMedicine, value);

//     final ns = NotificationService();

//     if (!value) {
//       // OFF — sab medicine notifications cancel karo
//       final medicines = context.read<MedicineProvider>().medicines;
//       for (final m in medicines) {
//         await ns.cancelMedicineReminders(m);
//       }
//       _snack('Medicine reminders off kar diye ✓', isError: false);
//     } else {
//       // ON — sab active medicines ke liye reschedule karo
//       final medicines = context.read<MedicineProvider>().medicines;
//       int count = 0;
//       for (final m in medicines) {
//         if (m.reminderTimes.isNotEmpty) {
//           await ns.scheduleMedicineReminder(m);
//           count++;
//         }
//       }
//       _snack('$count medicine reminders set kar diye ✓', isError: false);
//     }
//   }

//   // ── Toggle Appointment Notifications ──
//   Future<void> _toggleAppointmentNotifs(bool value) async {
//     setState(() => _appointmentNotifs = value);

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyAppointment, value);

//     final ns = NotificationService();

//     if (!value) {
//       // OFF — sab appointment notifications cancel karo
//       final doctors = context.read<DoctorProvider>().doctors;
//       for (final d in doctors) {
//         await ns.cancelAppointmentReminder(d);
//       }
//       _snack('Appointment reminders off kar diye ✓', isError: false);
//     } else {
//       // ON — sab upcoming appointments ke liye reschedule karo
//       final doctors = context.read<DoctorProvider>().upcomingDoctors;
//       int count = 0;
//       for (final d in doctors) {
//         await ns.scheduleAppointmentReminder(d);
//         count++;
//       }
//       _snack('$count appointment reminders set kar diye ✓', isError: false);
//     }
//   }

//   void _snack(String msg, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? AppColors.error : AppColors.success,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   // ── Load data if not loaded yet ──
//   Future<void> _ensureDataLoaded() async {
//     final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
//     if (uid.isEmpty) return;

//     final mp = context.read<MedicineProvider>();
//     final dp = context.read<DoctorProvider>();

//     if (mp.medicines.isEmpty) await mp.getMedicines(uid);
//     if (dp.doctors.isEmpty) await dp.getDoctors(uid);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);
//     final themeProvider = context.watch<ThemeProvider>();

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: r.pagePadding,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: r.mediumSpace),

//               // ── Header ──
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => context.go(AppRoutes.profile),
//                     icon: const Icon(Icons.arrow_back_ios),
//                     padding: EdgeInsets.zero,
//                   ),
//                   SizedBox(width: r.wp(2)),
//                   Text('Settings', style: AppTextStyles.heading2),
//                 ],
//               ),

//               SizedBox(height: r.largeSpace),

//               // ── Appearance ──
//               Text('Appearance', style: AppTextStyles.heading3),
//               SizedBox(height: r.mediumSpace),
//               CustomCard(
//                 child: _buildSettingRow(
//                   r,
//                   icon: themeProvider.isDarkMode
//                       ? Icons.dark_mode
//                       : Icons.light_mode,
//                   iconColor: AppColors.primary,
//                   title: 'Dark Mode',
//                   subtitle: themeProvider.isDarkMode
//                       ? 'Dark theme is on'
//                       : 'Light theme is on',
//                   trailing: Switch(
//                     value: themeProvider.isDarkMode,
//                     onChanged: (_) => themeProvider.toggleTheme(),
//                     activeColor: AppColors.primary,
//                   ),
//                 ),
//               ),

//               SizedBox(height: r.largeSpace),

//               // ── Notifications ──
//               Text('Notifications', style: AppTextStyles.heading3),
//               SizedBox(height: r.mediumSpace),
//               CustomCard(
//                 child: Column(
//                   children: [
//                     // Medicine toggle
//                     _buildSettingRow(
//                       r,
//                       icon: Icons.notifications_outlined,
//                       iconColor: AppColors.secondary,
//                       title: 'Medicine Reminders',
//                       subtitle: _medicineNotifs
//                           ? 'Reminders on hain'
//                           : 'Reminders off hain',
//                       trailing: Switch(
//                         value: _medicineNotifs,
//                         onChanged: (val) async {
//                           await _ensureDataLoaded();
//                           await _toggleMedicineNotifs(val);
//                         },
//                         activeColor: AppColors.primary,
//                       ),
//                     ),

//                     Divider(
//                       height: 1,
//                       color: const Color(0xFF9E9EAA).withOpacity(0.1),
//                     ),

//                     // Appointment toggle
//                     _buildSettingRow(
//                       r,
//                       icon: Icons.calendar_month_outlined,
//                       iconColor: AppColors.success,
//                       title: 'Appointment Reminders',
//                       subtitle: _appointmentNotifs
//                           ? 'Reminders on hain'
//                           : 'Reminders off hain',
//                       trailing: Switch(
//                         value: _appointmentNotifs,
//                         onChanged: (val) async {
//                           await _ensureDataLoaded();
//                           await _toggleAppointmentNotifs(val);
//                         },
//                         activeColor: AppColors.primary,
//                       ),
//                     ),

//                     Divider(
//                       height: 1,
//                       color: const Color(0xFF9E9EAA).withOpacity(0.1),
//                     ),

//                     // Test notification button
//                     _buildSettingRow(
//                       r,
//                       icon: Icons.notifications_active_outlined,
//                       iconColor: AppColors.warning,
//                       title: 'Test Notification',
//                       subtitle: 'Ek test notification bhejo',
//                       trailing: Icon(
//                         Icons.arrow_forward_ios,
//                         size: r.wp(3.5),
//                         color: const Color(0xFF9E9EAA),
//                       ),
//                       onTap: () async {
//                         await NotificationService().showTestNotification();
//                         _snack('Test notification bhej diya!');
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: r.largeSpace),

//               // ── Data ──
//               Text('Data', style: AppTextStyles.heading3),
//               SizedBox(height: r.mediumSpace),
//               CustomCard(
//                 child: Column(
//                   children: [
//                     _buildSettingRow(
//                       r,
//                       icon: Icons.storage_outlined,
//                       iconColor: AppColors.warning,
//                       title: 'Clear Cache',
//                       subtitle: 'Clear local stored data',
//                       trailing: Icon(
//                         Icons.arrow_forward_ios,
//                         size: r.wp(3.5),
//                         color: const Color(0xFF9E9EAA),
//                       ),
//                       onTap: () => _showClearCacheDialog(),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: r.largeSpace),

//               // ── About ──
//               Text('About', style: AppTextStyles.heading3),
//               SizedBox(height: r.mediumSpace),
//               CustomCard(
//                 child: Column(
//                   children: [
//                     _buildSettingRow(
//                       r,
//                       icon: Icons.info_outline,
//                       iconColor: AppColors.secondary,
//                       title: 'App Version',
//                       subtitle: 'MediTrack v1.0.0',
//                       trailing: const SizedBox(),
//                     ),
//                     Divider(
//                       height: 1,
//                       color: const Color(0xFF9E9EAA).withOpacity(0.1),
//                     ),
//                     _buildSettingRow(
//                       r,
//                       icon: Icons.privacy_tip_outlined,
//                       iconColor: AppColors.success,
//                       title: 'Privacy Policy',
//                       subtitle: 'Read our privacy policy',
//                       trailing: Icon(
//                         Icons.arrow_forward_ios,
//                         size: r.wp(3.5),
//                         color: const Color(0xFF9E9EAA),
//                       ),
//                       onTap: () {},
//                     ),
//                     Divider(
//                       height: 1,
//                       color: const Color(0xFF9E9EAA).withOpacity(0.1),
//                     ),
//                     _buildSettingRow(
//                       r,
//                       icon: Icons.description_outlined,
//                       iconColor: AppColors.warning,
//                       title: 'Terms of Service',
//                       subtitle: 'Read our terms',
//                       trailing: Icon(
//                         Icons.arrow_forward_ios,
//                         size: r.wp(3.5),
//                         color: const Color(0xFF9E9EAA),
//                       ),
//                       onTap: () {},
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: r.largeSpace),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Reusable row widget ──
//   Widget _buildSettingRow(
//     ResponsiveHelper r, {
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required Widget trailing,
//     VoidCallback? onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(r.mediumRadius),
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: r.hp(1.5)),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(r.wp(2)),
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(r.smallRadius),
//               ),
//               child: Icon(icon, color: iconColor, size: r.smallIcon),
//             ),
//             SizedBox(width: r.wp(3)),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Text(subtitle, style: AppTextStyles.bodySmall),
//                 ],
//               ),
//             ),
//             trailing,
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Clear cache dialog ──
//   void _showClearCacheDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Clear Cache', style: AppTextStyles.heading3),
//         content: Text(
//           'Ye local data clear kar dega. Cloud ka data safe rahega.',
//           style: AppTextStyles.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text(
//               'Cancel',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: const Color(0xFF9E9EAA),
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               _snack('Cache cleared!');
//             },
//             child: Text(
//               'Clear',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.error,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/notification/notification_service.dart';
import '../../widgets/common/custom_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _medicineNotifs = true;
  bool _appointmentNotifs = true;

  static const _keyMedicine = 'notif_medicine_enabled';
  static const _keyAppointment = 'notif_appointment_enabled';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _medicineNotifs = prefs.getBool(_keyMedicine) ?? true;
      _appointmentNotifs = prefs.getBool(_keyAppointment) ?? true;
    });
  }

  Future<void> _toggleMedicineNotifs(bool value) async {
    setState(() => _medicineNotifs = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMedicine, value);

    await _ensureDataLoaded();
    final ns = NotificationService();
    final medicines = context.read<MedicineProvider>().medicines;

    if (!value) {
      for (final m in medicines) {
        await ns.cancelMedicineReminders(m);
      }
      _snack('Medicine reminders disabled');
    } else {
      int count = 0;
      for (final m in medicines) {
        if (m.reminderTimes.isNotEmpty) {
          await ns.scheduleMedicineReminder(m);
          count++;
        }
      }
      _snack('$count medicine reminder${count == 1 ? '' : 's'} enabled');
    }
  }

  Future<void> _toggleAppointmentNotifs(bool value) async {
    setState(() => _appointmentNotifs = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAppointment, value);

    await _ensureDataLoaded();
    final ns = NotificationService();

    if (!value) {
      final doctors = context.read<DoctorProvider>().doctors;
      for (final d in doctors) {
        await ns.cancelAppointmentReminder(d);
      }
      _snack('Appointment reminders disabled');
    } else {
      final upcoming = context.read<DoctorProvider>().upcomingDoctors;
      int count = 0;
      for (final d in upcoming) {
        await ns.scheduleAppointmentReminder(d);
        count++;
      }
      _snack('$count appointment reminder${count == 1 ? '' : 's'} enabled');
    }
  }

  Future<void> _ensureDataLoaded() async {
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    final mp = context.read<MedicineProvider>();
    final dp = context.read<DoctorProvider>();
    if (mp.medicines.isEmpty) await mp.getMedicines(uid);
    if (dp.doctors.isEmpty) await dp.getDoctors(uid);
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.mediumSpace),

              // ── Header ──
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.profile),
                    icon: const Icon(Icons.arrow_back_ios),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(width: r.wp(2)),
                  Text('Settings', style: AppTextStyles.heading2),
                ],
              ),

              SizedBox(height: r.largeSpace),

              // ── Appearance ──
              Text('Appearance', style: AppTextStyles.heading3),
              SizedBox(height: r.mediumSpace),
              CustomCard(
                child: _buildSettingRow(
                  r,
                  icon: themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  iconColor: AppColors.primary,
                  title: 'Dark Mode',
                  subtitle: themeProvider.isDarkMode
                      ? 'Dark theme is active'
                      : 'Light theme is active',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: AppColors.primary,
                  ),
                ),
              ),

              SizedBox(height: r.largeSpace),

              // ── Notifications ──
              Text('Notifications', style: AppTextStyles.heading3),
              SizedBox(height: r.mediumSpace),
              CustomCard(
                child: Column(
                  children: [
                    _buildSettingRow(
                      r,
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.secondary,
                      title: 'Medicine Reminders',
                      subtitle: _medicineNotifs
                          ? 'You will be notified for medicines'
                          : 'Medicine reminders are off',
                      trailing: Switch(
                        value: _medicineNotifs,
                        onChanged: _toggleMedicineNotifs,
                        activeColor: AppColors.primary,
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: const Color(0xFF9E9EAA).withOpacity(0.1),
                    ),
                    _buildSettingRow(
                      r,
                      icon: Icons.calendar_month_outlined,
                      iconColor: AppColors.success,
                      title: 'Appointment Reminders',
                      subtitle: _appointmentNotifs
                          ? 'You will be notified for appointments'
                          : 'Appointment reminders are off',
                      trailing: Switch(
                        value: _appointmentNotifs,
                        onChanged: _toggleAppointmentNotifs,
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: r.largeSpace),

              // ── Data ──
              Text('Data', style: AppTextStyles.heading3),
              SizedBox(height: r.mediumSpace),
              CustomCard(
                child: _buildSettingRow(
                  r,
                  icon: Icons.storage_outlined,
                  iconColor: AppColors.warning,
                  title: 'Clear Cache',
                  subtitle: 'Clear locally stored data',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: r.wp(3.5),
                    color: const Color(0xFF9E9EAA),
                  ),
                  onTap: () => _showClearCacheDialog(),
                ),
              ),

              SizedBox(height: r.largeSpace),

              // ── About ──
              Text('About', style: AppTextStyles.heading3),
              SizedBox(height: r.mediumSpace),
              CustomCard(
                child: Column(
                  children: [
                    _buildSettingRow(
                      r,
                      icon: Icons.info_outline,
                      iconColor: AppColors.secondary,
                      title: 'App Version',
                      subtitle: 'MediTrack v1.0.0',
                      trailing: const SizedBox(),
                    ),
                    Divider(
                      height: 1,
                      color: const Color(0xFF9E9EAA).withOpacity(0.1),
                    ),
                    _buildSettingRow(
                      r,
                      icon: Icons.privacy_tip_outlined,
                      iconColor: AppColors.success,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: r.wp(3.5),
                        color: const Color(0xFF9E9EAA),
                      ),
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      color: const Color(0xFF9E9EAA).withOpacity(0.1),
                    ),
                    _buildSettingRow(
                      r,
                      icon: Icons.description_outlined,
                      iconColor: AppColors.warning,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms',
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: r.wp(3.5),
                        color: const Color(0xFF9E9EAA),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              SizedBox(height: r.largeSpace),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    ResponsiveHelper r, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(r.mediumRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: r.hp(1.5)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.wp(2)),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.smallRadius),
              ),
              child: Icon(icon, color: iconColor, size: r.smallIcon),
            ),
            SizedBox(width: r.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear Cache', style: AppTextStyles.heading3),
        content: Text(
          'This will clear all locally stored data. Your cloud data will not be affected.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF9E9EAA),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _snack('Cache cleared successfully');
            },
            child: Text(
              'Clear',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
