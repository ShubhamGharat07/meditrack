import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_card.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    await Future.wait([
      context.read<FamilyProvider>().getFamilyMembers(userId),
      context.read<MedicineProvider>().getMedicines(userId),
    ]);
  }

  // Make a call
  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not make call!'),
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
    final medicines = context.watch<MedicineProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.mediumSpace),

              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.dashboard),
                    icon: const Icon(Icons.arrow_back_ios),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(width: r.wp(2)),
                  Text('Emergency', style: AppTextStyles.heading2),
                ],
              ),

              SizedBox(height: r.largeSpace),

              // SOS Button
              _buildSOSButton(r),

              SizedBox(height: r.largeSpace),

              // Emergency numbers
              Text('Emergency Numbers', style: AppTextStyles.heading3),
              SizedBox(height: r.mediumSpace),
              _buildEmergencyNumbers(r),

              // SizedBox(height: r.largeSpace),

              // Family contacts
              // Text('Family Contacts', style: AppTextStyles.heading3),
              // SizedBox(height: r.mediumSpace),
              // _buildFamilyContacts(r, family),
              SizedBox(height: r.largeSpace),

              // Critical medicines
              Text('Critical Medicines', style: AppTextStyles.heading3),
              SizedBox(height: r.mediumSpace),
              _buildCriticalMedicines(r, medicines),

              SizedBox(height: r.largeSpace),
            ],
          ),
        ),
      ),
    );
  }

  // Big SOS button
  Widget _buildSOSButton(ResponsiveHelper r) {
    return Center(
      child: GestureDetector(
        onTap: () => _makeCall('112'),
        child: Container(
          width: r.wp(45),
          height: r.wp(45),
          decoration: BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emergency,
                color: AppColors.textWhite,
                size: r.largeIcon,
              ),
              SizedBox(height: r.hp(0.5)),
              Text(
                'SOS',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textWhite,
                  fontSize: r.sp(22),
                ),
              ),
              Text(
                'Call 112',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textWhite.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Emergency numbers list
  Widget _buildEmergencyNumbers(ResponsiveHelper r) {
    final numbers = [
      {
        'title': 'Ambulance',
        'number': '108',
        'icon': Icons.local_hospital,
        'color': AppColors.error,
      },
      {
        'title': 'Police',
        'number': '100',
        'icon': Icons.local_police,
        'color': AppColors.primary,
      },
      {
        'title': 'Fire Brigade',
        'number': '101',
        'icon': Icons.local_fire_department,
        'color': AppColors.warning,
      },
      {
        'title': 'National Emergency',
        'number': '112',
        'icon': Icons.emergency,
        'color': AppColors.error,
      },
    ];

    return Column(
      children: numbers.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: r.smallSpace),
          child: CustomCard(
            onTap: () => _makeCall(item['number'] as String),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.wp(3)),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
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
                    children: [
                      Text(
                        item['title'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item['number'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(r.wp(2)),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.call,
                    color: AppColors.success,
                    size: r.smallIcon,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Family contacts
  Widget _buildFamilyContacts(ResponsiveHelper r, FamilyProvider family) {
    if (family.members.isEmpty) {
      return CustomCard(
        child: Row(
          children: [
            Icon(
              Icons.people_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: r.smallIcon,
            ),
            SizedBox(width: r.wp(3)),
            Text(
              'No family members added!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: family.members.map((member) {
        return Padding(
          padding: EdgeInsets.only(bottom: r.smallSpace),
          child: CustomCard(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.wp(3)),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
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
                        member.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        member.relation,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Show allergies
                      if (member.allergies != null &&
                          member.allergies!.isNotEmpty)
                        Text(
                          'Allergies: ${member.allergies!.join(', ')}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontSize: r.sp(10),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Blood group badge
                if (member.bloodGroup != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.wp(2),
                      vertical: r.hp(0.3),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(r.smallRadius),
                    ),
                    child: Text(
                      member.bloodGroup!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
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

  // Critical medicines — High priority only
  Widget _buildCriticalMedicines(
    ResponsiveHelper r,
    MedicineProvider medicines,
  ) {
    final critical = medicines.medicines
        .where((m) => m.priority.toLowerCase() == 'high')
        .toList();

    if (critical.isEmpty) {
      return CustomCard(
        child: Row(
          children: [
            Icon(
              Icons.medication_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: r.smallIcon,
            ),
            SizedBox(width: r.wp(3)),
            Text(
              'No critical medicines!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: critical.map((medicine) {
        return Padding(
          padding: EdgeInsets.only(bottom: r.smallSpace),
          child: CustomCard(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.wp(3)),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medication,
                    color: AppColors.error,
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
                        '${medicine.dosage} • ${medicine.type}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.wp(2),
                    vertical: r.hp(0.3),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(r.smallRadius),
                  ),
                  child: Text(
                    'HIGH',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
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
}
