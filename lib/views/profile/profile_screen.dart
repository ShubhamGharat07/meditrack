// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/constants/app_text_style.dart';
// import '../../core/utils/responsive_helper.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/medicine_provider.dart';
// import '../../providers/doctor_provider.dart';
// import '../../providers/health_record_provider.dart';
// import '../../providers/family_provider.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/common/custom_card.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => _loadData());
//   }

//   Future<void> _loadData() async {
//     final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
//     if (userId.isEmpty) return;

//     await Future.wait([
//       context.read<MedicineProvider>().getMedicines(userId),
//       context.read<DoctorProvider>().getDoctors(userId),
//       context.read<HealthRecordProvider>().getHealthRecords(userId),
//       context.read<FamilyProvider>().getFamilyMembers(userId),
//     ]);
//   }

//   // Logout confirm dialog
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Logout', style: AppTextStyles.heading3),
//         content: Text(
//           'Are you sure you want to logout?',
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
//               await context.read<AuthProvider>().logout();
//               if (mounted) {
//                 context.go(AppRoutes.login);
//               }
//             },
//             child: Text(
//               'Logout',
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

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);
//     final auth = context.watch<AuthProvider>();
//     final medicines = context.watch<MedicineProvider>();
//     final doctors = context.watch<DoctorProvider>();
//     final records = context.watch<HealthRecordProvider>();
//     final family = context.watch<FamilyProvider>();

//     final user = auth.currentUser;

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: r.pagePadding,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: r.mediumSpace),

//               // Header
//               Text('Profile', style: AppTextStyles.heading2),

//               SizedBox(height: r.largeSpace),

//               // Profile card
//               _buildProfileCard(r, user),

//               SizedBox(height: r.largeSpace),

//               // Stats
//               _buildStatsRow(
//                 r,
//                 medicines.medicines.length,
//                 doctors.doctors.length,
//                 records.records.length,
//                 family.members.length,
//               ),

//               SizedBox(height: r.largeSpace),

//               // Menu items
//               Text('Account', style: AppTextStyles.heading3),
//               SizedBox(height: r.mediumSpace),
//               _buildMenuSection(r),

//               SizedBox(height: r.largeSpace),

//               // App info
//               Text('App', style: AppTextStyles.heading3),
//               SizedBox(height: r.mediumSpace),
//               _buildAppSection(r),

//               SizedBox(height: r.largeSpace),

//               // Logout button
//               _buildLogoutButton(r),

//               SizedBox(height: r.largeSpace),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Profile card — avatar + name + email
//   Widget _buildProfileCard(ResponsiveHelper r, dynamic user) {
//     return CustomCard(
//       child: Row(
//         children: [
//           // Avatar
//           Container(
//             width: r.wp(16),
//             height: r.wp(16),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 user?.name?.isNotEmpty == true
//                     ? user!.name[0].toUpperCase()
//                     : 'U',
//                 style: AppTextStyles.heading2.copyWith(
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(width: r.wp(4)),

//           // Name + email
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   user?.name ?? 'User',
//                   style: AppTextStyles.heading3,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: r.hp(0.3)),
//                 Text(
//                   user?.email ?? '',
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: r.hp(0.5)),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: r.wp(2),
//                     vertical: r.hp(0.2),
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.success.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(r.smallRadius),
//                   ),
//                   child: Text(
//                     'Active',
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: AppColors.success,
//                       fontSize: r.sp(10),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Stats row — 4 items
//   Widget _buildStatsRow(
//     ResponsiveHelper r,
//     int medicineCount,
//     int doctorCount,
//     int recordCount,
//     int familyCount,
//   ) {
//     final stats = [
//       {
//         'label': 'Medicines',
//         'count': medicineCount,
//         'color': AppColors.primary,
//       },
//       {'label': 'Doctors', 'count': doctorCount, 'color': AppColors.secondary},
//       {'label': 'Records', 'count': recordCount, 'color': AppColors.success},
//       // {'label': 'Family', 'count': familyCount, 'color': AppColors.warning},
//     ];

//     return CustomCard(
//       child: Row(
//         children: stats.asMap().entries.map((entry) {
//           final index = entry.key;
//           final stat = entry.value;
//           return Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 border: index < stats.length - 1
//                     ? Border(
//                         right: BorderSide(
//                           color: Theme.of(
//                             context,
//                           ).colorScheme.onSurfaceVariant.withOpacity(0.2),
//                         ),
//                       )
//                     : null,
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     '${stat['count']}',
//                     style: AppTextStyles.heading3.copyWith(
//                       color: stat['color'] as Color,
//                     ),
//                   ),
//                   SizedBox(height: r.hp(0.3)),
//                   Text(
//                     stat['label'] as String,
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                       fontSize: r.sp(10),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // Account menu section
//   Widget _buildMenuSection(ResponsiveHelper r) {
//     final menuItems = [
//       {
//         'title': 'My Medicines',
//         'icon': Icons.medication_outlined,
//         'color': AppColors.primary,
//         'route': AppRoutes.medicines,
//       },
//       {
//         'title': 'My Doctors',
//         'icon': Icons.person_outlined,
//         'color': AppColors.secondary,
//         'route': AppRoutes.doctors,
//       },
//       {
//         'title': 'Health Records',
//         'icon': Icons.folder_outlined,
//         'color': AppColors.success,
//         'route': AppRoutes.healthRecords,
//       },
//       // {
//       //   'title': 'Family Members',
//       //   'icon': Icons.people_outlined,
//       //   'color': AppColors.warning,
//       //   'route': AppRoutes.family,
//       // },
//     ];

//     return CustomCard(
//       child: Column(
//         children: menuItems.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;
//           return Column(
//             children: [
//               _buildMenuItem(
//                 r,
//                 icon: item['icon'] as IconData,
//                 title: item['title'] as String,
//                 color: item['color'] as Color,
//                 onTap: () => context.go(item['route'] as String),
//               ),
//               if (index < menuItems.length - 1)
//                 Divider(
//                   height: 1,
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.onSurfaceVariant.withOpacity(0.1),
//                 ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // App section — settings, analytics, emergency
//   Widget _buildAppSection(ResponsiveHelper r) {
//     final appItems = [
//       {
//         'title': 'Settings',
//         'icon': Icons.settings_outlined,
//         'color': Theme.of(context).colorScheme.onSurfaceVariant,
//         'route': AppRoutes.settings,
//       },
//       {
//         'title': 'Analytics',
//         'icon': Icons.bar_chart_outlined,
//         'color': AppColors.warning,
//         'route': AppRoutes.analytics,
//       },
//       {
//         'title': 'Emergency',
//         'icon': Icons.emergency_outlined,
//         'color': AppColors.error,
//         'route': AppRoutes.emergency,
//       },
//     ];

//     return CustomCard(
//       child: Column(
//         children: appItems.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;
//           return Column(
//             children: [
//               _buildMenuItem(
//                 r,
//                 icon: item['icon'] as IconData,
//                 title: item['title'] as String,
//                 color: item['color'] as Color,
//                 onTap: () => context.go(item['route'] as String),
//               ),
//               if (index < appItems.length - 1)
//                 Divider(
//                   height: 1,
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.onSurfaceVariant.withOpacity(0.1),
//                 ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // Single menu item
//   Widget _buildMenuItem(
//     ResponsiveHelper r, {
//     required IconData icon,
//     required String title,
//     required Color color,
//     required VoidCallback onTap,
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
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(r.smallRadius),
//               ),
//               child: Icon(icon, color: color, size: r.smallIcon),
//             ),
//             SizedBox(width: r.wp(3)),
//             Expanded(
//               child: Text(
//                 title,
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: r.wp(3.5),
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Logout button
//   Widget _buildLogoutButton(ResponsiveHelper r) {
//     return GestureDetector(
//       onTap: _showLogoutDialog,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: r.hp(2)),
//         decoration: BoxDecoration(
//           color: AppColors.error.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(r.mediumRadius),
//           border: Border.all(color: AppColors.error.withOpacity(0.3)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.logout, color: AppColors.error, size: r.smallIcon),
//             SizedBox(width: r.wp(2)),
//             Text(
//               'Logout',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.error,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
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
import '../../providers/medicine_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/health_record_provider.dart';
import '../../providers/family_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (userId.isEmpty) return;
    await Future.wait([
      context.read<MedicineProvider>().getMedicines(userId),
      context.read<DoctorProvider>().getDoctors(userId),
      context.read<HealthRecordProvider>().getHealthRecords(userId),
      context.read<FamilyProvider>().getFamilyMembers(userId),
    ]);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to logout?',
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
              await context.read<AuthProvider>().logout();
              if (mounted) context.go(AppRoutes.login);
            },
            child: Text(
              'Logout',
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

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final auth = context.watch<AuthProvider>();
    final medicines = context.watch<MedicineProvider>();
    final doctors = context.watch<DoctorProvider>();
    final records = context.watch<HealthRecordProvider>();
    final family = context.watch<FamilyProvider>();
    final user = auth.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.mediumSpace),

              // ── Header row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profile', style: AppTextStyles.heading2),
                  // Edit button
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.editProfile),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(
                      'Edit',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(
                        horizontal: r.wp(3),
                        vertical: r.hp(0.8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.largeSpace),

              // ── Profile Card ──
              _buildProfileCard(r, user),

              SizedBox(height: r.largeSpace),

              // ── Stats ──
              _buildStatsRow(
                r,
                medicines.medicines.length,
                doctors.doctors.length,
                records.records.length,
                family.members.length,
              ),

              SizedBox(height: r.largeSpace),

              // ── Health Info (blood group, age, phone) ──
              if (user?.bloodGroup != null ||
                  user?.age != null ||
                  user?.phone != null) ...[
                Text('Health Info', style: AppTextStyles.heading3),
                SizedBox(height: r.mediumSpace),
                _buildHealthInfoCard(r, user),
                SizedBox(height: r.largeSpace),
              ],

              // ── Account Menu ──
              Text('Account', style: AppTextStyles.heading3),
              SizedBox(height: r.mediumSpace),
              _buildMenuSection(r),

              SizedBox(height: r.largeSpace),

              // ── App Menu ──
              Text('App', style: AppTextStyles.heading3),
              SizedBox(height: r.mediumSpace),
              _buildAppSection(r),

              SizedBox(height: r.largeSpace),

              // ── Logout ──
              _buildLogoutButton(r),

              SizedBox(height: r.largeSpace),
            ],
          ),
        ),
      ),
    );
  }

  // ── Profile Card ──
  Widget _buildProfileCard(ResponsiveHelper r, dynamic user) {
    return CustomCard(
      child: Row(
        children: [
          // Avatar — photo ya initial
          GestureDetector(
            onTap: () => context.push(AppRoutes.editProfile),
            child: Container(
              width: r.wp(18),
              height: r.wp(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: user?.photoUrl != null
                    ? Image.network(
                        user!.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarInitial(r, user),
                      )
                    : _avatarInitial(r, user),
              ),
            ),
          ),

          SizedBox(width: r.wp(4)),

          // Name + email + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: r.hp(0.3)),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: r.hp(0.5)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.wp(2),
                    vertical: r.hp(0.2),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(r.smallRadius),
                  ),
                  child: Text(
                    'Active',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontSize: r.sp(10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit icon
          IconButton(
            onPressed: () => context.push(AppRoutes.editProfile),
            icon: Icon(
              Icons.arrow_forward_ios,
              size: r.wp(3.5),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarInitial(ResponsiveHelper r, dynamic user) {
    return Center(
      child: Text(
        user?.name?.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
        style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
      ),
    );
  }

  // ── Health Info Card ──
  Widget _buildHealthInfoCard(ResponsiveHelper r, dynamic user) {
    return CustomCard(
      child: Column(
        children: [
          if (user?.bloodGroup != null) ...[
            _buildInfoRow(
              r,
              icon: Icons.bloodtype_outlined,
              label: 'Blood Group',
              value: user!.bloodGroup!,
              color: AppColors.error,
            ),
          ],
          if (user?.age != null) ...[
            if (user?.bloodGroup != null) _buildDivider(),
            _buildInfoRow(
              r,
              icon: Icons.cake_outlined,
              label: 'Age',
              value: '${user!.age} years',
              color: AppColors.secondary,
            ),
          ],
          if (user?.phone != null && user!.phone!.isNotEmpty) ...[
            if (user.bloodGroup != null || user.age != null) _buildDivider(),
            _buildInfoRow(
              r,
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: user.phone!,
              color: AppColors.success,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ResponsiveHelper r, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.hp(1)),
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
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1);

  // ── Stats Row ──
  Widget _buildStatsRow(
    ResponsiveHelper r,
    int medicineCount,
    int doctorCount,
    int recordCount,
    int familyCount,
  ) {
    final stats = [
      {
        'label': 'Medicines',
        'count': medicineCount,
        'color': AppColors.primary,
      },
      {'label': 'Doctors', 'count': doctorCount, 'color': AppColors.secondary},
      {'label': 'Records', 'count': recordCount, 'color': AppColors.success},
    ];

    return CustomCard(
      child: Row(
        children: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: index < stats.length - 1
                    ? Border(
                        right: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.2),
                        ),
                      )
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    '${stat['count']}',
                    style: AppTextStyles.heading3.copyWith(
                      color: stat['color'] as Color,
                    ),
                  ),
                  SizedBox(height: r.hp(0.3)),
                  Text(
                    stat['label'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: r.sp(10),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Account Menu ──
  Widget _buildMenuSection(ResponsiveHelper r) {
    final menuItems = [
      {
        'title': 'My Medicines',
        'icon': Icons.medication_outlined,
        'color': AppColors.primary,
        'route': AppRoutes.medicines,
      },
      {
        'title': 'My Doctors',
        'icon': Icons.person_outlined,
        'color': AppColors.secondary,
        'route': AppRoutes.doctors,
      },
      {
        'title': 'Health Records',
        'icon': Icons.folder_outlined,
        'color': AppColors.success,
        'route': AppRoutes.healthRecords,
      },
    ];

    return CustomCard(
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildMenuItem(
                r,
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                color: item['color'] as Color,
                onTap: () => context.go(item['route'] as String),
              ),
              if (index < menuItems.length - 1)
                Divider(
                  height: 1,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── App Menu ──
  Widget _buildAppSection(ResponsiveHelper r) {
    final appItems = [
      {
        'title': 'Settings',
        'icon': Icons.settings_outlined,
        'color': Theme.of(context).colorScheme.onSurfaceVariant,
        'route': AppRoutes.settings,
      },
      {
        'title': 'Analytics',
        'icon': Icons.bar_chart_outlined,
        'color': AppColors.warning,
        'route': AppRoutes.analytics,
      },
      {
        'title': 'Emergency',
        'icon': Icons.emergency_outlined,
        'color': AppColors.error,
        'route': AppRoutes.emergency,
      },
    ];

    return CustomCard(
      child: Column(
        children: appItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildMenuItem(
                r,
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                color: item['color'] as Color,
                onTap: () => context.go(item['route'] as String),
              ),
              if (index < appItems.length - 1)
                Divider(
                  height: 1,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Single Menu Item ──
  Widget _buildMenuItem(
    ResponsiveHelper r, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.smallRadius),
              ),
              child: Icon(icon, color: color, size: r.smallIcon),
            ),
            SizedBox(width: r.wp(3)),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: r.wp(3.5),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout Button ──
  Widget _buildLogoutButton(ResponsiveHelper r) {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: r.hp(2)),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(r.mediumRadius),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColors.error, size: r.smallIcon),
            SizedBox(width: r.wp(2)),
            Text(
              'Logout',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
