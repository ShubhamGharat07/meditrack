// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:meditrack/core/constants/app_text_style.dart';
// import 'package:path/path.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/responsive_helper.dart';
// import '../../models/medicine_model.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/medicine_provider.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/common/custom_card.dart';
// import '../../widgets/common/custom_button.dart';

// class MedicineDetailScreen extends StatelessWidget {
//   final String medicineId;

//   const MedicineDetailScreen({super.key, required this.medicineId});

//   // Medicine complete hua ya nahi
//   bool _isCompleted(MedicineModel medicine) {
//     if (medicine.endDate == null) return false;
//     return medicine.endDate!.isBefore(DateTime.now());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);
//     final medicines = context.watch<MedicineProvider>();

//     final medicine = medicines.medicines.firstWhere(
//       (m) => m.id == medicineId,
//       orElse: () => MedicineModel(
//         id: '',
//         userId: '',
//         name: 'Not Found',
//         dosage: '',
//         type: '',
//         frequency: '',
//         startDate: DateTime.now(),
//         reminderTimes: [],
//         priority: 'Low',
//         isSynced: false,
//         createdAt: DateTime.now(),
//       ),
//     );

//     if (medicine.id.isEmpty) {
//       return Scaffold(
//         body: Center(
//           child: Text('Medicine not found!', style: AppTextStyles.bodyMedium),
//         ),
//       );
//     }

//     final completed = _isCompleted(medicine);

//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Padding(
//               padding: r.pagePadding,
//               child: Column(
//                 children: [
//                   SizedBox(height: r.mediumSpace),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         onPressed: () => context.go(AppRoutes.medicines),
//                         icon: const Icon(Icons.arrow_back_ios),
//                         padding: EdgeInsets.zero,
//                       ),
//                       Text('Medicine Detail', style: AppTextStyles.heading2),
//                       IconButton(
//                         onPressed: () => _confirmDelete(context, r, medicine),
//                         icon: Icon(
//                           Icons.delete_outline,
//                           color: AppColors.error,
//                           size: r.mediumIcon,
//                         ),
//                         padding: EdgeInsets.zero,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: r.pagePadding,
//                 child: Column(
//                   children: [
//                     // Medicine hero card
//                     CustomCard(
//                       color: _priorityColor(medicine.priority).withOpacity(0.1),
//                       hasShadow: false,
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(r.wp(4)),
//                             decoration: BoxDecoration(
//                               color: _priorityColor(
//                                 medicine.priority,
//                               ).withOpacity(0.2),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.medication,
//                               size: r.largeIcon,
//                               color: _priorityColor(medicine.priority),
//                             ),
//                           ),
//                           SizedBox(width: r.wp(4)),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   medicine.name,
//                                   style: AppTextStyles.heading2,
//                                 ),
//                                 SizedBox(height: r.hp(0.5)),
//                                 Text(
//                                   medicine.dosage,
//                                   style: AppTextStyles.bodyMedium.copyWith(
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.onSurfaceVariant,
//                                   ),
//                                 ),
//                                 SizedBox(height: r.hp(0.5)),
//                                 // Priority badge + Completed badge ek saath
//                                 Row(
//                                   children: [
//                                     Container(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: r.wp(3),
//                                         vertical: r.hp(0.3),
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: _priorityColor(
//                                           medicine.priority,
//                                         ).withOpacity(0.2),
//                                         borderRadius: BorderRadius.circular(
//                                           r.smallRadius,
//                                         ),
//                                       ),
//                                       child: Text(
//                                         medicine.priority,
//                                         style: AppTextStyles.bodySmall.copyWith(
//                                           color: _priorityColor(
//                                             medicine.priority,
//                                           ),
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//                                     // ── COMPLETED BADGE ──
//                                     if (completed) ...[
//                                       SizedBox(width: r.wp(2)),
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: r.wp(3),
//                                           vertical: r.hp(0.3),
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: AppColors.success.withOpacity(
//                                             0.15,
//                                           ),
//                                           borderRadius: BorderRadius.circular(
//                                             r.smallRadius,
//                                           ),
//                                         ),
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               Icons.check_circle_outline,
//                                               size: r.wp(3),
//                                               color: AppColors.success,
//                                             ),
//                                             SizedBox(width: r.wp(1)),
//                                             Text(
//                                               'Completed',
//                                               style: AppTextStyles.bodySmall
//                                                   .copyWith(
//                                                     color: AppColors.success,
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(height: r.mediumSpace),

//                     // Details card
//                     CustomCard(
//                       child: Column(
//                         children: [
//                           _buildDetailRow(
//                             r,
//                             icon: Icons.category_outlined,
//                             label: 'Type',
//                             value: medicine.type,
//                           ),
//                           _buildDivider(),
//                           _buildDetailRow(
//                             r,
//                             icon: Icons.repeat,
//                             label: 'Frequency',
//                             value: medicine.frequency,
//                           ),
//                           _buildDivider(),
//                           _buildDetailRow(
//                             r,
//                             icon: Icons.calendar_today,
//                             label: 'Start Date',
//                             value:
//                                 '${medicine.startDate.day}/${medicine.startDate.month}/${medicine.startDate.year}',
//                           ),
//                           if (medicine.endDate != null) ...[
//                             _buildDivider(),
//                             _buildDetailRow(
//                               r,
//                               icon: Icons.event,
//                               label: 'End Date',
//                               value:
//                                   '${medicine.endDate!.day}/${medicine.endDate!.month}/${medicine.endDate!.year}',
//                               // End date red dikhao agar complete hua
//                               valueColor: completed ? AppColors.success : null,
//                             ),
//                           ],
//                           // ── SYNC STATUS COMMENTED OUT ──
//                           // _buildDivider(),
//                           // _buildDetailRow(
//                           //   r,
//                           //   icon: Icons.cloud_done_outlined,
//                           //   label: 'Sync Status',
//                           //   value: medicine.isSynced ? 'Synced' : 'Pending sync',
//                           //   valueColor: medicine.isSynced
//                           //       ? AppColors.success
//                           //       : AppColors.warning,
//                           // ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(height: r.mediumSpace),

//                     // Reminder times card
//                     CustomCard(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.alarm,
//                                 size: r.smallIcon,
//                                 color: AppColors.primary,
//                               ),
//                               SizedBox(width: r.wp(2)),
//                               Text(
//                                 'Reminder Times',
//                                 style: AppTextStyles.heading3,
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: r.mediumSpace),
//                           Wrap(
//                             spacing: r.wp(2),
//                             runSpacing: r.hp(0.5),
//                             children: medicine.reminderTimes.map((time) {
//                               return Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: r.wp(3),
//                                   vertical: r.hp(0.8),
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.primary.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(
//                                     r.smallRadius,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.access_time,
//                                       size: r.wp(3.5),
//                                       color: AppColors.primary,
//                                     ),
//                                     SizedBox(width: r.wp(1)),
//                                     Text(
//                                       time,
//                                       style: AppTextStyles.bodySmall.copyWith(
//                                         color: AppColors.primary,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Notes card
//                     if (medicine.notes != null &&
//                         medicine.notes!.isNotEmpty) ...[
//                       SizedBox(height: r.mediumSpace),
//                       CustomCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.notes,
//                                   size: r.smallIcon,
//                                   color: AppColors.primary,
//                                 ),
//                                 SizedBox(width: r.wp(2)),
//                                 Text('Notes', style: AppTextStyles.heading3),
//                               ],
//                             ),
//                             SizedBox(height: r.smallSpace),
//                             Text(
//                               medicine.notes!,
//                               style: AppTextStyles.bodyMedium.copyWith(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onSurfaceVariant,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],

//                     SizedBox(height: r.largeSpace),

//                     // Delete button
//                     CustomButton(
//                       text: 'Delete Medicine',
//                       onPressed: () => _confirmDelete(context, r, medicine),
//                       color: AppColors.error,
//                       icon: Icons.delete_outline,
//                     ),

//                     SizedBox(height: r.largeSpace),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(
//     ResponsiveHelper r, {
//     required IconData icon,
//     required String label,
//     required String value,
//     Color? valueColor,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: r.hp(1)),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: r.smallIcon,
//             color: Theme.of(
//               context as BuildContext,
//             ).colorScheme.onSurfaceVariant,
//           ),
//           SizedBox(width: r.wp(3)),
//           Expanded(
//             child: Text(
//               label,
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: Theme.of(
//                   context as BuildContext,
//                 ).colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: AppTextStyles.bodyMedium.copyWith(
//               fontWeight: FontWeight.w600,
//               color:
//                   valueColor ??
//                   Theme.of(context as BuildContext).colorScheme.onSurface,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDivider() => const Divider(height: 1);

//   void _confirmDelete(
//     BuildContext context,
//     ResponsiveHelper r,
//     MedicineModel medicine,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Medicine', style: AppTextStyles.heading3),
//         content: Text(
//           'Are you sure you want to delete ${medicine.name}?',
//           style: AppTextStyles.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               final userId =
//                   context.read<AuthProvider>().currentUser?.uid ?? '';
//               await context.read<MedicineProvider>().deleteMedicine(
//                 userId,
//                 medicine.id,
//               );
//               if (context.mounted) context.go(AppRoutes.medicines);
//             },
//             child: Text(
//               'Delete',
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

//   Color _priorityColor(String priority) {
//     switch (priority.toLowerCase()) {
//       case 'high':
//         return AppColors.error;
//       case 'medium':
//         return AppColors.warning;
//       default:
//         return AppColors.success;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/medicine_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_button.dart';

class MedicineDetailScreen extends StatefulWidget {
  final String medicineId;

  const MedicineDetailScreen({super.key, required this.medicineId});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load medicines if they are not already loaded
    Future.microtask(() async {
      final provider = context.read<MedicineProvider>();
      if (provider.medicines.isEmpty) {
        final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
        if (userId.isNotEmpty) {
          await provider.getMedicines(userId);
        }
      }
    });
  }

  bool _isCompleted(MedicineModel medicine) {
    if (medicine.endDate == null) return false;
    return medicine.endDate!.isBefore(DateTime.now());
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

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final medicines = context.watch<MedicineProvider>();

    // Loading state
    if (medicines.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final medicine = medicines.medicines.firstWhere(
      (m) => m.id == widget.medicineId,
      orElse: () => MedicineModel(
        id: '',
        userId: '',
        name: '',
        dosage: '',
        type: '',
        frequency: '',
        startDate: DateTime.now(),
        reminderTimes: [],
        priority: 'Low',
        isSynced: false,
        createdAt: DateTime.now(),
      ),
    );

    if (medicine.id.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.medication_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text('Medicine not found!', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(AppRoutes.medicines),
                child: const Text('Back to Medicines'),
              ),
            ],
          ),
        ),
      );
    }

    final completed = _isCompleted(medicine);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: r.pagePadding,
              child: Column(
                children: [
                  SizedBox(height: r.mediumSpace),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go(AppRoutes.medicines),
                        icon: const Icon(Icons.arrow_back_ios),
                        padding: EdgeInsets.zero,
                      ),
                      Text('Medicine Detail', style: AppTextStyles.heading2),
                      IconButton(
                        onPressed: () => _confirmDelete(medicine),
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: r.mediumIcon,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: r.pagePadding,
                child: Column(
                  children: [
                    // Medicine hero card
                    CustomCard(
                      color: _priorityColor(medicine.priority).withOpacity(0.1),
                      hasShadow: false,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(r.wp(4)),
                            decoration: BoxDecoration(
                              color: _priorityColor(
                                medicine.priority,
                              ).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.medication,
                              size: r.largeIcon,
                              color: _priorityColor(medicine.priority),
                            ),
                          ),
                          SizedBox(width: r.wp(4)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicine.name,
                                  style: AppTextStyles.heading2,
                                ),
                                SizedBox(height: r.hp(0.5)),
                                Text(
                                  medicine.dosage,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: r.hp(0.5)),
                                Row(
                                  children: [
                                    // Priority badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: r.wp(3),
                                        vertical: r.hp(0.3),
                                      ),
                                      decoration: BoxDecoration(
                                        color: _priorityColor(
                                          medicine.priority,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          r.smallRadius,
                                        ),
                                      ),
                                      child: Text(
                                        medicine.priority,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: _priorityColor(
                                            medicine.priority,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    // Completed badge
                                    if (completed) ...[
                                      SizedBox(width: r.wp(2)),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: r.wp(3),
                                          vertical: r.hp(0.3),
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withOpacity(
                                            0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            r.smallRadius,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              size: r.wp(3),
                                              color: AppColors.success,
                                            ),
                                            SizedBox(width: r.wp(1)),
                                            Text(
                                              'Completed',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color: AppColors.success,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: r.mediumSpace),

                    // Details card
                    CustomCard(
                      child: Column(
                        children: [
                          _buildDetailRow(
                            r,
                            icon: Icons.category_outlined,
                            label: 'Type',
                            value: medicine.type,
                          ),
                          _buildDivider(),
                          _buildDetailRow(
                            r,
                            icon: Icons.repeat,
                            label: 'Frequency',
                            value: medicine.frequency,
                          ),
                          _buildDivider(),
                          _buildDetailRow(
                            r,
                            icon: Icons.calendar_today,
                            label: 'Start Date',
                            value:
                                '${medicine.startDate.day}/${medicine.startDate.month}/${medicine.startDate.year}',
                          ),
                          if (medicine.endDate != null) ...[
                            _buildDivider(),
                            _buildDetailRow(
                              r,
                              icon: Icons.event,
                              label: 'End Date',
                              value:
                                  '${medicine.endDate!.day}/${medicine.endDate!.month}/${medicine.endDate!.year}',
                              valueColor: completed ? AppColors.success : null,
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: r.mediumSpace),

                    // Reminder times card
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                size: r.smallIcon,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: r.wp(2)),
                              Text(
                                'Reminder Times',
                                style: AppTextStyles.heading3,
                              ),
                            ],
                          ),
                          SizedBox(height: r.mediumSpace),
                          medicine.reminderTimes.isEmpty
                              ? Text(
                                  'No reminders set',
                                  style: AppTextStyles.bodySmall,
                                )
                              : Wrap(
                                  spacing: r.wp(2),
                                  runSpacing: r.hp(0.5),
                                  children: medicine.reminderTimes.map((time) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: r.wp(3),
                                        vertical: r.hp(0.8),
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          r.smallRadius,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: r.wp(3.5),
                                            color: AppColors.primary,
                                          ),
                                          SizedBox(width: r.wp(1)),
                                          Text(
                                            time,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),

                    // Notes card
                    if (medicine.notes != null &&
                        medicine.notes!.isNotEmpty) ...[
                      SizedBox(height: r.mediumSpace),
                      CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notes,
                                  size: r.smallIcon,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: r.wp(2)),
                                Text('Notes', style: AppTextStyles.heading3),
                              ],
                            ),
                            SizedBox(height: r.smallSpace),
                            Text(
                              medicine.notes!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: r.largeSpace),

                    CustomButton(
                      text: 'Delete Medicine',
                      onPressed: () => _confirmDelete(medicine),
                      color: AppColors.error,
                      icon: Icons.delete_outline,
                    ),

                    SizedBox(height: r.largeSpace),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper widgets — context ab seedha available hai ──

  Widget _buildDetailRow(
    ResponsiveHelper r, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.hp(1)),
      child: Row(
        children: [
          Icon(
            icon,
            size: r.smallIcon,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant, // ✅ context directly
          ),
          SizedBox(width: r.wp(3)),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant, // ✅ context directly
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  valueColor ??
                  Theme.of(context).colorScheme.onSurface, // ✅ context directly
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1);

  void _confirmDelete(MedicineModel medicine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Medicine', style: AppTextStyles.heading3),
        content: Text(
          '\'${medicine.name}\' delete karna chahte ho?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final userId =
                  context.read<AuthProvider>().currentUser?.uid ?? '';
              await context.read<MedicineProvider>().deleteMedicine(
                userId,
                medicine.id,
              );
              if (mounted) context.go(AppRoutes.medicines);
            },
            child: Text(
              'Delete',
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
