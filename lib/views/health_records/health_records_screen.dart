import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_record_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import 'health_record_detail_screen.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'All';
  File? _selectedFile;
  String _selectedFileName = '';
  String _selectedFileType = '';

  final List<String> _categories = [
    'All',
    'Report',
    'Prescription',
    'Scan',
    'Bill',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadRecords());
  }

  Future<void> _loadRecords() async {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (userId.isEmpty) return;
    await context.read<HealthRecordProvider>().getHealthRecords(userId);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────
  // FILE PICKER — file_picker 8.1.2
  // ─────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final extension = result.files.single.extension?.toLowerCase() ?? '';
      final fileType = extension == 'pdf' ? 'pdf' : 'image';

      setState(() {
        _selectedFile = file;
        _selectedFileName = fileName;
        _selectedFileType = fileType;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = '';
      _selectedFileType = '';
    });
  }

  void _showAddRecordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildAddRecordSheet(),
    );
  }

  // ─────────────────────────────────────
  // SAVE RECORD
  // ─────────────────────────────────────

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file to upload!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    final category = _selectedCategory == 'All' ? 'Report' : _selectedCategory;

    final success = await context.read<HealthRecordProvider>().addHealthRecord(
      userId: userId,
      title: _titleController.text.trim(),
      category: category,
      file: _selectedFile!,
      fileType: _selectedFileType,
      notes: _notesController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      _titleController.clear();
      _notesController.clear();
      _removeFile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record uploaded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<HealthRecordProvider>().errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final records = context.watch<HealthRecordProvider>();

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Health Records', style: AppTextStyles.heading2),
                      IconButton(
                        onPressed: _showAddRecordSheet,
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

                  // ── Category filter chips ──
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: EdgeInsets.only(right: r.wp(2)),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategory = category);
                              records.setCategory(
                                category == 'All' ? '' : category,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: r.wp(4),
                                vertical: r.hp(0.8),
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(
                                  r.largeRadius,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                category,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isSelected
                                      ? AppColors.textWhite
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Records List ──
            Expanded(
              child: records.isLoading
                  ? const LoadingIndicator()
                  : records.filteredRecords.isEmpty
                  ? EmptyState(
                      message: 'No health records found!',
                      icon: Icons.folder_outlined,
                      buttonText: 'Add Record',
                      onButtonTap: _showAddRecordSheet,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRecords,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.wp(6),
                          vertical: r.hp(1),
                        ),
                        itemCount: records.filteredRecords.length,
                        itemBuilder: (context, index) {
                          final record = records.filteredRecords[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: r.smallSpace),
                            child: CustomCard(
                              // ── FIX: onTap → detail screen ──
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HealthRecordDetailScreen(record: record),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Category icon
                                  Container(
                                    padding: EdgeInsets.all(r.wp(3)),
                                    decoration: BoxDecoration(
                                      color: _categoryColor(
                                        record.category,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        r.smallRadius,
                                      ),
                                    ),
                                    child: Icon(
                                      _categoryIcon(record.category),
                                      color: _categoryColor(record.category),
                                      size: r.smallIcon,
                                    ),
                                  ),

                                  SizedBox(width: r.wp(3)),

                                  // Title + Meta
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record.title,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: r.hp(0.3)),
                                        Row(
                                          children: [
                                            Text(
                                              record.category,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color: _categoryColor(
                                                      record.category,
                                                    ),
                                                  ),
                                            ),
                                            SizedBox(width: r.wp(2)),
                                            if (record.fileType.isNotEmpty)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: r.wp(2),
                                                  vertical: r.hp(0.2),
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      record.fileType == 'pdf'
                                                      ? AppColors.error
                                                            .withOpacity(0.1)
                                                      : AppColors.success
                                                            .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        r.smallRadius,
                                                      ),
                                                ),
                                                child: Text(
                                                  record.fileType.toUpperCase(),
                                                  style: AppTextStyles.bodySmall
                                                      .copyWith(
                                                        color:
                                                            record.fileType ==
                                                                'pdf'
                                                            ? AppColors.error
                                                            : AppColors.success,
                                                        fontSize: r.sp(9),
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (record.notes != null &&
                                            record.notes!.isNotEmpty) ...[
                                          SizedBox(height: r.hp(0.3)),
                                          Text(
                                            record.notes!,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Sync + Delete + Arrow
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        record.isSynced
                                            ? Icons.cloud_done
                                            : Icons.cloud_off_outlined,
                                        size: r.wp(4),
                                        color: record.isSynced
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                      SizedBox(height: r.hp(0.5)),
                                      IconButton(
                                        onPressed: () =>
                                            _confirmDelete(context, r, record),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                          size: r.smallIcon,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecordSheet,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: AppColors.textWhite, size: r.mediumIcon),
      ),
    );
  }

  // ─────────────────────────────────────
  // ADD RECORD BOTTOM SHEET
  // ─────────────────────────────────────

  Widget _buildAddRecordSheet() {
    final r = ResponsiveHelper(context);
    final records = context.watch<HealthRecordProvider>();
    String sheetCategory = 'Report';

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
                  Text('Add Health Record', style: AppTextStyles.heading2),
                  SizedBox(height: r.mediumSpace),

                  // Title
                  CustomTextField(
                    controller: _titleController,
                    label: 'Record Title',
                    prefixIcon: Icons.title,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title is required!';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: r.mediumSpace),

                  // Category chips
                  Text('Category', style: AppTextStyles.label),
                  SizedBox(height: r.smallSpace),
                  Wrap(
                    spacing: r.wp(2),
                    runSpacing: r.hp(0.5),
                    children:
                        [
                          'Report',
                          'Prescription',
                          'Scan',
                          'Bill',
                          'Other',
                        ].map((cat) {
                          final isSelected = sheetCategory == cat;
                          return GestureDetector(
                            onTap: () =>
                                setSheetState(() => sheetCategory = cat),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: r.wp(4),
                                vertical: r.hp(0.8),
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _categoryColor(cat)
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(
                                  r.largeRadius,
                                ),
                                border: Border.all(color: _categoryColor(cat)),
                              ),
                              child: Text(
                                cat,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isSelected
                                      ? AppColors.textWhite
                                      : _categoryColor(cat),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),

                  SizedBox(height: r.mediumSpace),

                  // File picker
                  Text('Upload File', style: AppTextStyles.label),
                  SizedBox(height: r.smallSpace),

                  if (_selectedFile != null)
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
                            _selectedFileType == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            color: AppColors.success,
                            size: r.smallIcon,
                          ),
                          SizedBox(width: r.wp(3)),
                          Expanded(
                            child: Text(
                              _selectedFileName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.success,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setSheetState(() => _removeFile()),
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
                    )
                  else
                    GestureDetector(
                      onTap: () async {
                        await _pickFile();
                        setSheetState(() {});
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: r.hp(3)),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
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
                              'Tap to select PDF or Image',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: r.hp(0.5)),
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

                  SizedBox(height: r.mediumSpace),

                  // Notes
                  CustomTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    prefixIcon: Icons.notes,
                    maxLines: 3,
                  ),

                  SizedBox(height: r.mediumSpace),

                  // Info banner
                  Container(
                    padding: r.cardPadding,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: r.smallIcon,
                        ),
                        SizedBox(width: r.wp(2)),
                        Expanded(
                          child: Text(
                            'File will be uploaded to Firebase Storage. Internet required!',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: r.largeSpace),

                  // Save button
                  CustomButton(
                    text: records.isUploading
                        ? 'Uploading...'
                        : 'Upload & Save',
                    onPressed: _saveRecord,
                    isLoading: records.isLoading || records.isUploading,
                    icon: Icons.cloud_upload,
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
  // DELETE CONFIRMATION
  // ─────────────────────────────────────

  void _confirmDelete(
    BuildContext context,
    ResponsiveHelper r,
    dynamic record,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Record', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to delete "${record.title}"?',
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
              await context.read<HealthRecordProvider>().deleteHealthRecord(
                userId,
                record.id,
                record.fileUrl,
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
  // HELPERS
  // ─────────────────────────────────────

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'report':
        return AppColors.primary;
      case 'prescription':
        return AppColors.secondary;
      case 'scan':
        return AppColors.success;
      case 'bill':
        return AppColors.warning;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'report':
        return Icons.description_outlined;
      case 'prescription':
        return Icons.medication_outlined;
      case 'scan':
        return Icons.document_scanner_outlined;
      case 'bill':
        return Icons.receipt_outlined;
      default:
        return Icons.folder_outlined;
    }
  }
}
