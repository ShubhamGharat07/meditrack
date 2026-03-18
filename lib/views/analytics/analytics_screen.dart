import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:meditrack/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/health_record_provider.dart';
import '../../providers/family_provider.dart';
import '../../widgets/common/loading_indicator.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final medicines = context.watch<MedicineProvider>();
    final doctors = context.watch<DoctorProvider>();
    final records = context.watch<HealthRecordProvider>();
    final family = context.watch<FamilyProvider>();

    final isLoading =
        medicines.isLoading ||
        doctors.isLoading ||
        records.isLoading ||
        family.isLoading;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const LoadingIndicator()
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: r.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: r.mediumSpace),

                      // ── HEADER — AddMedicineScreen jaisa style ──
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.dashboard);
                              }
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                            padding: EdgeInsets.zero,
                          ),
                          SizedBox(width: r.wp(2)),
                          Text('Analytics', style: AppTextStyles.heading2),
                        ],
                      ),

                      SizedBox(height: r.largeSpace),

                      // Summary cards
                      _buildSummaryCards(
                        r,
                        medicines.medicines.length,
                        doctors.doctors.length,
                        records.records.length,
                        family.members.length,
                      ),

                      SizedBox(height: r.largeSpace),

                      _buildSectionTitle(r, 'Medicine Priority'),
                      SizedBox(height: r.mediumSpace),
                      _buildMedicinePriorityChart(r, medicines),

                      SizedBox(height: r.largeSpace),

                      _buildSectionTitle(r, 'Health Records by Category'),
                      SizedBox(height: r.mediumSpace),
                      _buildRecordsCategoryChart(r, records),

                      SizedBox(height: r.largeSpace),

                      _buildSectionTitle(r, 'Medicine Status'),
                      SizedBox(height: r.mediumSpace),
                      _buildMedicineStatus(r, medicines),

                      SizedBox(height: r.largeSpace),

                      _buildSectionTitle(r, 'Appointments Summary'),
                      SizedBox(height: r.mediumSpace),
                      _buildAppointmentsSummary(r, doctors),

                      SizedBox(height: r.largeSpace),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryCards(
    ResponsiveHelper r,
    int medicineCount,
    int doctorCount,
    int recordCount,
    int familyCount,
  ) {
    final items = [
      {
        'title': 'Medicines',
        'value': '$medicineCount',
        'icon': Icons.medication,
        'color': AppColors.primary,
      },
      {
        'title': 'Doctors',
        'value': '$doctorCount',
        'icon': Icons.person,
        'color': AppColors.secondary,
      },
      {
        'title': 'Records',
        'value': '$recordCount',
        'icon': Icons.folder,
        'color': AppColors.success,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: r.wp(3),
        mainAxisSpacing: r.wp(3),
        childAspectRatio: 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: r.cardPadding,
          decoration: BoxDecoration(
            color: (item['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.mediumRadius),
            border: Border.all(
              color: (item['color'] as Color).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.wp(2)),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(r.smallRadius),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: r.smallIcon,
                ),
              ),
              SizedBox(width: r.wp(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['value'] as String,
                      style: AppTextStyles.heading2.copyWith(
                        color: item['color'] as Color,
                      ),
                    ),
                    Text(
                      item['title'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicinePriorityChart(
    ResponsiveHelper r,
    MedicineProvider medicines,
  ) {
    final high = medicines.medicines
        .where((m) => m.priority.toLowerCase() == 'high')
        .length;
    final medium = medicines.medicines
        .where((m) => m.priority.toLowerCase() == 'medium')
        .length;
    final low = medicines.medicines
        .where((m) => m.priority.toLowerCase() == 'low')
        .length;

    if (medicines.medicines.isEmpty) {
      return _buildEmptyChart(r, 'No medicines added yet!');
    }

    final maxVal = [
      high,
      medium,
      low,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: r.cardPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(r.mediumRadius),
      ),
      child: SizedBox(
        height: r.hp(25),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVal + 2,
            barGroups: [
              _buildBarGroup(0, high.toDouble(), AppColors.error),
              _buildBarGroup(1, medium.toDouble(), AppColors.warning),
              _buildBarGroup(2, low.toDouble(), AppColors.success),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const titles = ['High', 'Medium', 'Low'];
                    if (value.toInt() >= titles.length) return const SizedBox();
                    return Padding(
                      padding: EdgeInsets.only(top: r.hp(0.5)),
                      child: Text(
                        titles[value.toInt()],
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: r.sp(10),
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: r.wp(8),
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: AppTextStyles.bodySmall.copyWith(fontSize: r.sp(10)),
                  ),
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.1),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 30,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildRecordsCategoryChart(
    ResponsiveHelper r,
    HealthRecordProvider records,
  ) {
    if (records.records.isEmpty) {
      return _buildEmptyChart(r, 'No health records yet!');
    }

    final Map<String, int> categoryCounts = {};
    for (final record in records.records) {
      categoryCounts[record.category] =
          (categoryCounts[record.category] ?? 0) + 1;
    }

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
    ];

    final entries = categoryCounts.entries.toList();

    final sections = entries.map((entry) {
      final index = entries.indexOf(entry);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: colors[index % colors.length],
        title: '${entry.value}',
        radius: r.wp(15),
        titleStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w600,
        ),
      );
    }).toList();

    return Container(
      padding: r.cardPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(r.mediumRadius),
      ),
      child: Column(
        children: [
          SizedBox(
            height: r.hp(25),
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: r.wp(10),
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: r.mediumSpace),
          Wrap(
            spacing: r.wp(4),
            runSpacing: r.hp(1),
            children: entries.map((entry) {
              final index = entries.indexOf(entry);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: r.wp(3),
                    height: r.wp(3),
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: r.wp(1)),
                  Text(entry.key, style: AppTextStyles.bodySmall),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineStatus(ResponsiveHelper r, MedicineProvider medicines) {
    final active = medicines.getActiveMedicines().length;
    final completed = medicines.getCompletedMedicines().length;
    final total = medicines.medicines.length;

    return Container(
      padding: r.cardPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(r.mediumRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusItem(
              r,
              'Active',
              active,
              total,
              AppColors.success,
            ),
          ),
          SizedBox(width: r.wp(4)),
          Expanded(
            child: _buildStatusItem(
              r,
              'Completed',
              completed,
              total,
              AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    ResponsiveHelper r,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percent = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: r.hp(0.5)),
        Text('$count', style: AppTextStyles.heading2.copyWith(color: color)),
        SizedBox(height: r.hp(0.5)),
        ClipRRect(
          borderRadius: BorderRadius.circular(r.smallRadius),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: r.hp(1),
          ),
        ),
        SizedBox(height: r.hp(0.3)),
        Text(
          '${(percent * 100).toStringAsFixed(0)}%',
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontSize: r.sp(10),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsSummary(ResponsiveHelper r, DoctorProvider doctors) {
    final upcoming = doctors.upcomingDoctors.length;
    final past = doctors.pastDoctors.length;

    return Container(
      padding: r.cardPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(r.mediumRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildAppointmentItem(
              r,
              'Upcoming',
              upcoming,
              Icons.calendar_month,
              AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: r.hp(8),
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.2),
          ),
          Expanded(
            child: _buildAppointmentItem(
              r,
              'Past',
              past,
              Icons.history,
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(
    ResponsiveHelper r,
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: r.mediumIcon),
        SizedBox(height: r.smallSpace),
        Text('$count', style: AppTextStyles.heading2.copyWith(color: color)),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart(ResponsiveHelper r, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.wp(8)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(r.mediumRadius),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart,
            size: r.mediumIcon,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          SizedBox(height: r.smallSpace),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ResponsiveHelper r, String title) {
    return Text(title, style: AppTextStyles.heading3);
  }
}
