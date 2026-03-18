import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase/firestore_service.dart';
import '../../services/firebase/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();

  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  String? _selectedBloodGroup;
  File? _pickedImage;
  bool _isLoading = false;

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
    _prefillData();
  }

  void _prefillData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    _nameController.text = user.name;
    _phoneController.text = user.phone ?? '';
    _ageController.text = user.age?.toString() ?? '';
    _selectedBloodGroup = user.bloodGroup;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // ── Pick photo from gallery or camera ──
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close bottom sheet
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Profile Photo', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text('Camera', style: AppTextStyles.bodyMedium),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.secondary,
                  ),
                ),
                title: Text('Gallery', style: AppTextStyles.bodyMedium),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              if (context.read<AuthProvider>().currentUser?.photoUrl != null ||
                  _pickedImage != null) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                  ),
                  title: Text('Remove Photo', style: AppTextStyles.bodyMedium),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _pickedImage = null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Save to Firestore ──
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final user = auth.currentUser!;

      String? photoUrl = user.photoUrl;

      // Upload new photo if picked
      if (_pickedImage != null) {
        photoUrl = await _storageService.uploadProfilePhoto(
          user.uid,
          _pickedImage!,
        );
      }

      // Build update map
      final updateData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'age': _ageController.text.trim().isEmpty
            ? null
            : int.tryParse(_ageController.text.trim()),
        'bloodGroup': _selectedBloodGroup,
        'photoUrl': photoUrl,
      };

      // Save to Firestore
      await _firestoreService.updateUser(user.uid, updateData);

      // Update local state — notify AuthProvider
      final updatedUser = UserModel(
        uid: user.uid,
        name: _nameController.text.trim(),
        email: user.email,
        photoUrl: photoUrl,
        bloodGroup: _selectedBloodGroup,
        age: _ageController.text.trim().isEmpty
            ? null
            : int.tryParse(_ageController.text.trim()),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        isBlocked: user.isBlocked,
        createdAt: user.createdAt,
      );

      auth.updateCurrentUser(updatedUser);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: r.mediumSpace),

                // ── Profile Photo ──
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _showImagePickerSheet,
                        child: Container(
                          width: r.wp(26),
                          height: r.wp(26),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _pickedImage != null
                                ? Image.file(_pickedImage!, fit: BoxFit.cover)
                                : user?.photoUrl != null
                                ? Image.network(
                                    user!.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _avatarFallback(user),
                                  )
                                : _avatarFallback(user),
                          ),
                        ),
                      ),
                      // Camera icon badge
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImagePickerSheet,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: r.smallSpace),
                    child: Text(
                      'Tap to change photo',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ),

                SizedBox(height: r.largeSpace),

                // ── Fields heading ──
                Text('Personal Info', style: AppTextStyles.heading3),
                SizedBox(height: r.mediumSpace),

                // ── Name ──
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required!';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters!';
                    }
                    return null;
                  },
                ),

                SizedBox(height: r.mediumSpace),

                // ── Phone ──
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number (optional)',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length < 10) {
                        return 'Enter a valid phone number!';
                      }
                    }
                    return null;
                  },
                ),

                SizedBox(height: r.mediumSpace),

                // ── Age ──
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age (optional)',
                    prefixIcon: const Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final age = int.tryParse(value.trim());
                      if (age == null || age < 1 || age > 120) {
                        return 'Enter a valid age (1-120)!';
                      }
                    }
                    return null;
                  },
                ),

                SizedBox(height: r.mediumSpace),

                // ── Blood Group ──
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: InputDecoration(
                    labelText: 'Blood Group (optional)',
                    prefixIcon: const Icon(Icons.bloodtype_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'Not specified',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ..._bloodGroups.map(
                      (bg) => DropdownMenuItem(
                        value: bg,
                        child: Text(bg, style: AppTextStyles.bodyMedium),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedBloodGroup = value),
                ),

                SizedBox(height: r.mediumSpace),

                // ── Email (read-only) ──
                TextFormField(
                  initialValue: user?.email ?? '',
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: const Icon(Icons.lock_outline, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.4),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: r.smallSpace),

                Padding(
                  padding: EdgeInsets.only(left: r.wp(1)),
                  child: Text(
                    'Email address cannot be changed.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),

                SizedBox(height: r.largeSpace),

                // ── Save Button ──
                SizedBox(
                  width: double.infinity,
                  height: r.hp(7),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(
                        0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text('Save Changes', style: AppTextStyles.button),
                  ),
                ),

                SizedBox(height: r.largeSpace),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback(UserModel? user) {
    return Center(
      child: Text(
        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
        style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
      ),
    );
  }
}
