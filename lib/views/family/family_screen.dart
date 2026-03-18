// import 'package:flutter/material.dart';
// import 'package:meditrack/core/constants/app_text_style.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/responsive_helper.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/family_provider.dart';
// import '../../widgets/common/custom_button.dart';
// import '../../widgets/common/custom_text_field.dart';
// import '../../widgets/common/empty_state.dart';
// import '../../widgets/common/loading_indicator.dart';
// import '../../models/family_member_model.dart';

// class FamilyScreen extends StatefulWidget {
//   const FamilyScreen({super.key});

//   @override
//   State<FamilyScreen> createState() => _FamilyScreenState();
// }

// class _FamilyScreenState extends State<FamilyScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _relationController = TextEditingController();
//   final _ageController = TextEditingController();
//   final _bloodGroupController = TextEditingController();
//   final _allergiesController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => _loadMembers());
//   }

//   Future<void> _loadMembers() async {
//     final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
//     if (userId.isEmpty) return;
//     await context.read<FamilyProvider>().getFamilyMembers(userId);
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _relationController.dispose();
//     _ageController.dispose();
//     _bloodGroupController.dispose();
//     _allergiesController.dispose();
//     super.dispose();
//   }

//   void _showAddMemberSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.background,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (context) => _buildAddMemberSheet(),
//     );
//   }

//   Future<void> _saveMember() async {
//     if (!_formKey.currentState!.validate()) return;

//     final userId = context.read<AuthProvider>().currentUser?.uid ?? '';

//     // Allergies — comma separated string → List
//     final allergiesText = _allergiesController.text.trim();
//     final allergies = allergiesText.isNotEmpty
//         ? allergiesText
//               .split(',')
//               .map((e) => e.trim())
//               .where((e) => e.isNotEmpty)
//               .toList()
//         : null;

//     final success = await context.read<FamilyProvider>().addFamilyMember(
//       userId: userId,
//       name: _nameController.text.trim(),
//       relation: _relationController.text.trim(),
//       age: int.tryParse(_ageController.text.trim()),
//       bloodGroup: _bloodGroupController.text.trim().isEmpty
//           ? null
//           : _bloodGroupController.text.trim(),
//       allergies: allergies,
//     );

//     if (!mounted) return;

//     if (success) {
//       Navigator.pop(context);
//       _nameController.clear();
//       _relationController.clear();
//       _ageController.clear();
//       _bloodGroupController.clear();
//       _allergiesController.clear();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Family member added!'),
//           backgroundColor: AppColors.success,
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(context.read<FamilyProvider>().errorMessage),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);
//     final family = context.watch<FamilyProvider>();

//     return Scaffold(
//       backgroundColor: AppColors.background,
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
//                       Text('Family Members', style: AppTextStyles.heading2),
//                       IconButton(
//                         onPressed: _showAddMemberSheet,
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
//                   SizedBox(height: r.smallSpace),
//                   Text(
//                     'Manage health records for your family',
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Members list
//             Expanded(
//               child: family.isLoading
//                   ? const LoadingIndicator()
//                   : family.members.isEmpty
//                   ? EmptyState(
//                       message: 'No family members added!',
//                       icon: Icons.people_outline,
//                       buttonText: 'Add Member',
//                       onButtonTap: _showAddMemberSheet,
//                     )
//                   : RefreshIndicator(
//                       onRefresh: _loadMembers,
//                       child: ListView.builder(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: r.wp(6),
//                           vertical: r.hp(1),
//                         ),
//                         itemCount: family.members.length,
//                         itemBuilder: (context, index) {
//                           final member = family.members[index];
//                           return Padding(
//                             padding: EdgeInsets.only(bottom: r.smallSpace),
//                             child: _buildMemberCard(r, member),
//                           );
//                         },
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddMemberSheet,
//         backgroundColor: AppColors.primary,
//         child: Icon(
//           Icons.person_add,
//           color: AppColors.textWhite,
//           size: r.mediumIcon,
//         ),
//       ),
//     );
//   }

//   Widget _buildMemberCard(ResponsiveHelper r, FamilyMemberModel member) {
//     return Container(
//       padding: r.cardPadding,
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(r.mediumRadius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Avatar — name ka pehla letter
//           Container(
//             width: r.wp(14),
//             height: r.wp(14),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 member.name.substring(0, 1).toUpperCase(),
//                 style: AppTextStyles.heading2.copyWith(
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(width: r.wp(3)),

//           // Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   member.name,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: r.hp(0.3)),
//                 Text(
//                   member.relation,
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 SizedBox(height: r.hp(0.3)),
//                 Row(
//                   children: [
//                     // Age chip
//                     if (member.age != null)
//                       _buildInfoChip(
//                         r,
//                         '${member.age} yrs',
//                         Icons.cake_outlined,
//                       ),
//                     if (member.age != null) SizedBox(width: r.wp(2)),

//                     // Blood group chip
//                     if (member.bloodGroup != null &&
//                         member.bloodGroup!.isNotEmpty)
//                       _buildInfoChip(
//                         r,
//                         member.bloodGroup!,
//                         Icons.bloodtype_outlined,
//                       ),
//                   ],
//                 ),

//                 // Allergies
//                 if (member.allergies != null &&
//                     member.allergies!.isNotEmpty) ...[
//                   SizedBox(height: r.hp(0.5)),
//                   Text(
//                     'Allergies: ${member.allergies!.join(', ')}',
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: AppColors.warning,
//                       fontSize: r.sp(10),
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           // Sync + Delete
//           Column(
//             children: [
//               Icon(
//                 member.isSynced ? Icons.cloud_done : Icons.cloud_off_outlined,
//                 size: r.wp(4),
//                 color: member.isSynced ? AppColors.success : AppColors.warning,
//               ),
//               SizedBox(height: r.hp(0.5)),
//               IconButton(
//                 onPressed: () => _confirmDelete(context, r, member),
//                 icon: Icon(
//                   Icons.delete_outline,
//                   color: AppColors.error,
//                   size: r.smallIcon,
//                 ),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddMemberSheet() {
//     final r = ResponsiveHelper(context);
//     final family = context.watch<FamilyProvider>();

//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
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
//                     color: AppColors.textSecondary.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(r.smallRadius),
//                   ),
//                 ),
//               ),

//               SizedBox(height: r.mediumSpace),

//               Text('Add Family Member', style: AppTextStyles.heading2),

//               SizedBox(height: r.mediumSpace),

//               // Name
//               CustomTextField(
//                 controller: _nameController,
//                 label: 'Full Name',
//                 prefixIcon: Icons.person_outline,
//                 textCapitalization: TextCapitalization.words,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Name is required!';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height: r.mediumSpace),

//               // Relation
//               CustomTextField(
//                 controller: _relationController,
//                 label: 'Relation (e.g. Father, Mother)',
//                 prefixIcon: Icons.people_outline,
//                 textCapitalization: TextCapitalization.words,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Relation is required!';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height: r.mediumSpace),

//               // Age
//               CustomTextField(
//                 controller: _ageController,
//                 label: 'Age (Optional)',
//                 prefixIcon: Icons.cake_outlined,
//                 keyboardType: TextInputType.number,
//               ),

//               SizedBox(height: r.mediumSpace),

//               // Blood Group
//               CustomTextField(
//                 controller: _bloodGroupController,
//                 label: 'Blood Group (Optional)',
//                 prefixIcon: Icons.bloodtype_outlined,
//                 textCapitalization: TextCapitalization.characters,
//               ),

//               SizedBox(height: r.mediumSpace),

//               // Allergies
//               CustomTextField(
//                 controller: _allergiesController,
//                 label: 'Allergies (Optional)',
//                 prefixIcon: Icons.warning_amber_outlined,
//               ),

//               SizedBox(height: r.smallSpace),
//               Text(
//                 '* Separate multiple allergies with commas',
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.textSecondary,
//                   fontSize: r.sp(10),
//                 ),
//               ),

//               SizedBox(height: r.largeSpace),

//               // Save button
//               CustomButton(
//                 text: 'Add Member',
//                 onPressed: _saveMember,
//                 isLoading: family.isLoading,
//                 icon: Icons.person_add,
//               ),

//               SizedBox(height: r.largeSpace),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoChip(ResponsiveHelper r, String text, IconData icon) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: r.wp(2), vertical: r.hp(0.3)),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(r.smallRadius),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: r.wp(3), color: AppColors.primary),
//           SizedBox(width: r.wp(1)),
//           Text(
//             text,
//             style: AppTextStyles.bodySmall.copyWith(
//               color: AppColors.primary,
//               fontSize: r.sp(10),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _confirmDelete(
//     BuildContext context,
//     ResponsiveHelper r,
//     FamilyMemberModel member,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Remove Member', style: AppTextStyles.heading3),
//         content: Text(
//           'Remove ${member.name} from family?',
//           style: AppTextStyles.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               final userId =
//                   context.read<AuthProvider>().currentUser?.uid ?? '';
//               await context.read<FamilyProvider>().deleteFamilyMember(
//                 userId,
//                 member.id,
//               );
//             },
//             child: Text(
//               'Remove',
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
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../models/family_member_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadMembers());
  }

  Future<void> _loadMembers() async {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (userId.isEmpty) return;
    await context.read<FamilyProvider>().getFamilyMembers(userId);
  }

  Future<void> _deleteMember(String memberId) async {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Member?', style: AppTextStyles.heading3),
        content: Text(
          'Deleting this member will also delete all their data.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<FamilyProvider>().deleteFamilyMember(
        userId,
        memberId,
      );
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<FamilyProvider>().errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final family = context.watch<FamilyProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    children: [
                      IconButton(
                        onPressed: () => context.go(AppRoutes.dashboard),
                        icon: const Icon(Icons.arrow_back_ios),
                        padding: EdgeInsets.zero,
                      ),
                      SizedBox(width: r.wp(2)),
                      Expanded(
                        child: Text(
                          'Family Members',
                          style: AppTextStyles.heading2,
                        ),
                      ),
                      // Add button
                      IconButton(
                        onPressed: () =>
                            context.push(AppRoutes.addFamilyMember),
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
                  SizedBox(height: r.smallSpace),
                  // Count
                  if (family.members.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${family.members.length} member${family.members.length > 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── List ──
            Expanded(
              child: family.isLoading
                  ? const LoadingIndicator()
                  : family.members.isEmpty
                  ? EmptyState(
                      message:
                          'No family members added!\nAdd your family to manage their health.',
                      icon: Icons.people_outline,
                      buttonText: 'Add Member',
                      onButtonTap: () =>
                          context.push(AppRoutes.addFamilyMember),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMembers,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.wp(6),
                          vertical: r.hp(1),
                        ),
                        itemCount: family.members.length,
                        itemBuilder: (context, index) {
                          return _buildMemberCard(r, family.members[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addFamilyMember),
        backgroundColor: AppColors.primary,
        child: Icon(
          Icons.person_add,
          color: AppColors.textWhite,
          size: r.mediumIcon,
        ),
      ),
    );
  }

  Widget _buildMemberCard(ResponsiveHelper r, FamilyMemberModel member) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.mediumSpace),
      child: CustomCard(
        onTap: () =>
            context.push('/family/detail/${member.id}'), // ← NAVIGATE TO DETAIL
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: r.wp(7),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: member.photoUrl != null
                  ? NetworkImage(member.photoUrl!)
                  : null,
              child: member.photoUrl == null
                  ? Text(
                      member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),

            SizedBox(width: r.wp(4)),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: r.hp(0.3)),
                  Row(
                    children: [
                      _buildChip(r, member.relation, AppColors.primary),
                      if (member.bloodGroup != null) ...[
                        SizedBox(width: r.wp(2)),
                        _buildChip(r, member.bloodGroup!, AppColors.error),
                      ],
                    ],
                  ),
                  if (member.age != null) ...[
                    SizedBox(height: r.hp(0.3)),
                    Text(
                      '${member.age} years',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  // Medical conditions preview
                  if (member.medicalConditions != null &&
                      member.medicalConditions!.isNotEmpty) ...[
                    SizedBox(height: r.hp(0.3)),
                    Text(
                      member.medicalConditions!.take(2).join(', '),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                // Edit
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: r.smallIcon,
                    color: AppColors.primary,
                  ),
                  onPressed: () => context.push('/family/edit/${member.id}'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(height: r.hp(0.5)),
                // Delete
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: r.smallIcon,
                    color: AppColors.error,
                  ),
                  onPressed: () => _deleteMember(member.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            SizedBox(width: r.wp(1)),
            Icon(
              Icons.arrow_forward_ios,
              size: r.wp(3),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(ResponsiveHelper r, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.wp(2), vertical: r.hp(0.2)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.smallRadius),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
