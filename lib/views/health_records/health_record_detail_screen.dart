import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/health_record_model.dart';

class HealthRecordDetailScreen extends StatefulWidget {
  final HealthRecordModel record;

  const HealthRecordDetailScreen({super.key, required this.record});

  @override
  State<HealthRecordDetailScreen> createState() =>
      _HealthRecordDetailScreenState();
}

class _HealthRecordDetailScreenState extends State<HealthRecordDetailScreen> {
  // For PDF
  String? _localPdfPath;
  bool _isPdfLoading = false;
  bool _pdfError = false;

  // PDF page tracking
  int _currentPage = 0;
  int _totalPages = 0;
  PDFViewController? _pdfController;

  @override
  void initState() {
    super.initState();
    if (widget.record.fileType == 'pdf') {
      _downloadAndLoadPdf();
    }
  }

  // ─────────────────────────────────────
  // PDF DOWNLOAD — from Firebase URL to local temp file
  // flutter_pdfview 1.4.4 — requires filePath, URL doesn't work directly
  // ─────────────────────────────────────

  Future<void> _downloadAndLoadPdf() async {
    if (widget.record.fileUrl.isEmpty) return;

    setState(() {
      _isPdfLoading = true;
      _pdfError = false;
    });

    try {
      final response = await http
          .get(Uri.parse(widget.record.fileUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Save to temp directory
        final tempDir = await getTemporaryDirectory();
        final fileName = 'meditrack_record_${widget.record.id}.pdf';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          setState(() {
            _localPdfPath = file.path;
            _isPdfLoading = false;
          });
        }
      } else {
        debugPrint('PDF download failed: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isPdfLoading = false;
            _pdfError = true;
          });
        }
      }
    } catch (e) {
      debugPrint('PDF download error: $e');
      if (mounted) {
        setState(() {
          _isPdfLoading = false;
          _pdfError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final record = widget.record;
    final isPdf = record.fileType == 'pdf';

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for viewer
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          record.title,
          style: AppTextStyles.heading3,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // PDF page counter — show in AppBar
        actions: [
          if (isPdf && _totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Info Banner ──
          _buildInfoBanner(r, record),

          // ── File Viewer — PDF ya Image ──
          Expanded(
            child: isPdf ? _buildPdfViewer(r) : _buildImageViewer(r, record),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // INFO BANNER
  // ─────────────────────────────────────

  Widget _buildInfoBanner(ResponsiveHelper r, HealthRecordModel record) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(horizontal: r.wp(4), vertical: r.hp(1.5)),
      child: Row(
        children: [
          // Category icon
          Container(
            padding: EdgeInsets.all(r.wp(2)),
            decoration: BoxDecoration(
              color: _categoryColor(record.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.smallRadius),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: r.hp(0.3)),
                Row(
                  children: [
                    _buildBadge(
                      record.category,
                      _categoryColor(record.category),
                    ),
                    SizedBox(width: r.wp(2)),
                    _buildBadge(
                      record.fileType.toUpperCase(),
                      record.fileType == 'pdf'
                          ? AppColors.error
                          : AppColors.success,
                    ),
                    SizedBox(width: r.wp(2)),
                    Text(
                      DateFormatter.formatDate(record.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  SizedBox(height: r.hp(0.3)),
                  Text(
                    record.notes!,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: r.wp(2)),

          // Sync status
          Icon(
            record.isSynced ? Icons.cloud_done : Icons.cloud_off_outlined,
            size: r.wp(5),
            color: record.isSynced ? AppColors.success : AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // PDF VIEWER — flutter_pdfview 1.4.4
  // ─────────────────────────────────────

  Widget _buildPdfViewer(ResponsiveHelper r) {
    // Loading state
    if (_isPdfLoading) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: r.mediumSpace),
              Text(
                'Loading PDF...',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_pdfError || _localPdfPath == null) {
      return _buildErrorState(
        r,
        title: 'Could not load PDF',
        subtitle: 'Please check your internet and retry',
        icon: Icons.picture_as_pdf,
        color: AppColors.error,
        onRetry: _downloadAndLoadPdf,
      );
    }

    // PDF Viewer — flutter_pdfview 1.4.4 API
    return PDFView(
      filePath: _localPdfPath!,
      enableSwipe: true,
      swipeHorizontal: false, // Vertical scroll
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      defaultPage: 0,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      backgroundColor: Colors.black,
      onRender: (pages) {
        if (mounted) {
          setState(() => _totalPages = pages ?? 0);
        }
      },
      onViewCreated: (controller) {
        _pdfController = controller;
      },
      onPageChanged: (page, total) {
        if (mounted) {
          setState(() {
            _currentPage = page ?? 0;
            _totalPages = total ?? 0;
          });
        }
      },
      onError: (error) {
        debugPrint('PDFView error: $error');
        if (mounted) {
          setState(() {
            _pdfError = true;
            _localPdfPath = null;
          });
        }
      },
      onPageError: (page, error) {
        debugPrint('PDFView page $page error: $error');
      },
    );
  }

  // ─────────────────────────────────────
  // IMAGE VIEWER — cached_network_image 3.4.1 + pinch to zoom
  // ─────────────────────────────────────

  Widget _buildImageViewer(ResponsiveHelper r, HealthRecordModel record) {
    if (record.fileUrl.isEmpty) {
      return _buildErrorState(
        r,
        title: 'File URL missing',
        subtitle: 'File URL is missing in the record',
        icon: Icons.image_not_supported,
        color: AppColors.warning,
      );
    }

    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: record.fileUrl,
          fit: BoxFit.contain,
          // cached_network_image 3.4.1
          placeholder: (context, url) => Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: r.mediumSpace),
                  Text(
                    'Loading image...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildErrorState(
            r,
            title: 'Could not load image',
            subtitle: 'Please check your internet and retry',
            icon: Icons.broken_image_outlined,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // ERROR STATE
  // ─────────────────────────────────────

  Widget _buildErrorState(
    ResponsiveHelper r, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onRetry,
  }) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: color),
              ),
              SizedBox(height: r.largeSpace),
              Text(
                title,
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.smallSpace),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                SizedBox(height: r.largeSpace),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: Text('Retry', style: AppTextStyles.button),
                ),
              ],
            ],
          ),
        ),
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
