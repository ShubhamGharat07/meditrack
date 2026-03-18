import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:meditrack/views/notification/notification_screen.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/health_record_provider.dart';
import '../../providers/family_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Notification badge count
  int _notifCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadData();
      await _loadNotifCount();
    });
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

  // ─────────────────────────────────────
  // NOTIFICATION BADGE COUNT
  // ─────────────────────────────────────

  Future<void> _loadNotifCount() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final pending = await plugin.pendingNotificationRequests();
    if (mounted) {
      setState(() => _notifCount = pending.length);
    }
  }

  // ─────────────────────────────────────
  // OPEN NOTIFICATION SCREEN
  // ─────────────────────────────────────

  void _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    // Refresh badge after coming back from screen
    await _loadNotifCount();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final auth = context.watch<AuthProvider>();
    final medicines = context.watch<MedicineProvider>();
    final doctors = context.watch<DoctorProvider>();
    final records = context.watch<HealthRecordProvider>();
    final family = context.watch<FamilyProvider>();

    final userName = auth.currentUser?.name ?? 'User';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadData();
            await _loadNotifCount();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: r.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: r.mediumSpace),

                // Header
                _buildHeader(r, userName, greeting),

                SizedBox(height: r.largeSpace),

                // Stats grid
                _buildStatsGrid(
                  r,
                  medicines.medicines.length,
                  doctors.upcomingDoctors.length,
                  records.records.length,
                  family.members.length,
                ),

                SizedBox(height: r.largeSpace),

                // Today's medicines
                SectionHeader(
                  title: "Today's Medicines",
                  actionText: 'See All',
                  onActionTap: () => context.go(AppRoutes.medicines),
                ),
                SizedBox(height: r.smallSpace),
                medicines.isLoading
                    ? const LoadingIndicator()
                    : _buildTodayMedicines(r, medicines),

                SizedBox(height: r.largeSpace),

                // Upcoming appointments
                SectionHeader(
                  title: 'Upcoming Appointments',
                  actionText: 'See All',
                  onActionTap: () => context.go(AppRoutes.doctors),
                ),
                SizedBox(height: r.smallSpace),
                doctors.isLoading
                    ? const LoadingIndicator()
                    : _buildUpcomingAppointments(r, doctors),

                SizedBox(height: r.largeSpace),

                // Quick actions
                const SectionHeader(title: 'Quick Actions'),
                SizedBox(height: r.smallSpace),
                _buildQuickActions(r),

                SizedBox(height: r.largeSpace),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // HEADER — Bell button pe notification screen open
  // ─────────────────────────────────────

  Widget _buildHeader(ResponsiveHelper r, String userName, String greeting) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(userName, style: AppTextStyles.heading2),
          ],
        ),
        // ── NOTIFICATION BELL — Badge ke saath ──
        GestureDetector(
          onTap: _openNotifications,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: r.mediumIcon,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              // Badge — notification count dikhao
              if (_notifCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _notifCount > 99 ? '99+' : '$_notifCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // STATS GRID
  // ─────────────────────────────────────

  Widget _buildStatsGrid(
    ResponsiveHelper r,
    int medicineCount,
    int appointmentCount,
    int recordCount,
    int familyCount,
  ) {
    final stats = [
      {
        'title': 'Medicines',
        'count': medicineCount,
        'icon': Icons.medication,
        'color': AppColors.primary,
        'route': AppRoutes.medicines,
      },
      {
        'title': 'Appointments',
        'count': appointmentCount,
        'icon': Icons.calendar_month,
        'color': AppColors.secondary,
        'route': AppRoutes.doctors,
      },
      {
        'title': 'Records',
        'count': recordCount,
        'icon': Icons.folder_special,
        'color': AppColors.success,
        'route': AppRoutes.healthRecords,
      },
      // {
      //   'title': 'Family',
      //   'count': familyCount,
      //   'icon': Icons.people,
      //   'color': AppColors.warning,
      //   'route': AppRoutes.family,
      // },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.gridColumns,
        crossAxisSpacing: r.wp(3),
        mainAxisSpacing: r.wp(3),
        childAspectRatio: 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return StatCard(
          title: stat['title'] as String,
          count: stat['count'] as int,
          icon: stat['icon'] as IconData,
          color: stat['color'] as Color,
          onTap: () => context.go(stat['route'] as String),
        );
      },
    );
  }

  // ─────────────────────────────────────
  // TODAY'S MEDICINES
  // ─────────────────────────────────────

  Widget _buildTodayMedicines(ResponsiveHelper r, MedicineProvider medicines) {
    final todayMedicines = medicines.getActiveMedicines().take(3).toList();

    if (todayMedicines.isEmpty) {
      return EmptyState(
        message: 'No medicines for today!',
        icon: Icons.medication_outlined,
        buttonText: 'Add Medicine',
        onButtonTap: () => context.go(AppRoutes.addMedicine),
      );
    }

    return Column(
      children: todayMedicines.map((medicine) {
        return Padding(
          padding: EdgeInsets.only(bottom: r.smallSpace),
          child: CustomCard(
            onTap: () => context.go('/medicines/detail/${medicine.id}'),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.wp(2)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(r.smallRadius),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: AppColors.primary,
                    size: r.smallIcon,
                  ),
                ),
                SizedBox(width: r.wp(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${medicine.dosage} • ${medicine.frequency}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: r.wp(2)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.wp(2),
                    vertical: r.hp(0.4),
                  ),
                  decoration: BoxDecoration(
                    color: _priorityColor(medicine.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(r.smallRadius),
                  ),
                  child: Text(
                    medicine.priority,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _priorityColor(medicine.priority),
                      fontSize: r.sp(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────
  // UPCOMING APPOINTMENTS
  // ─────────────────────────────────────

  Widget _buildUpcomingAppointments(
    ResponsiveHelper r,
    DoctorProvider doctors,
  ) {
    final upcoming = doctors.upcomingDoctors.take(2).toList();

    if (upcoming.isEmpty) {
      return EmptyState(
        message: 'No upcoming appointments!',
        icon: Icons.calendar_month_outlined,
        buttonText: 'Add Doctor',
        onButtonTap: () => context.go(AppRoutes.doctors),
      );
    }

    return Column(
      children: upcoming.map((doctor) {
        return Padding(
          padding: EdgeInsets.only(bottom: r.smallSpace),
          child: CustomCard(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.wp(2)),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(r.smallRadius),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColors.secondary,
                    size: r.smallIcon,
                  ),
                ),
                SizedBox(width: r.wp(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.doctorName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        doctor.speciality,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: r.wp(2)),
                Text(
                  '${doctor.appointmentDate.day}/${doctor.appointmentDate.month}/${doctor.appointmentDate.year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                    fontSize: r.sp(10),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────

  Widget _buildQuickActions(ResponsiveHelper r) {
    final actions = [
      {
        'title': 'Add Medicine',
        'icon': Icons.add_circle,
        'color': AppColors.primary,
        'route': AppRoutes.addMedicine,
      },
      {
        'title': 'Add Doctor',
        'icon': Icons.person_add,
        'color': AppColors.secondary,
        'route': AppRoutes.doctors,
      },
      {
        'title': 'Emergency',
        'icon': Icons.emergency,
        'color': AppColors.error,
        'route': AppRoutes.emergency,
      },
      {
        'title': 'AI Chat',
        'icon': Icons.smart_toy,
        'color': AppColors.success,
        'route': AppRoutes.aiAssistant,
      },
      {
        'title': 'Analytics',
        'icon': Icons.bar_chart,
        'color': AppColors.warning,
        'route': AppRoutes.analytics,
      },
      // {
      //   'title': 'Family',
      //   'icon': Icons.people,
      //   'color': AppColors.primary,
      //   'route': AppRoutes.family,
      // },
      {
        'title': 'Health Insurance',
        'icon': Icons.health_and_safety,
        'color': AppColors.primary,
        'route': AppRoutes.healthInsurance,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.gridColumns,
        crossAxisSpacing: r.wp(3),
        mainAxisSpacing: r.wp(3),
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return CustomCard(
          color: (action['color'] as Color).withOpacity(0.1),
          hasShadow: false,
          onTap: () {
            final route = action['route'] as String;
            if (route == AppRoutes.healthInsurance) {
              context.push(route);
            } else {
              context.go(route);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action['icon'] as IconData,
                color: action['color'] as Color,
                size: r.mediumIcon,
              ),
              SizedBox(height: r.smallSpace),
              Text(
                action['title'] as String,
                style: AppTextStyles.bodySmall.copyWith(
                  color: action['color'] as Color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
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
