import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/health_insurance_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_insurance_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import 'document_viewer_screen.dart';

class HealthInsuranceScreen extends StatefulWidget {
  const HealthInsuranceScreen({super.key});

  @override
  State<HealthInsuranceScreen> createState() => _HealthInsuranceScreenState();
}

class _HealthInsuranceScreenState extends State<HealthInsuranceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _coverageController = TextEditingController();
  final _agentController = TextEditingController();
  final _membersController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));

  File? _selectedDoc;
  String _selectedDocName = '';
  String _selectedDocType = '';

  HealthInsuranceModel? _editingPolicy;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadPolicies());
  }

  Future<void> _loadPolicies() async {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (userId.isEmpty) return;
    await context.read<HealthInsuranceProvider>().getPolicies(userId);
  }

  @override
  void dispose() {
    _providerController.dispose();
    _policyNumberController.dispose();
    _coverageController.dispose();
    _agentController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────
  // CALL AGENT
  // ─────────────────────────────────────

  Future<void> _callAgent(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
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

  // ─────────────────────────────────────
  // FILE PICKER
  // ─────────────────────────────────────

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final ext = result.files.single.extension?.toLowerCase() ?? '';
      setState(() {
        _selectedDoc = File(result.files.single.path!);
        _selectedDocName = result.files.single.name;
        _selectedDocType = ext == 'pdf' ? 'pdf' : 'image';
      });
    }
  }

  void _removeDoc() {
    setState(() {
      _selectedDoc = null;
      _selectedDocName = '';
      _selectedDocType = '';
    });
  }

  // ─────────────────────────────────────
  // DATE PICKERS
  // ─────────────────────────────────────

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  // ─────────────────────────────────────
  // OPEN DOCUMENT VIEWER
  // ─────────────────────────────────────

  void _openDocument(String url, String? docType, String providerName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentViewerScreen(
          url: url,
          docType: docType ?? 'pdf',
          title: '$providerName Policy',
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // SHOW ADD / EDIT SHEET
  // ─────────────────────────────────────

  void _showAddEditSheet({HealthInsuranceModel? policy}) {
    _editingPolicy = policy;

    if (policy != null) {
      _providerController.text = policy.providerName;
      _policyNumberController.text = policy.policyNumber;
      _coverageController.text = policy.coverageAmount;
      _agentController.text = policy.agentContact;
      _membersController.text = policy.coveredMembers.join(', ');
      _startDate = policy.startDate;
      _endDate = policy.endDate;
    } else {
      _providerController.clear();
      _policyNumberController.clear();
      _coverageController.clear();
      _agentController.clear();
      _membersController.clear();
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 365));
      _selectedDoc = null;
      _selectedDocName = '';
      _selectedDocType = '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildAddEditSheet(),
    );
  }

  // ─────────────────────────────────────
  // SAVE POLICY
  // ─────────────────────────────────────

  Future<void> _savePolicy() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    final members = _membersController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    bool success;

    if (_editingPolicy != null) {
      final updated = _editingPolicy!.copyWith(
        providerName: _providerController.text.trim(),
        policyNumber: _policyNumberController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        coverageAmount: _coverageController.text.trim(),
        agentContact: _agentController.text.trim(),
        coveredMembers: members,
      );
      success = await context.read<HealthInsuranceProvider>().updatePolicy(
        policy: updated,
        newDocFile: _selectedDoc,
        newDocType: _selectedDocType.isNotEmpty ? _selectedDocType : null,
      );
    } else {
      success = await context.read<HealthInsuranceProvider>().addPolicy(
        userId: userId,
        providerName: _providerController.text.trim(),
        policyNumber: _policyNumberController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        coverageAmount: _coverageController.text.trim(),
        agentContact: _agentController.text.trim(),
        coveredMembers: members,
        docFile: _selectedDoc,
        docType: _selectedDocType.isNotEmpty ? _selectedDocType : null,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingPolicy != null ? 'Policy updated!' : 'Policy added!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<HealthInsuranceProvider>().errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ─────────────────────────────────────
  // DELETE POLICY
  // ─────────────────────────────────────

  void _confirmDelete(HealthInsuranceModel policy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Policy', style: AppTextStyles.heading3),
        content: Text(
          'Delete ${policy.providerName} policy? This cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final userId =
                  context.read<AuthProvider>().currentUser?.uid ?? '';
              await context.read<HealthInsuranceProvider>().deletePolicy(
                userId,
                policy.id,
                docType: policy.docType,
              );
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

  // ─────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final insurance = context.watch<HealthInsuranceProvider>();

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
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            Navigator.maybePop(context);
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: r.wp(2)),
                      Text('Health Insurance', style: AppTextStyles.heading2),
                    ],
                  ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: insurance.isLoading
                  ? const LoadingIndicator()
                  : insurance.policies.isEmpty
                  ? EmptyState(
                      message: 'No insurance policies added!',
                      icon: Icons.health_and_safety_outlined,
                      buttonText: 'Add Policy',
                      onButtonTap: () => _showAddEditSheet(),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPolicies,
                      child: ListView.builder(
                        padding: r.pagePadding,
                        itemCount: insurance.policies.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: r.mediumSpace),
                            child: _buildPolicyCard(
                              r,
                              insurance.policies[index],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditSheet(),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: AppColors.textWhite, size: r.mediumIcon),
      ),
    );
  }

  // ─────────────────────────────────────
  // POLICY CARD
  // ─────────────────────────────────────

  Widget _buildPolicyCard(ResponsiveHelper r, HealthInsuranceModel policy) {
    final isActive = policy.isActive;
    final statusColor = isActive ? AppColors.success : AppColors.error;
    final statusText = isActive ? 'Active' : 'Expired';

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Provider + Status ──
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.wp(2)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallRadius),
                ),
                child: Icon(
                  Icons.health_and_safety,
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
                      policy.providerName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Policy: ${policy.policyNumber}',
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallRadius),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(10),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: r.mediumSpace),
          Divider(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.15),
          ),
          SizedBox(height: r.mediumSpace),

          // ── Coverage ──
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: r.smallIcon,
                color: AppColors.primary,
              ),
              SizedBox(width: r.wp(2)),
              Text(
                'Coverage',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '₹${policy.coverageAmount}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: r.smallSpace),

          // ── Dates ──
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: r.smallIcon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: r.wp(2)),
              Text(
                '${_formatDate(policy.startDate)}  →  ${_formatDate(policy.endDate)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: r.smallSpace),

          // ── Agent — tap to call ──
          // ── Agent Contact Card — tap to call ──
          GestureDetector(
            onTap: () => _callAgent(policy.agentContact),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.wp(4),
                vertical: r.hp(1.2),
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(r.mediumRadius),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(r.wp(2)),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.call,
                      color: AppColors.success,
                      size: r.smallIcon,
                    ),
                  ),
                  SizedBox(width: r.wp(3)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insurance Agent',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: r.sp(10),
                          ),
                        ),
                        Text(
                          policy.agentContact,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.wp(3),
                      vertical: r.hp(0.6),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(r.largeRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.call, color: Colors.white, size: r.wp(3.5)),
                        SizedBox(width: r.wp(1)),
                        Text(
                          'Call',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: r.sp(11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Covered Members ──
          if (policy.coveredMembers.isNotEmpty) ...[
            SizedBox(height: r.smallSpace),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.people_outlined,
                  size: r.smallIcon,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: r.wp(2)),
                Expanded(
                  child: Wrap(
                    spacing: r.wp(2),
                    runSpacing: r.hp(0.4),
                    children: policy.coveredMembers.map((member) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.wp(2),
                          vertical: r.hp(0.2),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(r.smallRadius),
                        ),
                        child: Text(
                          member,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: r.sp(10),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: r.mediumSpace),
          Divider(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.15),
          ),
          SizedBox(height: r.smallSpace),

          // ── Document + Edit + Delete ──
          Row(
            children: [
              // View Document
              Expanded(
                child: GestureDetector(
                  onTap: policy.docUrl != null
                      ? () => _openDocument(
                          policy.docUrl!,
                          policy.docType,
                          policy.providerName,
                        )
                      : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: r.hp(1)),
                    decoration: BoxDecoration(
                      color: policy.docUrl != null
                          ? AppColors.primary.withOpacity(0.08)
                          : Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(r.smallRadius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          policy.docUrl != null
                              ? (policy.docType == 'pdf'
                                    ? Icons.picture_as_pdf
                                    : Icons.image_outlined)
                              : Icons.upload_file_outlined,
                          size: r.smallIcon,
                          color: policy.docUrl != null
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: r.wp(1)),
                        Text(
                          policy.docUrl != null
                              ? 'View Document'
                              : 'No document',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: policy.docUrl != null
                                ? AppColors.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            fontWeight: policy.docUrl != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: r.wp(2)),

              // Edit
              IconButton(
                onPressed: () => _showAddEditSheet(policy: policy),
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: r.smallIcon,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: r.wp(8),
                  minHeight: r.wp(8),
                ),
              ),

              // Delete
              IconButton(
                onPressed: () => _confirmDelete(policy),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: r.smallIcon,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: r.wp(8),
                  minHeight: r.wp(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // ADD / EDIT BOTTOM SHEET
  // ─────────────────────────────────────

  Widget _buildAddEditSheet() {
    final r = ResponsiveHelper(context);
    final insurance = context.watch<HealthInsuranceProvider>();
    final isEdit = _editingPolicy != null;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: r.pagePadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: r.mediumSpace),

                  // Handle bar
                  Center(
                    child: Container(
                      width: r.wp(10),
                      height: r.hp(0.5),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(r.smallRadius),
                      ),
                    ),
                  ),

                  SizedBox(height: r.mediumSpace),
                  Text(
                    isEdit ? 'Edit Policy' : 'Add Insurance Policy',
                    style: AppTextStyles.heading2,
                  ),
                  SizedBox(height: r.mediumSpace),

                  // Provider Name
                  CustomTextField(
                    controller: _providerController,
                    label: 'Insurance Provider',
                    prefixIcon: Icons.business_outlined,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Provider name required!'
                        : null,
                  ),
                  SizedBox(height: r.mediumSpace),

                  // Policy Number
                  CustomTextField(
                    controller: _policyNumberController,
                    label: 'Policy Number',
                    prefixIcon: Icons.numbers,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Policy number required!'
                        : null,
                  ),
                  SizedBox(height: r.mediumSpace),

                  // Coverage
                  CustomTextField(
                    controller: _coverageController,
                    label: 'Coverage Amount (e.g. 10 Lakh)',
                    prefixIcon: Icons.currency_rupee,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Coverage amount required!'
                        : null,
                  ),
                  SizedBox(height: r.mediumSpace),

                  // Start Date
                  Text('Start Date', style: AppTextStyles.label),
                  SizedBox(height: r.smallSpace),
                  _buildDateTile(
                    r,
                    date: _startDate,
                    onTap: () async {
                      await _pickStartDate();
                      setSheetState(() {});
                    },
                  ),
                  SizedBox(height: r.mediumSpace),

                  // End Date
                  Text('End Date', style: AppTextStyles.label),
                  SizedBox(height: r.smallSpace),
                  _buildDateTile(
                    r,
                    date: _endDate,
                    onTap: () async {
                      await _pickEndDate();
                      setSheetState(() {});
                    },
                  ),
                  SizedBox(height: r.mediumSpace),

                  // Agent Contact
                  CustomTextField(
                    controller: _agentController,
                    label: 'Agent Contact Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Agent contact required!'
                        : null,
                  ),
                  SizedBox(height: r.mediumSpace),

                  // Covered Members
                  CustomTextField(
                    controller: _membersController,
                    label: 'Covered Members (comma separated)',
                    prefixIcon: Icons.people_outlined,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Add at least one member!'
                        : null,
                  ),
                  SizedBox(height: r.hp(0.5)),
                  Text(
                    'Example: Self, Maa, Papa',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: r.sp(10),
                    ),
                  ),
                  SizedBox(height: r.mediumSpace),

                  // Document Upload
                  Text(
                    'Policy Document (Optional)',
                    style: AppTextStyles.label,
                  ),
                  SizedBox(height: r.smallSpace),

                  if (_selectedDoc != null) ...[
                    Container(
                      padding: r.cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedDocType == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            color: AppColors.success,
                            size: r.smallIcon,
                          ),
                          SizedBox(width: r.wp(3)),
                          Expanded(
                            child: Text(
                              _selectedDocName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.success,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setSheetState(() => _removeDoc()),
                            icon: Icon(
                              Icons.close,
                              size: r.wp(4),
                              color: AppColors.error,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ] else if (isEdit && _editingPolicy?.docUrl != null) ...[
                    Container(
                      padding: r.cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            color: AppColors.primary,
                            size: r.smallIcon,
                          ),
                          SizedBox(width: r.wp(2)),
                          Expanded(
                            child: Text(
                              'Document attached. Upload new to replace.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: r.smallSpace),
                    GestureDetector(
                      onTap: () async {
                        await _pickDocument();
                        setSheetState(() {});
                      },
                      child: Text(
                        'Upload new document',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: () async {
                        await _pickDocument();
                        setSheetState(() {});
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: r.hp(2.5)),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(r.mediumRadius),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: r.mediumIcon,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: r.smallSpace),
                            Text(
                              'Tap to upload PDF or Image',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Supported: PDF, JPG, PNG',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: r.sp(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: r.largeSpace),

                  CustomButton(
                    text: insurance.isUploading
                        ? 'Uploading...'
                        : isEdit
                        ? 'Update Policy'
                        : 'Save Policy',
                    onPressed: _savePolicy,
                    isLoading: insurance.isLoading || insurance.isUploading,
                    icon: Icons.save,
                  ),

                  SizedBox(height: r.largeSpace),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────

  Widget _buildDateTile(
    ResponsiveHelper r, {
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.wp(4), vertical: r.hp(1.8)),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(r.mediumRadius),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              size: r.smallIcon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: r.wp(3)),
            Text(_formatDate(date), style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
