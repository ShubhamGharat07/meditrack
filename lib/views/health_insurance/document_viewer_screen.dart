import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:media_scanner/media_scanner.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/utils/responsive_helper.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String url;
  final String docType;
  final String title;

  const DocumentViewerScreen({
    super.key,
    required this.url,
    required this.docType,
    required this.title,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  String? _localPdfPath;
  bool _isLoadingPdf = true;
  bool _isDownloading = false;
  bool _isSharing = false;
  int _currentPage = 0;
  int _totalPages = 0;
  String? _lastDownloadedPath;

  final FlutterLocalNotificationsPlugin _notifPlugin =
      FlutterLocalNotificationsPlugin();

  static const int _downloadNotifId = 77777;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    if (widget.docType == 'pdf') {
      _loadPdf();
    }
  }

  // ─────────────────────────────────────
  // INIT NOTIFICATIONS
  // ─────────────────────────────────────

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('🔔 Notification tapped: ${details.payload}');
        if (details.payload != null && details.payload!.isNotEmpty) {
          OpenFile.open(details.payload!);
        } else if (_lastDownloadedPath != null) {
          OpenFile.open(_lastDownloadedPath!);
        }
      },
    );
    debugPrint('✅ DocumentViewer notifications initialized');
  }

  // ─────────────────────────────────────
  // ANDROID SDK VERSION — device_info_plus
  // ─────────────────────────────────────

  Future<int> _getAndroidSdkVersion() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdk = androidInfo.version.sdkInt;
      debugPrint('📱 Android SDK version: $sdk');
      return sdk;
    } catch (e) {
      debugPrint('⚠️ Could not get SDK version: $e — defaulting to 29');
      return 29;
    }
  }

  // ─────────────────────────────────────
  // PERMISSION CHECK
  // Only needed for Android 9 (API 28) and below
  // ─────────────────────────────────────

  Future<bool> _checkStoragePermission() async {
    if (!Platform.isAndroid) {
      debugPrint('📱 Not Android — no permission needed');
      return true;
    }

    final sdk = await _getAndroidSdkVersion();

    if (sdk >= 29) {
      // Android 10+ — no storage permission needed
      debugPrint('✅ Android 10+ (SDK $sdk) — storage permission not required');
      return true;
    }

    // Android 9 and below
    debugPrint('🔐 Android $sdk — checking storage permission...');
    final status = await Permission.storage.status;
    debugPrint('🔐 Current storage permission status: $status');

    if (status.isGranted) {
      debugPrint('✅ Storage permission already granted');
      return true;
    }

    final result = await Permission.storage.request();
    debugPrint('🔐 Storage permission request result: $result');

    if (result.isGranted) {
      return true;
    }

    debugPrint('❌ Storage permission denied');
    return false;
  }

  // ─────────────────────────────────────
  // LOAD PDF — cache in temp directory for the viewer
  // ─────────────────────────────────────

  Future<void> _loadPdf() async {
    try {
      debugPrint('📄 Loading PDF from: ${widget.url}');
      setState(() => _isLoadingPdf = true);

      final response = await http.get(Uri.parse(widget.url));
      debugPrint('📄 PDF response status: ${response.statusCode}');
      debugPrint('📄 PDF size: ${response.bodyBytes.length} bytes');

      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final safeTitle = widget.title.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final file = File('${dir.path}/$safeTitle.pdf');
      await file.writeAsBytes(bytes);

      debugPrint('📄 PDF saved to temp: ${file.path}');

      if (mounted) {
        setState(() {
          _localPdfPath = file.path;
          _isLoadingPdf = false;
        });
      }
    } catch (e) {
      debugPrint('❌ PDF load failed: $e');
      if (mounted) {
        setState(() => _isLoadingPdf = false);
        _showSnackBar('Failed to load PDF!', isError: true);
      }
    }
  }

  // ─────────────────────────────────────
  // DOWNLOAD
  // ─────────────────────────────────────

  Future<void> _downloadDocument() async {
    if (_isDownloading) return;

    debugPrint('⬇️ Download started for: ${widget.title}');

    // Permission check
    final hasPermission = await _checkStoragePermission();
    if (!hasPermission) {
      _showSnackBar('Storage permission required!', isError: true);
      return;
    }

    setState(() => _isDownloading = true);

    try {
      await _showDownloadProgressNotif(0, 100, 'Starting download...');

      debugPrint('⬇️ Fetching file from URL...');
      final request = http.Request('GET', Uri.parse(widget.url));
      final response = await request.send();
      final contentLength = response.contentLength ?? 0;
      debugPrint('⬇️ Content length: $contentLength bytes');

      final bytes = <int>[];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        if (contentLength > 0) {
          final progress = ((bytes.length / contentLength) * 100).round();
          if (progress % 10 == 0) {
            debugPrint('⬇️ Download progress: $progress%');
          }
          await _showDownloadProgressNotif(
            progress,
            100,
            'Downloading... $progress%',
          );
        }
      }

      debugPrint('⬇️ Download complete — ${bytes.length} bytes received');

      // ── Save to Downloads folder ──
      final ext = widget.docType == 'pdf' ? 'pdf' : 'jpg';
      final safeTitle = widget.title.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final fileName =
          '${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        debugPrint('📁 Creating Downloads directory...');
        await downloadsDir.create(recursive: true);
      }

      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      debugPrint('✅ File saved to: ${file.path}');

      // ── Trigger media scan to make it visible in File Manager immediately ──
      // try {
      //   await Process.run('am', [
      //     'broadcast',
      //     '-a',
      //     'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
      //     '-d',
      //     'file://${file.path}',
      //   ]);
      //   debugPrint('✅ Media scan triggered');
      // } catch (e) {
      //   debugPrint('⚠️ Media scan failed (non-critical): $e');
      // }

      // Reload media to ensure visibility
      try {
        await MediaScanner.loadMedia(path: file.path);
        debugPrint(
          '✅ Media scan triggered — file should appear in File Manager',
        );
      } catch (e) {
        debugPrint('⚠️ Media scan failed (non-critical): $e');
      }

      _lastDownloadedPath = file.path;

      await _showDownloadCompleteNotif(fileName, file.path);

      if (mounted) {
        setState(() => _isDownloading = false);
        _showSnackBar(
          'Saved to Downloads!',
          actionLabel: 'Open',
          onAction: () {
            debugPrint('📂 Opening file: ${file.path}');
            OpenFile.open(file.path);
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Download failed: $e');
      await _notifPlugin.cancel(id: _downloadNotifId);
      if (mounted) {
        setState(() => _isDownloading = false);
        _showSnackBar('Download failed!', isError: true);
      }
    }
  }

  // ─────────────────────────────────────
  // SHARE — Open native OS share sheet directly
  // ─────────────────────────────────────

  Future<void> _shareDocument() async {
    if (_isSharing) return;

    debugPrint('📤 Share started for: ${widget.title}');
    setState(() => _isSharing = true);

    try {
      final response = await http.get(Uri.parse(widget.url));
      debugPrint(
        '📤 File fetched for sharing: ${response.bodyBytes.length} bytes',
      );

      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final ext = widget.docType == 'pdf' ? 'pdf' : 'jpg';
      final safeTitle = widget.title.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final file = File('${dir.path}/$safeTitle.$ext');
      await file.writeAsBytes(bytes);

      debugPrint('📤 Temp file created: ${file.path}');
      setState(() => _isSharing = false);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: widget.title),
      );
      debugPrint('✅ Share sheet opened');
    } catch (e) {
      debugPrint('❌ Share failed: $e');
      if (mounted) {
        setState(() => _isSharing = false);
        _showSnackBar('Share failed!', isError: true);
      }
    }
  }

  // ─────────────────────────────────────
  // NOTIFICATION HELPERS
  // ─────────────────────────────────────

  Future<void> _showDownloadProgressNotif(
    int progress,
    int maxProgress,
    String message,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      'meditrack_downloads',
      'MediTrack Downloads',
      channelDescription: 'File download progress',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      onlyAlertOnce: true,
      icon: '@mipmap/ic_launcher',
    );

    await _notifPlugin.show(
      id: _downloadNotifId,
      title: '📥 Downloading ${widget.title}',
      body: message,
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  Future<void> _showDownloadCompleteNotif(
    String fileName,
    String filePath,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      'meditrack_downloads',
      'MediTrack Downloads',
      channelDescription: 'File download progress',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    await _notifPlugin.show(
      id: _downloadNotifId,
      title: '✅ Download Complete',
      body: 'Tap to open $fileName',
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: filePath,
    );
    debugPrint('🔔 Download complete notification shown');
  }

  // ─────────────────────────────────────
  // SNACKBAR HELPER
  // ─────────────────────────────────────

  void _showSnackBar(
    String message, {
    bool isError = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  // ─────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final isPdf = widget.docType == 'pdf';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: r.wp(4),
                vertical: r.hp(1),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: r.wp(2)),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Page count — PDF only
                  if (isPdf && _totalPages > 0)
                    Container(
                      margin: EdgeInsets.only(right: r.wp(2)),
                      padding: EdgeInsets.symmetric(
                        horizontal: r.wp(2),
                        vertical: r.hp(0.3),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(r.smallRadius),
                      ),
                      child: Text(
                        '${_currentPage + 1} / $_totalPages',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: r.sp(11),
                        ),
                      ),
                    ),

                  // Download button
                  _isDownloading
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: r.wp(2)),
                          child: SizedBox(
                            width: r.wp(5),
                            height: r.wp(5),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _downloadDocument,
                          icon: Icon(
                            Icons.download_outlined,
                            color: AppColors.primary,
                            size: r.mediumIcon,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: r.wp(9),
                            minHeight: r.wp(9),
                          ),
                          tooltip: 'Download',
                        ),

                  // Share button
                  _isSharing
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: r.wp(2)),
                          child: SizedBox(
                            width: r.wp(5),
                            height: r.wp(5),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _shareDocument,
                          icon: Icon(
                            Icons.share_outlined,
                            color: AppColors.primary,
                            size: r.mediumIcon,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: r.wp(9),
                            minHeight: r.wp(9),
                          ),
                          tooltip: 'Share',
                        ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(child: isPdf ? _buildPdfViewer(r) : _buildImageViewer(r)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // PDF VIEWER
  // ─────────────────────────────────────

  Widget _buildPdfViewer(ResponsiveHelper r) {
    if (_isLoadingPdf) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: r.mediumSpace),
            Text(
              'Loading PDF...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_localPdfPath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: r.mediumIcon,
              color: AppColors.error,
            ),
            SizedBox(height: r.mediumSpace),
            Text(
              'Failed to load PDF',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: r.mediumSpace),
            TextButton(
              onPressed: _loadPdf,
              child: Text(
                'Retry',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return PDFView(
      filePath: _localPdfPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      fitPolicy: FitPolicy.BOTH,
      onRender: (pages) {
        debugPrint('📄 PDF rendered — total pages: $pages');
        if (mounted) setState(() => _totalPages = pages ?? 0);
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
        debugPrint('❌ PDF render error: $error');
        if (mounted) _showSnackBar('PDF Error: $error', isError: true);
      },
    );
  }

  // ─────────────────────────────────────
  // IMAGE VIEWER — pinch to zoom
  // ─────────────────────────────────────

  Widget _buildImageViewer(ResponsiveHelper r) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: widget.url,
          fit: BoxFit.contain,
          placeholder: (context, url) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: r.mediumSpace),
                Text(
                  'Loading image...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          errorWidget: (context, url, error) {
            debugPrint('❌ Image load error: $error');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: r.mediumIcon,
                    color: AppColors.error,
                  ),
                  SizedBox(height: r.mediumSpace),
                  Text(
                    'Failed to load image',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
