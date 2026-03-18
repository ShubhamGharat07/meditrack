import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/family_member_model.dart';
import '../../models/medicine_model.dart';
import '../../models/doctor_model.dart';
import '../../models/health_record_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/section_header.dart';

class FamilyMemberDetailScreen extends StatefulWidget {
  final String memberId;

  const FamilyMemberDetailScreen({super.key, required this.memberId});

  @override
  State<FamilyMemberDetailScreen> createState() =>
      _FamilyMemberDetailScreenState();
}

class _FamilyMemberDetailScreenState extends State<FamilyMemberDetailScreen> {
  FamilyMemberModel? _member;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    final family = context.read<FamilyProvider>();

    // Find member
    _member = family.members.firstWhere(
      (m) => m.id == widget.memberId,
      orElse: () => family.members.first,
    );

    if (_member == null) return;

    // Load member data
    await family.loadMemberData(userId, widget.memberId);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // Detail screen se jaate waqt data clear
    context.read<FamilyProvider>().clearMemberData();
    super.dispose();
  }

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final family = context.watch<FamilyProvider>();

    _member ??= family.members.firstWhere(
      (m) => m.id == widget.memberId,
      orElse: () => family.members.isNotEmpty
          ? family.members.first
          : FamilyMemberModel(
              id: '',
              userId: '',
              name: 'Unknown',
              relation: '',
              createdAt: DateTime.now(),
            ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── SLIVER APP BAR (Profile Header) ──
          SliverAppBar(
            expandedHeight: r.hp(28),
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () =>
                    context.push('/family/edit/${widget.memberId}'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(r, _member!),
            ),
          ),

          // ── CONTENT ──
          SliverToBoxAdapter(
            child: family.isMemberDataLoading
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: LoadingIndicator(),
                  )
                : Padding(
                    padding: r.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: r.mediumSpace),

                        // Medical Info
                        _buildMedicalInfo(r, _member!),
                        SizedBox(height: r.largeSpace),

                        // Medicines
                        _buildMedicinesSection(r, family),
                        SizedBox(height: r.largeSpace),

                        // Doctors / Appointments
                        _buildDoctorsSection(r, family),
                        SizedBox(height: r.largeSpace),

                        // Health Records
                        _buildHealthRecordsSection(r, family),
                        SizedBox(height: r.largeSpace),

                        // Insurance
                        _buildInsuranceSection(r, _member!),
                        SizedBox(height: r.largeSpace),

                        // Emergency Contact
                        _buildEmergencySection(r, _member!),
                        SizedBox(height: r.largeSpace),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // PROFILE HEADER
  // ─────────────────────────────────────

  Widget _buildProfileHeader(ResponsiveHelper r, FamilyMemberModel member) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: r.hp(4)),
            // Avatar
            CircleAvatar(
              radius: r.wp(12),
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: member.photoUrl != null
                  ? NetworkImage(member.photoUrl!)
                  : null,
              child: member.photoUrl == null
                  ? Text(
                      member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            SizedBox(height: r.mediumSpace),
            Text(
              member.name,
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            ),
            Text(
              member.relation,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: r.smallSpace),
            // Quick info chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (member.age != null) _whiteChip('${member.age} yrs'),
                if (member.bloodGroup != null) ...[
                  SizedBox(width: r.wp(2)),
                  _whiteChip(member.bloodGroup!),
                ],
                if (member.gender != null) ...[
                  SizedBox(width: r.wp(2)),
                  _whiteChip(member.gender!),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _whiteChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      ),
    );
  }

  // ─────────────────────────────────────
  // MEDICAL INFO
  // ─────────────────────────────────────

  Widget _buildMedicalInfo(ResponsiveHelper r, FamilyMemberModel member) {
    final hasAllergies =
        member.allergies != null && member.allergies!.isNotEmpty;
    final hasConditions =
        member.medicalConditions != null &&
        member.medicalConditions!.isNotEmpty;

    if (!hasAllergies && !hasConditions) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Medical Info'),
        SizedBox(height: r.mediumSpace),
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAllergies) ...[
                Text('Allergies', style: AppTextStyles.label),
                SizedBox(height: r.hp(0.5)),
                Wrap(
                  spacing: r.wp(2),
                  runSpacing: r.hp(0.5),
                  children: member.allergies!
                      .map((a) => _infoChip(r, a, AppColors.error))
                      .toList(),
                ),
                if (hasConditions) SizedBox(height: r.mediumSpace),
              ],
              if (hasConditions) ...[
                Text('Medical Conditions', style: AppTextStyles.label),
                SizedBox(height: r.hp(0.5)),
                Wrap(
                  spacing: r.wp(2),
                  runSpacing: r.hp(0.5),
                  children: member.medicalConditions!
                      .map((c) => _infoChip(r, c, AppColors.warning))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoChip(ResponsiveHelper r, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.wp(3), vertical: r.hp(0.4)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.smallRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
    );
  }

  // ─────────────────────────────────────
  // MEDICINES SECTION
  // ─────────────────────────────────────

  Widget _buildMedicinesSection(ResponsiveHelper r, FamilyProvider family) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '💊 Medicines',
          actionText: 'Add',
          onActionTap: () => context.push(
            '${AppRoutes.addMedicine}?memberId=${widget.memberId}',
          ),
        ),
        SizedBox(height: r.mediumSpace),
        if (family.memberMedicines.isEmpty)
          _emptySection(r, 'No medicines added', Icons.medication_outlined)
        else
          ...family.memberMedicines
              .take(3)
              .map((m) => _buildMedicineItem(r, m)),
        if (family.memberMedicines.length > 3)
          _seeMoreButton(
            r,
            '${family.memberMedicines.length - 3} more medicines',
          ),
      ],
    );
  }

  Widget _buildMedicineItem(ResponsiveHelper r, MedicineModel m) {
    final priorityColor = m.priority.toLowerCase() == 'high'
        ? AppColors.error
        : m.priority.toLowerCase() == 'medium'
        ? AppColors.warning
        : AppColors.success;

    return Padding(
      padding: EdgeInsets.only(bottom: r.smallSpace),
      child: CustomCard(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.wp(2.5)),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.smallRadius),
              ),
              child: Icon(
                Icons.medication,
                color: priorityColor,
                size: r.smallIcon,
              ),
            ),
            SizedBox(width: r.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${m.dosage} • ${m.frequency}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _miniChip(r, m.priority, priorityColor),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // DOCTORS SECTION
  // ─────────────────────────────────────

  Widget _buildDoctorsSection(ResponsiveHelper r, FamilyProvider family) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '🏥 Appointments',
          actionText: 'Add',
          onActionTap: () =>
              context.push('/doctors?memberId=${widget.memberId}'),
        ),
        SizedBox(height: r.mediumSpace),
        if (family.memberDoctors.isEmpty)
          _emptySection(r, 'No appointments scheduled', Icons.event_outlined)
        else
          ...family.memberDoctors.take(3).map((d) => _buildDoctorItem(r, d)),
      ],
    );
  }

  Widget _buildDoctorItem(ResponsiveHelper r, DoctorModel d) {
    final isUpcoming = d.isUpcoming;
    return Padding(
      padding: EdgeInsets.only(bottom: r.smallSpace),
      child: CustomCard(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.wp(2.5)),
              decoration: BoxDecoration(
                color:
                    (isUpcoming ? AppColors.secondary : AppColors.textSecondary)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.smallRadius),
              ),
              child: Icon(
                Icons.local_hospital,
                color: isUpcoming
                    ? AppColors.secondary
                    : AppColors.textSecondary,
                size: r.smallIcon,
              ),
            ),
            SizedBox(width: r.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${d.doctorName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    d.speciality,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    DateFormatter.formatDate(d.appointmentDate),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isUpcoming
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _miniChip(
              r,
              isUpcoming ? 'Upcoming' : 'Done',
              isUpcoming ? AppColors.secondary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // HEALTH RECORDS SECTION
  // ─────────────────────────────────────

  Widget _buildHealthRecordsSection(ResponsiveHelper r, FamilyProvider family) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '📁 Health Records',
          actionText: 'Add',
          onActionTap: () =>
              context.push('/health-records?memberId=${widget.memberId}'),
        ),
        SizedBox(height: r.mediumSpace),
        if (family.memberHealthRecords.isEmpty)
          _emptySection(r, 'No health records', Icons.folder_outlined)
        else
          ...family.memberHealthRecords
              .take(3)
              .map((rec) => _buildHealthRecordItem(r, rec)),
      ],
    );
  }

  Widget _buildHealthRecordItem(ResponsiveHelper r, HealthRecordModel rec) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.smallSpace),
      child: CustomCard(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.wp(2.5)),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.smallRadius),
              ),
              child: Icon(
                rec.fileType == 'pdf'
                    ? Icons.picture_as_pdf
                    : Icons.image_outlined,
                color: AppColors.info,
                size: r.smallIcon,
              ),
            ),
            SizedBox(width: r.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    rec.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _miniChip(r, rec.fileType.toUpperCase(), AppColors.info),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // INSURANCE SECTION
  // ─────────────────────────────────────

  Widget _buildInsuranceSection(ResponsiveHelper r, FamilyMemberModel member) {
    final hasInsurance =
        member.insuranceProvider != null ||
        member.insurancePolicyNumber != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '🛡️ Health Insurance',
          actionText: 'Edit',
          onActionTap: () => context.push('/family/edit/${widget.memberId}'),
        ),
        SizedBox(height: r.mediumSpace),
        CustomCard(
          child: hasInsurance
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (member.insuranceProvider != null)
                      _infoRow(
                        r,
                        Icons.shield,
                        'Provider',
                        member.insuranceProvider!,
                      ),
                    if (member.insurancePolicyNumber != null) ...[
                      SizedBox(height: r.smallSpace),
                      _infoRow(
                        r,
                        Icons.numbers,
                        'Policy No.',
                        member.insurancePolicyNumber!,
                      ),
                    ],
                    if (member.insuranceExpiry != null) ...[
                      SizedBox(height: r.smallSpace),
                      _infoRow(
                        r,
                        Icons.event,
                        'Expiry',
                        DateFormatter.formatDate(member.insuranceExpiry!),
                        // Expiry close aane par warning
                        valueColor:
                            member.insuranceExpiry!.isBefore(
                              DateTime.now().add(const Duration(days: 30)),
                            )
                            ? AppColors.warning
                            : null,
                      ),
                    ],
                    if (member.insuranceDocUrl != null) ...[
                      SizedBox(height: r.mediumSpace),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(member.insuranceDocUrl!);
                          if (await canLaunchUrl(uri)) launchUrl(uri);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: r.wp(4),
                            vertical: r.hp(1.2),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(r.mediumRadius),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.download,
                                color: AppColors.primary,
                                size: r.smallIcon,
                              ),
                              SizedBox(width: r.wp(2)),
                              Text(
                                'View Insurance Document',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppColors.textSecondary,
                      size: r.smallIcon,
                    ),
                    SizedBox(width: r.wp(3)),
                    Text(
                      'No insurance info added',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // EMERGENCY SECTION
  // ─────────────────────────────────────

  Widget _buildEmergencySection(ResponsiveHelper r, FamilyMemberModel member) {
    final hasContact = member.emergencyContact != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '🆘 Emergency Contact'),
        SizedBox(height: r.mediumSpace),
        CustomCard(
          onTap: hasContact ? () => _call(member.emergencyContact!) : null,
          child: hasContact
              ? Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(r.wp(3)),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emergency,
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
                            member.emergencyContactName ?? 'Emergency Contact',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            member.emergencyContact!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
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
                )
              : Row(
                  children: [
                    Icon(
                      Icons.emergency_outlined,
                      color: AppColors.textSecondary,
                      size: r.smallIcon,
                    ),
                    SizedBox(width: r.wp(3)),
                    Text(
                      'No emergency contact added',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────

  Widget _infoRow(
    ResponsiveHelper r,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: r.smallIcon, color: AppColors.textSecondary),
        SizedBox(width: r.wp(3)),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptySection(ResponsiveHelper r, String message, IconData icon) {
    return CustomCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: r.smallIcon),
          SizedBox(width: r.wp(3)),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(ResponsiveHelper r, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.wp(2), vertical: r.hp(0.3)),
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

  Widget _seeMoreButton(ResponsiveHelper r, String text) {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: Text(
          '+ $text',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
