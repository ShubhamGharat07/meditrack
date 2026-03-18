import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/family_member_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_header.dart';

class AddEditFamilyMemberScreen extends StatefulWidget {
  final String? memberId; // null = add mode, non-null = edit mode

  const AddEditFamilyMemberScreen({super.key, this.memberId});

  @override
  State<AddEditFamilyMemberScreen> createState() =>
      _AddEditFamilyMemberScreenState();
}

class _AddEditFamilyMemberScreenState extends State<AddEditFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDob;
  String? _selectedBloodGroup;

  // Medical
  final _allergiesController = TextEditingController(); // comma-separated
  final _conditionsController = TextEditingController(); // comma-separated

  // Emergency
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // Insurance
  final _insuranceProviderController = TextEditingController();
  final _insurancePolicyController = TextEditingController();
  DateTime? _insuranceExpiry;

  // Files
  File? _photo;
  File? _insuranceDoc;
  String? _insuranceDocType;

  // Existing URLs in edit mode
  String? _existingPhotoUrl;
  String? _existingInsuranceDocUrl;

  bool get _isEditMode => widget.memberId != null;
  FamilyMemberModel? _existingMember;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final family = context.read<FamilyProvider>();
    _existingMember = family.members.firstWhere(
      (m) => m.id == widget.memberId,
      orElse: () => family.members.first,
    );

    if (_existingMember == null) return;
    final m = _existingMember!;

    _nameController.text = m.name;
    _relationController.text = m.relation;
    _ageController.text = m.age?.toString() ?? '';
    _selectedGender = m.gender;
    _selectedDob = m.dob;
    _selectedBloodGroup = m.bloodGroup;
    _existingPhotoUrl = m.photoUrl;
    _allergiesController.text = m.allergies?.join(', ') ?? '';
    _conditionsController.text = m.medicalConditions?.join(', ') ?? '';
    _emergencyNameController.text = m.emergencyContactName ?? '';
    _emergencyPhoneController.text = m.emergencyContact ?? '';
    _insuranceProviderController.text = m.insuranceProvider ?? '';
    _insurancePolicyController.text = m.insurancePolicyNumber ?? '';
    _insuranceExpiry = m.insuranceExpiry;
    _existingInsuranceDocUrl = m.insuranceDocUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _ageController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyController.dispose();
    super.dispose();
  }

  // Pick photo
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  // Pick insurance doc
  Future<void> _pickInsuranceDoc() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final ext = result.files.single.extension?.toLowerCase() ?? '';
      setState(() {
        _insuranceDoc = File(result.files.single.path!);
        _insuranceDocType = ext == 'pdf' ? 'pdf' : 'image';
      });
    }
  }

  // DOB picker
  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        // Age auto-calculate
        final age = DateTime.now().year - picked.year;
        _ageController.text = age.toString();
      });
    }
  }

  // Insurance expiry picker
  Future<void> _pickInsuranceExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _insuranceExpiry ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _insuranceExpiry = picked);
  }

  // Parse comma-separated list
  List<String>? _parseList(String text) {
    if (text.trim().isEmpty) return null;
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    final family = context.read<FamilyProvider>();
    bool success;

    if (_isEditMode && _existingMember != null) {
      // Edit mode
      final updatedMember = _existingMember!.copyWith(
        name: _nameController.text.trim(),
        relation: _relationController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        dob: _selectedDob,
        bloodGroup: _selectedBloodGroup,
        allergies: _parseList(_allergiesController.text),
        medicalConditions: _parseList(_conditionsController.text),
        emergencyContactName: _emergencyNameController.text.trim().isEmpty
            ? null
            : _emergencyNameController.text.trim(),
        emergencyContact: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        insuranceProvider: _insuranceProviderController.text.trim().isEmpty
            ? null
            : _insuranceProviderController.text.trim(),
        insurancePolicyNumber: _insurancePolicyController.text.trim().isEmpty
            ? null
            : _insurancePolicyController.text.trim(),
        insuranceExpiry: _insuranceExpiry,
      );

      success = await family.updateFamilyMember(
        userId: userId,
        member: updatedMember,
        newPhoto: _photo,
        newInsuranceDoc: _insuranceDoc,
        insuranceDocType: _insuranceDocType,
      );
    } else {
      // Add mode
      success = await family.addFamilyMember(
        userId: userId,
        name: _nameController.text.trim(),
        relation: _relationController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        dob: _selectedDob,
        bloodGroup: _selectedBloodGroup,
        photo: _photo,
        allergies: _parseList(_allergiesController.text),
        medicalConditions: _parseList(_conditionsController.text),
        emergencyContactName: _emergencyNameController.text.trim().isEmpty
            ? null
            : _emergencyNameController.text.trim(),
        emergencyContact: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        insuranceProvider: _insuranceProviderController.text.trim().isEmpty
            ? null
            : _insuranceProviderController.text.trim(),
        insurancePolicyNumber: _insurancePolicyController.text.trim().isEmpty
            ? null
            : _insurancePolicyController.text.trim(),
        insuranceExpiry: _insuranceExpiry,
        insuranceDoc: _insuranceDoc,
        insuranceDocType: _insuranceDocType,
      );
    }

    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(family.errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final family = context.watch<FamilyProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditMode ? 'Edit Member' : 'Add Family Member',
          style: AppTextStyles.heading3,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: r.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.mediumSpace),

              // ── PHOTO ──
              _buildPhotoSection(r),
              SizedBox(height: r.largeSpace),

              // ── BASIC INFO ──
              const SectionHeader(title: 'Basic Info'),
              SizedBox(height: r.mediumSpace),
              _buildBasicInfoSection(r),
              SizedBox(height: r.largeSpace),

              // ── MEDICAL INFO ──
              const SectionHeader(title: 'Medical Info'),
              SizedBox(height: r.mediumSpace),
              _buildMedicalSection(r),
              SizedBox(height: r.largeSpace),

              // ── EMERGENCY CONTACT ──
              const SectionHeader(title: 'Emergency Contact'),
              SizedBox(height: r.mediumSpace),
              _buildEmergencySection(r),
              SizedBox(height: r.largeSpace),

              // ── INSURANCE ──
              const SectionHeader(title: 'Health Insurance'),
              SizedBox(height: r.mediumSpace),
              _buildInsuranceSection(r),
              SizedBox(height: r.largeSpace),

              // ── SAVE BUTTON ──
              CustomButton(
                text: _isEditMode ? 'Update Member' : 'Add Member',
                onPressed: _save,
                isLoading: family.isLoading,
              ),
              SizedBox(height: r.largeSpace),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // PHOTO SECTION
  // ─────────────────────────────────────

  Widget _buildPhotoSection(ResponsiveHelper r) {
    return Center(
      child: GestureDetector(
        onTap: _pickPhoto,
        child: Stack(
          children: [
            CircleAvatar(
              radius: r.wp(15),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: _photo != null
                  ? FileImage(_photo!)
                  : (_existingPhotoUrl != null
                        ? NetworkImage(_existingPhotoUrl!) as ImageProvider
                        : null),
              child: (_photo == null && _existingPhotoUrl == null)
                  ? Icon(Icons.person, size: r.wp(12), color: AppColors.primary)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(r.wp(2)),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.textWhite,
                  size: r.wp(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // BASIC INFO SECTION
  // ─────────────────────────────────────

  Widget _buildBasicInfoSection(ResponsiveHelper r) {
    return Column(
      children: [
        // Name
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration(r, 'Full Name *', Icons.person_outlined),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Name is required!' : null,
        ),
        SizedBox(height: r.mediumSpace),

        // Relation
        TextFormField(
          controller: _relationController,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration(
            r,
            'Relation (e.g. Mother, Son) *',
            Icons.people_outlined,
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Relation is required!' : null,
        ),
        SizedBox(height: r.mediumSpace),

        // Gender
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: _inputDecoration(r, 'Gender', Icons.wc),
          items: _genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGender = v),
        ),
        SizedBox(height: r.mediumSpace),

        // DOB
        GestureDetector(
          onTap: _pickDob,
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(
                text: _selectedDob != null
                    ? DateFormatter.formatDate(_selectedDob!)
                    : '',
              ),
              decoration: _inputDecoration(
                r,
                'Date of Birth',
                Icons.calendar_today_outlined,
              ),
            ),
          ),
        ),
        SizedBox(height: r.mediumSpace),

        // Age
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(r, 'Age', Icons.cake_outlined),
        ),
        SizedBox(height: r.mediumSpace),

        // Blood Group
        DropdownButtonFormField<String>(
          value: _selectedBloodGroup,
          decoration: _inputDecoration(
            r,
            'Blood Group',
            Icons.bloodtype_outlined,
          ),
          items: _bloodGroups
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
          onChanged: (v) => setState(() => _selectedBloodGroup = v),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // MEDICAL SECTION
  // ─────────────────────────────────────

  Widget _buildMedicalSection(ResponsiveHelper r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _allergiesController,
          decoration: _inputDecoration(
            r,
            'Allergies (comma separated)',
            Icons.warning_amber_outlined,
          ).copyWith(hintText: 'e.g. Penicillin, Dust, Peanuts'),
          maxLines: 2,
        ),
        SizedBox(height: r.mediumSpace),
        TextFormField(
          controller: _conditionsController,
          decoration: _inputDecoration(
            r,
            'Medical Conditions (comma separated)',
            Icons.medical_information_outlined,
          ).copyWith(hintText: 'e.g. Diabetes, Hypertension'),
          maxLines: 2,
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // EMERGENCY SECTION
  // ─────────────────────────────────────

  Widget _buildEmergencySection(ResponsiveHelper r) {
    return Column(
      children: [
        TextFormField(
          controller: _emergencyNameController,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration(
            r,
            'Contact Name',
            Icons.person_pin_outlined,
          ),
        ),
        SizedBox(height: r.mediumSpace),
        TextFormField(
          controller: _emergencyPhoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(
            r,
            'Contact Phone Number',
            Icons.phone_outlined,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // INSURANCE SECTION
  // ─────────────────────────────────────

  Widget _buildInsuranceSection(ResponsiveHelper r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _insuranceProviderController,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration(
            r,
            'Insurance Provider',
            Icons.shield_outlined,
          ),
          // e.g. Star Health, LIC, HDFC ERGO
        ),
        SizedBox(height: r.mediumSpace),

        TextFormField(
          controller: _insurancePolicyController,
          decoration: _inputDecoration(
            r,
            'Policy Number',
            Icons.numbers_outlined,
          ),
        ),
        SizedBox(height: r.mediumSpace),

        // Expiry date
        GestureDetector(
          onTap: _pickInsuranceExpiry,
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(
                text: _insuranceExpiry != null
                    ? DateFormatter.formatDate(_insuranceExpiry!)
                    : '',
              ),
              decoration: _inputDecoration(
                r,
                'Policy Expiry Date',
                Icons.event_outlined,
              ),
            ),
          ),
        ),
        SizedBox(height: r.mediumSpace),

        // Insurance doc upload
        GestureDetector(
          onTap: _pickInsuranceDoc,
          child: Container(
            padding: EdgeInsets.all(r.wp(4)),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(r.mediumRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  color: AppColors.primary,
                  size: r.smallIcon,
                ),
                SizedBox(width: r.wp(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insurance Document',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _insuranceDoc != null
                            ? _insuranceDoc!.path.split('/').last
                            : (_existingInsuranceDocUrl != null
                                  ? 'Existing doc (tap to replace)'
                                  : 'Upload PDF or Image'),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _insuranceDoc != null
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_insuranceDoc != null || _existingInsuranceDocUrl != null)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: r.smallIcon,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    ResponsiveHelper r,
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: r.smallIcon, color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r.mediumRadius),
        borderSide: const BorderSide(color: AppColors.textSecondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r.mediumRadius),
        borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r.mediumRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: r.wp(4),
        vertical: r.hp(2),
      ),
    );
  }
}
