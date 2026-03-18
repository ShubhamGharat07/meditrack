// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/constants/app_text_style.dart';
// import '../../services/notification/notification_service.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key});

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   List<PendingNotificationRequest> _medicineNotifs = [];
//   List<PendingNotificationRequest> _appointmentNotifs = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//   }

//   // ─────────────────────────────────────
//   // LOAD PENDING NOTIFICATIONS
//   // ─────────────────────────────────────

//   Future<void> _loadNotifications() async {
//     setState(() => _isLoading = true);

//     // NotificationService se pending notifications fetch karo
//     final plugin = FlutterLocalNotificationsPlugin();
//     final pending = await plugin.pendingNotificationRequests();

//     // Medicine vs Appointment alag karo by title
//     final medicines = pending
//         .where(
//           (n) =>
//               n.title?.contains('Medicine') == true ||
//               n.title?.contains('💊') == true,
//         )
//         .toList();

//     final appointments = pending
//         .where(
//           (n) =>
//               n.title?.contains('Appointment') == true ||
//               n.title?.contains('🏥') == true,
//         )
//         .toList();

//     if (mounted) {
//       setState(() {
//         _medicineNotifs = medicines;
//         _appointmentNotifs = appointments;
//         _isLoading = false;
//       });
//     }
//   }

//   // ─────────────────────────────────────
//   // CANCEL ONE NOTIFICATION
//   // ─────────────────────────────────────

//   Future<void> _cancelNotification(int id) async {
//     await NotificationService().cancelNotification(id);
//     await _loadNotifications(); // Refresh
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Notification cancelled'),
//           backgroundColor: AppColors.success,
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   // ─────────────────────────────────────
//   // CANCEL ALL NOTIFICATIONS
//   // ─────────────────────────────────────

//   Future<void> _cancelAll() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Cancel All?', style: AppTextStyles.heading3),
//         content: Text(
//           'Sab notifications cancel ho jaayengi. Medicines aur appointments ke reminders band ho jaayenge.',
//           style: AppTextStyles.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: Text(
//               'Yes, Cancel All',
//               style: TextStyle(color: AppColors.error),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       await NotificationService().cancelAllNotifications();
//       await _loadNotifications();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('All notifications cancelled'),
//             backgroundColor: AppColors.warning,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final total = _medicineNotifs.length + _appointmentNotifs.length;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.surface,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text('Notifications', style: AppTextStyles.heading3),
//         actions: [
//           if (total > 0)
//             TextButton(
//               onPressed: _cancelAll,
//               child: Text(
//                 'Clear All',
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: AppColors.error,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: AppColors.primary),
//             )
//           : total == 0
//           ? _buildEmptyState()
//           : RefreshIndicator(
//               onRefresh: _loadNotifications,
//               color: AppColors.primary,
//               child: ListView(
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   // ── Summary Card ──
//                   _buildSummaryCard(total),

//                   const SizedBox(height: 20),

//                   // ── Medicine Reminders ──
//                   if (_medicineNotifs.isNotEmpty) ...[
//                     _buildSectionHeader(
//                       '💊 Medicine Reminders',
//                       _medicineNotifs.length,
//                       AppColors.primary,
//                     ),
//                     const SizedBox(height: 8),
//                     ..._medicineNotifs.map(
//                       (n) => _buildNotifCard(
//                         n,
//                         AppColors.primary,
//                         Icons.medication,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],

//                   // ── Appointment Reminders ──
//                   if (_appointmentNotifs.isNotEmpty) ...[
//                     _buildSectionHeader(
//                       '🏥 Appointment Reminders',
//                       _appointmentNotifs.length,
//                       AppColors.secondary,
//                     ),
//                     const SizedBox(height: 8),
//                     ..._appointmentNotifs.map(
//                       (n) => _buildNotifCard(
//                         n,
//                         AppColors.secondary,
//                         Icons.calendar_month,
//                       ),
//                     ),
//                   ],

//                   const SizedBox(height: 20),

//                   // ── Info Banner ──
//                   // _buildInfoBanner(),
//                 ],
//               ),
//             ),
//     );
//   }

//   // ─────────────────────────────────────
//   // SUMMARY CARD
//   // ─────────────────────────────────────

//   Widget _buildSummaryCard(int total) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [AppColors.primary, AppColors.primaryLight],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.notifications_active,
//               color: Colors.white,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '$total Active Reminders',
//                   style: AppTextStyles.heading3.copyWith(color: Colors.white),
//                 ),
//                 Text(
//                   '${_medicineNotifs.length} medicine • ${_appointmentNotifs.length} appointment',
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: Colors.white.withOpacity(0.85),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────
//   // SECTION HEADER
//   // ─────────────────────────────────────

//   Widget _buildSectionHeader(String title, int count, Color color) {
//     return Row(
//       children: [
//         Text(
//           title,
//           style: AppTextStyles.bodyMedium.copyWith(
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '$count',
//             style: AppTextStyles.bodySmall.copyWith(
//               color: color,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────
//   // NOTIFICATION CARD
//   // ─────────────────────────────────────

//   Widget _buildNotifCard(
//     PendingNotificationRequest notif,
//     Color color,
//     IconData icon,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: color, size: 22),
//         ),
//         title: Text(
//           notif.title ?? 'Reminder',
//           style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Text(
//             notif.body ?? '',
//             style: AppTextStyles.bodySmall,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         trailing: IconButton(
//           icon: Icon(Icons.close, color: AppColors.error, size: 20),
//           tooltip: 'Cancel this reminder',
//           onPressed: () => _cancelNotification(notif.id),
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────
//   // EMPTY STATE
//   // ─────────────────────────────────────

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.08),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.notifications_off_outlined,
//                 size: 60,
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text('No Active Reminders', style: AppTextStyles.heading3),
//             const SizedBox(height: 8),
//             Text(
//               'Medicines ya doctors add karo\nreminders automatically set honge!',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────
//   // INFO BANNER
//   // ─────────────────────────────────────

//   // Widget _buildInfoBanner() {
//   //   return Container(
//   //     padding: const EdgeInsets.all(12),
//   //     decoration: BoxDecoration(
//   //       color: AppColors.info.withOpacity(0.08),
//   //       borderRadius: BorderRadius.circular(10),
//   //       border: Border.all(color: AppColors.info.withOpacity(0.2)),
//   //     ),
//   //     child: Row(
//   //       children: [
//   //         const Icon(Icons.info_outline, color: AppColors.info, size: 18),
//   //         const SizedBox(width: 10),
//   //         // Expanded(
//   //         //   child: Text(
//   //         //     '',
//   //         //     style: AppTextStyles.caption.copyWith(color: AppColors.info),
//   //         //   ),
//   //         // ),
//   //       ],
//   //     ),
//   //   );
//   // }
// }

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../services/notification/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<PendingNotificationRequest> _medicineNotifs = [];
  List<PendingNotificationRequest> _appointmentNotifs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ─────────────────────────────────────
  // LOAD PENDING NOTIFICATIONS
  // ─────────────────────────────────────

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    // Fetch pending notifications from NotificationService
    final plugin = FlutterLocalNotificationsPlugin();
    final pending = await plugin.pendingNotificationRequests();

    // Separate Medicine and Appointment notifications by title
    final medicines = pending
        .where(
          (n) =>
              n.title?.contains('Medicine') == true ||
              n.title?.contains('💊') == true,
        )
        .toList();

    final appointments = pending
        .where(
          (n) =>
              n.title?.contains('Appointment') == true ||
              n.title?.contains('🏥') == true,
        )
        .toList();

    if (mounted) {
      setState(() {
        _medicineNotifs = medicines;
        _appointmentNotifs = appointments;
        _isLoading = false;
      });
    }
  }

  // ─────────────────────────────────────
  // CANCEL ONE NOTIFICATION
  // ─────────────────────────────────────

  Future<void> _cancelNotification(int id) async {
    await NotificationService().cancelNotification(id);
    await _loadNotifications(); // Refresh
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification cancelled'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ─────────────────────────────────────
  // CANCEL ALL NOTIFICATIONS
  // ─────────────────────────────────────

  Future<void> _cancelAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancel All?', style: AppTextStyles.heading3),
        content: Text(
          'All notifications will be cancelled. Medicine and appointment reminders will be turned off.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Yes, Cancel All',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await NotificationService().cancelAllNotifications();
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cancelled'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _medicineNotifs.length + _appointmentNotifs.length;

    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: AppTextStyles.heading3),
        actions: [
          if (total > 0)
            TextButton(
              onPressed: _cancelAll,
              child: Text(
                'Clear All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : total == 0
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Summary Card ──
                  _buildSummaryCard(total),

                  const SizedBox(height: 20),

                  // ── Medicine Reminders ──
                  if (_medicineNotifs.isNotEmpty) ...[
                    _buildSectionHeader(
                      '💊 Medicine Reminders',
                      _medicineNotifs.length,
                      AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    ..._medicineNotifs.map(
                      (n) => _buildNotifCard(
                        n,
                        AppColors.primary,
                        Icons.medication,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Appointment Reminders ──
                  if (_appointmentNotifs.isNotEmpty) ...[
                    _buildSectionHeader(
                      '🏥 Appointment Reminders',
                      _appointmentNotifs.length,
                      AppColors.secondary,
                    ),
                    const SizedBox(height: 8),
                    ..._appointmentNotifs.map(
                      (n) => _buildNotifCard(
                        n,
                        AppColors.secondary,
                        Icons.calendar_month,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Info Banner ──
                  // _buildInfoBanner(),
                ],
              ),
            ),
    );
  }

  // ─────────────────────────────────────
  // SUMMARY CARD
  // ─────────────────────────────────────

  Widget _buildSummaryCard(int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total Active Reminders',
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                ),
                Text(
                  '${_medicineNotifs.length} medicine • ${_appointmentNotifs.length} appointment',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // SECTION HEADER
  // ─────────────────────────────────────

  Widget _buildSectionHeader(String title, int count, Color color) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // NOTIFICATION CARD
  // ─────────────────────────────────────

  Widget _buildNotifCard(
    PendingNotificationRequest notif,
    Color color,
    IconData icon,
  ) {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          notif.title ?? 'Reminder',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            notif.body ?? '',
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.close, color: AppColors.error, size: 20),
          tooltip: 'Cancel this reminder',
          onPressed: () => _cancelNotification(notif.id),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────

  Widget _buildEmptyState() {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text('No Active Reminders', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Add medicines or doctors\nto automatically set reminders!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // INFO BANNER
  // ─────────────────────────────────────

  // Widget _buildInfoBanner() {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: AppColors.info.withOpacity(0.08),
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: AppColors.info.withOpacity(0.2)),
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(Icons.info_outline, color: AppColors.info, size: 18),
  //         const SizedBox(width: 10),
  //         // Expanded(
  //         //   child: Text(
  //         //     '',
  //         //     style: AppTextStyles.caption.copyWith(color: AppColors.info),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }
}
