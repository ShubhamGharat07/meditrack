// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:meditrack/core/constants/app_text_style.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/responsive_helper.dart';
// import '../../models/medicine_model.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/medicine_provider.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/common/custom_card.dart';
// import '../../widgets/common/empty_state.dart';
// import '../../widgets/common/loading_indicator.dart';
// import '../../widgets/common/section_header.dart';

// class MedicineListScreen extends StatefulWidget {
//   const MedicineListScreen({super.key});

//   @override
//   State<MedicineListScreen> createState() => _MedicineListScreenState();
// }

// class _MedicineListScreenState extends State<MedicineListScreen> {
//   final _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => _loadMedicines());
//   }

//   Future<void> _loadMedicines() async {
//     final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
//     if (userId.isEmpty) return;
//     await context.read<MedicineProvider>().getMedicines(userId);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   bool _isCompleted(MedicineModel medicine) {
//     if (medicine.endDate == null) return false;
//     return medicine.endDate!.isBefore(DateTime.now());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);
//     final medicines = context.watch<MedicineProvider>();

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

//                   // Title + Add button
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Medicines', style: AppTextStyles.heading2),
//                       IconButton(
//                         onPressed: () => context.go(AppRoutes.addMedicine),
//                         icon: Container(
//                           padding: EdgeInsets.all(r.wp(2)),
//                           decoration: BoxDecoration(
//                             color: AppColors.primary,
//                             borderRadius: BorderRadius.circular(r.mediumRadius),
//                           ),
//                           child: Icon(
//                             Icons.add,
//                             color: AppColors.textWhite,
//                             size: r.smallIcon,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: r.mediumSpace),

//                   // Search bar
//                   TextField(
//                     controller: _searchController,
//                     onChanged: (value) => medicines.setSearchQuery(value),
//                     decoration: InputDecoration(
//                       hintText: 'Search medicines...',
//                       prefixIcon: Icon(
//                         Icons.search,
//                         size: r.smallIcon,
//                         color: Theme.of(context).colorScheme.onSurfaceVariant,
//                       ),
//                       suffixIcon: _searchController.text.isNotEmpty
//                           ? IconButton(
//                               icon: Icon(Icons.clear, size: r.smallIcon),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 medicines.setSearchQuery('');
//                               },
//                             )
//                           : null,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(r.mediumRadius),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Theme.of(context).cardColor,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: r.wp(4),
//                         vertical: r.hp(1.5),
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: r.mediumSpace),

//                   // Filter chips
//                   _buildFilterChips(r, medicines),
//                 ],
//               ),
//             ),

//             // Medicine list
//             Expanded(
//               child: medicines.isLoading
//                   ? const LoadingIndicator()
//                   : medicines.filteredMedicines.isEmpty
//                   ? EmptyState(
//                       message: 'No medicines found!',
//                       icon: Icons.medication_outlined,
//                       buttonText: 'Add Medicine',
//                       onButtonTap: () => context.go(AppRoutes.addMedicine),
//                     )
//                   : RefreshIndicator(
//                       onRefresh: _loadMedicines,
//                       child: ListView.builder(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: r.wp(6),
//                           vertical: r.hp(1),
//                         ),
//                         itemCount: medicines.filteredMedicines.length,
//                         itemBuilder: (context, index) {
//                           final medicine = medicines.filteredMedicines[index];
//                           final completed = _isCompleted(medicine);

//                           return Padding(
//                             padding: EdgeInsets.only(bottom: r.smallSpace),
//                             child: CustomCard(
//                               onTap: () => context.go(
//                                 '/medicines/detail/${medicine.id}',
//                               ),
//                               child: Row(
//                                 children: [
//                                   // Priority icon
//                                   Container(
//                                     padding: EdgeInsets.all(r.wp(3)),
//                                     decoration: BoxDecoration(
//                                       color: _priorityColor(
//                                         medicine.priority,
//                                       ).withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(
//                                         r.smallRadius,
//                                       ),
//                                     ),
//                                     child: Icon(
//                                       Icons.medication,
//                                       color: _priorityColor(medicine.priority),
//                                       size: r.smallIcon,
//                                     ),
//                                   ),

//                                   SizedBox(width: r.wp(3)),

//                                   // Medicine info
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           medicine.name,
//                                           style: AppTextStyles.bodyMedium
//                                               .copyWith(
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                         ),
//                                         SizedBox(height: r.hp(0.3)),
//                                         Text(
//                                           '${medicine.dosage} • ${medicine.type}',
//                                           style: AppTextStyles.bodySmall
//                                               .copyWith(
//                                                 color: Theme.of(
//                                                   context,
//                                                 ).colorScheme.onSurfaceVariant,
//                                               ),
//                                         ),
//                                         SizedBox(height: r.hp(0.3)),
//                                         Text(
//                                           medicine.frequency,
//                                           style: AppTextStyles.bodySmall
//                                               .copyWith(
//                                                 color: AppColors.primary,
//                                               ),
//                                         ),
//                                         // ── COMPLETED CHIP ──
//                                         if (completed) ...[
//                                           SizedBox(height: r.hp(0.3)),
//                                           Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.check_circle_outline,
//                                                 size: r.wp(3),
//                                                 color: AppColors.success,
//                                               ),
//                                               SizedBox(width: r.wp(1)),
//                                               Text(
//                                                 'Completed',
//                                                 style: AppTextStyles.bodySmall
//                                                     .copyWith(
//                                                       color: AppColors.success,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       fontSize: r.sp(10),
//                                                     ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),

//                                   // Priority badge + Arrow
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: r.wp(2),
//                                           vertical: r.hp(0.3),
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: _priorityColor(
//                                             medicine.priority,
//                                           ).withOpacity(0.1),
//                                           borderRadius: BorderRadius.circular(
//                                             r.smallRadius,
//                                           ),
//                                         ),
//                                         child: Text(
//                                           medicine.priority,
//                                           style: AppTextStyles.bodySmall
//                                               .copyWith(
//                                                 color: _priorityColor(
//                                                   medicine.priority,
//                                                 ),
//                                                 fontSize: r.sp(10),
//                                               ),
//                                         ),
//                                       ),
//                                       SizedBox(height: r.hp(0.5)),
//                                       Icon(
//                                         Icons.arrow_forward_ios,
//                                         size: r.wp(3),
//                                         color: Theme.of(
//                                           context,
//                                         ).colorScheme.onSurfaceVariant,
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),

//       // FAB
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => context.go(AppRoutes.addMedicine),
//         backgroundColor: AppColors.primary,
//         child: Icon(Icons.add, color: AppColors.textWhite, size: r.mediumIcon),
//       ),
//     );
//   }

//   Widget _buildFilterChips(ResponsiveHelper r, MedicineProvider medicines) {
//     final filters = ['All', 'Active', 'Completed'];

//     return Row(
//       children: filters.map((filter) {
//         final isSelected = medicines.selectedFilter == filter;
//         return Padding(
//           padding: EdgeInsets.only(right: r.wp(2)),
//           child: GestureDetector(
//             onTap: () => medicines.setFilter(filter),
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: r.wp(4),
//                 vertical: r.hp(0.8),
//               ),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? AppColors.primary
//                     : Theme.of(context).cardColor,
//                 borderRadius: BorderRadius.circular(r.largeRadius),
//                 border: Border.all(
//                   color: isSelected
//                       ? AppColors.primary
//                       : Theme.of(
//                           context,
//                         ).colorScheme.onSurfaceVariant.withOpacity(0.3),
//                 ),
//               ),
//               child: Text(
//                 filter,
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: isSelected
//                       ? AppColors.textWhite
//                       : Theme.of(context).colorScheme.onSurfaceVariant,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
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
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/section_header.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadMedicines());
  }

  Future<void> _loadMedicines() async {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (userId.isEmpty) return;
    await context.read<MedicineProvider>().getMedicines(userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isCompleted(MedicineModel medicine) {
    if (medicine.endDate == null) return false;
    return medicine.endDate!.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final medicines = context.watch<MedicineProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: r.pagePadding,
              child: Column(
                children: [
                  SizedBox(height: r.mediumSpace),

                  // Title + Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Medicines', style: AppTextStyles.heading2),
                      IconButton(
                        onPressed: () => context.go(AppRoutes.addMedicine),
                        icon: Container(
                          padding: EdgeInsets.all(r.wp(2)),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(r.mediumRadius),
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppColors.textWhite,
                            size: r.smallIcon,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: r.mediumSpace),

                  // Search bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => medicines.setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Search medicines...',
                      prefixIcon: Icon(
                        Icons.search,
                        size: r.smallIcon,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: r.smallIcon),
                              onPressed: () {
                                _searchController.clear();
                                medicines.setSearchQuery('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: r.wp(4),
                        vertical: r.hp(1.5),
                      ),
                    ),
                  ),

                  SizedBox(height: r.mediumSpace),

                  // Filter chips
                  _buildFilterChips(r, medicines),
                ],
              ),
            ),

            // Medicine list
            Expanded(
              child: medicines.isLoading
                  ? const LoadingIndicator()
                  : medicines.filteredMedicines.isEmpty
                  ? EmptyState(
                      message: 'No medicines found!',
                      icon: Icons.medication_outlined,
                      buttonText: 'Add Medicine',
                      onButtonTap: () => context.go(AppRoutes.addMedicine),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMedicines,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.wp(6),
                          vertical: r.hp(1),
                        ),
                        itemCount: medicines.filteredMedicines.length,
                        itemBuilder: (context, index) {
                          final medicine = medicines.filteredMedicines[index];
                          final completed = _isCompleted(medicine);

                          return Padding(
                            padding: EdgeInsets.only(bottom: r.smallSpace),
                            child: CustomCard(
                              onTap: () => context.push(
                                '/medicines/detail/${medicine.id}',
                              ),
                              child: Row(
                                children: [
                                  // Priority icon
                                  Container(
                                    padding: EdgeInsets.all(r.wp(3)),
                                    decoration: BoxDecoration(
                                      color: _priorityColor(
                                        medicine.priority,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        r.smallRadius,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.medication,
                                      color: _priorityColor(medicine.priority),
                                      size: r.smallIcon,
                                    ),
                                  ),

                                  SizedBox(width: r.wp(3)),

                                  // Medicine info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          medicine.name,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        SizedBox(height: r.hp(0.3)),
                                        Text(
                                          '${medicine.dosage} • ${medicine.type}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                        SizedBox(height: r.hp(0.3)),
                                        Text(
                                          medicine.frequency,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.primary,
                                              ),
                                        ),
                                        // ── COMPLETED CHIP ──
                                        if (completed) ...[
                                          SizedBox(height: r.hp(0.3)),
                                          Row(
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: r.sp(10),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Priority badge + Arrow
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: r.wp(2),
                                          vertical: r.hp(0.3),
                                        ),
                                        decoration: BoxDecoration(
                                          color: _priorityColor(
                                            medicine.priority,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            r.smallRadius,
                                          ),
                                        ),
                                        child: Text(
                                          medicine.priority,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: _priorityColor(
                                                  medicine.priority,
                                                ),
                                                fontSize: r.sp(10),
                                              ),
                                        ),
                                      ),
                                      SizedBox(height: r.hp(0.5)),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: r.wp(3),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.addMedicine),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: AppColors.textWhite, size: r.mediumIcon),
      ),
    );
  }

  Widget _buildFilterChips(ResponsiveHelper r, MedicineProvider medicines) {
    final filters = ['All', 'Active', 'Completed'];

    return Row(
      children: filters.map((filter) {
        final isSelected = medicines.selectedFilter == filter;
        return Padding(
          padding: EdgeInsets.only(right: r.wp(2)),
          child: GestureDetector(
            onTap: () => medicines.setFilter(filter),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.wp(4),
                vertical: r.hp(0.8),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(r.largeRadius),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
              ),
              child: Text(
                filter,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.textWhite
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
