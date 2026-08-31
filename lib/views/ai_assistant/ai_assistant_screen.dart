import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/ai_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/health_record_provider.dart';
import '../../providers/health_insurance_provider.dart';
import '../../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Message entrance animation — slide up + fade in, plays once per new message
// ─────────────────────────────────────────────────────────────────────────────
class _MessageEntrance extends StatefulWidget {
  final Widget child;
  final bool animate;

  const _MessageEntrance({required this.child, this.animate = true});

  @override
  State<_MessageEntrance> createState() => _MessageEntranceState();
}

class _MessageEntranceState extends State<_MessageEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    if (widget.animate) {
      _ctrl.forward();
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typing dots — 3 bouncing dots, staggered repeat loop
// ─────────────────────────────────────────────────────────────────────────────
class _TypingDots extends StatefulWidget {
  final ResponsiveHelper r;
  const _TypingDots({required this.r});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
        duration: const Duration(milliseconds: 550),
        vsync: this,
      ),
    );
    _anims = _controllers
        .map(
          (c) => Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 170), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final dotSize = r.wp(2).clamp(6.0, 9.0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Container(
            width: dotSize,
            height: dotSize,
            margin: EdgeInsets.symmetric(horizontal: r.wp(0.8)),
            transform: Matrix4.translationValues(
              0,
              -_anims[i].value * r.hp(0.9),
              0,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.3 + _anims[i].value * 0.65,
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AIAssistantScreen — logic 100% preserved, UI polished
// ─────────────────────────────────────────────────────────────────────────────
class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final Map<int, int> _visibleTokenCounts = {};
  final Map<int, Timer> _typewriterTimers = {};
  final Set<int> _completedTypewriterMessages = {};

  // Track which indices have already been animated — prevents re-animation on rebuild
  final Set<int> _animatedIndices = {};

  @override
  void initState() {
    super.initState();
    // Pre-load all health data so RAG context is populated
    // even if user comes directly to AI screen
    Future.microtask(() {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.uid;
      if (userId != null) {
        final medProvider = context.read<MedicineProvider>();
        if (medProvider.medicines.isEmpty) medProvider.getMedicines(userId);
        final docProvider = context.read<DoctorProvider>();
        if (docProvider.doctors.isEmpty) docProvider.getDoctors(userId);
        final hrProvider = context.read<HealthRecordProvider>();
        if (hrProvider.records.isEmpty) hrProvider.getHealthRecords(userId);
        final insProvider = context.read<HealthInsuranceProvider>();
        if (insProvider.policies.isEmpty) insProvider.getPolicies(userId);
      }
    });
  }

  @override
  void dispose() {
    for (final timer in _typewriterTimers.values) {
      timer.cancel();
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // Send message — RAG enabled (passes all providers for context)
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    await context.read<AIProvider>().sendMessage(
      message,
      medicineProvider: context.read<MedicineProvider>(),
      doctorProvider: context.read<DoctorProvider>(),
      healthRecordProvider: context.read<HealthRecordProvider>(),
      healthInsuranceProvider: context.read<HealthInsuranceProvider>(),
      authProvider: context.read<AuthProvider>(),
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final ai = context.watch<AIProvider>();
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(r, ai),
            Divider(height: 1, thickness: 0.5, color: colors.divider),
            Expanded(
              child: ai.messages.isEmpty
                  ? _buildEmptyChat(r)
                  : _buildMessageList(r, ai),
            ),
            if (ai.isLoading) _buildTypingIndicator(r),
            _buildInputArea(r, ai),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(ResponsiveHelper r, AIProvider ai) {
    final colors = AppColors.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.wp(4).clamp(16, 48).toDouble(),
        vertical: r.hp(1.4),
      ),
      color: colors.surface,
      child: Row(
        children: [
          // Gradient circular avatar
          Container(
            width: r.wp(10).clamp(36, 46).toDouble(),
            height: r.wp(10).clamp(36, 46).toDouble(),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: AppColors.textWhite,
              size: r.smallIcon,
            ),
          ),
          SizedBox(width: r.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MediTrack AI', style: AppTextStyles.heading3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: r.wp(1.5)),
                    Text(
                      'Your Health Assistant',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                        fontSize: r.sp(11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (ai.messages.isNotEmpty)
            IconButton(
              onPressed: () => _showClearDialog(r),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: r.mediumIcon,
              ),
              tooltip: 'Clear chat',
            ),
        ],
      ),
    );
  }

  // ── Message list with per-message entrance animation ────────────────────────
  Widget _buildMessageList(ResponsiveHelper r, AIProvider ai) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: r.wp(4), vertical: r.hp(2)),
      itemCount: ai.messages.length,
      itemBuilder: (context, index) {
        final message = ai.messages[index];
        final shouldAnimate = !_animatedIndices.contains(index);
        if (shouldAnimate) _animatedIndices.add(index);
        final visibleMessage = message.isUser
            ? message.message
            : _visibleAiMessageText(message, shouldAnimate);
        return _MessageEntrance(
          animate: shouldAnimate,
          child: _buildMessageBubble(
            r,
            message,
            visibleMessage: visibleMessage,
          ),
        );
      },
    );
  }

  String _visibleAiMessageText(ChatMessage message, bool shouldAnimate) {
    final key = _messageKey(message);
    if (!shouldAnimate && !_typewriterTimers.containsKey(key)) {
      return message.message;
    }

    _startTypewriter(message);
    final tokens = _splitRevealTokens(message.message);
    final visibleCount = _visibleTokenCounts[key] ?? 0;
    return tokens.take(visibleCount).join();
  }

  void _startTypewriter(ChatMessage message) {
    final key = _messageKey(message);
    if (_completedTypewriterMessages.contains(key) ||
        _typewriterTimers.containsKey(key)) {
      return;
    }

    final tokens = _splitRevealTokens(message.message);
    if (tokens.isEmpty) {
      _completedTypewriterMessages.add(key);
      return;
    }

    _visibleTokenCounts[key] = 0;
    _typewriterTimers[key] = Timer.periodic(
      const Duration(milliseconds: 38),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final nextCount = (_visibleTokenCounts[key] ?? 0) + 1;
        if (nextCount >= tokens.length) {
          _visibleTokenCounts[key] = tokens.length;
          _completedTypewriterMessages.add(key);
          _typewriterTimers.remove(key)?.cancel();
        } else {
          _visibleTokenCounts[key] = nextCount;
        }

        setState(() {});
        _scrollToBottom();
      },
    );
  }

  List<String> _splitRevealTokens(String text) {
    return RegExp(r'\S+\s*|\s+')
        .allMatches(text)
        .map((match) => match.group(0)!)
        .toList();
  }

  int _messageKey(ChatMessage message) {
    return Object.hash(message.time.microsecondsSinceEpoch, message.message);
  }

  // ── Typing indicator (bouncing dots) ────────────────────────────────────────
  Widget _buildTypingIndicator(ResponsiveHelper r) {
    final colors = AppColors.of(context);
    final avatarSize = r.wp(8).clamp(28.0, 38.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(r.wp(4), r.hp(0.5), r.wp(4), r.hp(0.8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: AppColors.textWhite,
              size: r.wp(4).clamp(14.0, 20.0),
            ),
          ),
          SizedBox(width: r.wp(2)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.wp(4),
              vertical: r.hp(1.4),
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(r.largeRadius),
                topRight: Radius.circular(r.largeRadius),
                bottomRight: Radius.circular(r.largeRadius),
                bottomLeft: const Radius.circular(4),
              ),
              border: Border.all(color: colors.divider, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _TypingDots(r: r),
          ),
        ],
      ),
    );
  }

  // ── Input area ──────────────────────────────────────────────────────────────
  Widget _buildInputArea(ResponsiveHelper r, AIProvider ai) {
    final colors = AppColors.of(context);
    final btnSize = r.wp(11).clamp(42.0, 52.0);
    return Container(
      padding: EdgeInsets.fromLTRB(r.wp(4), r.hp(1), r.wp(4), r.hp(1.5)),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text field with border
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(r.largeRadius),
                border: Border.all(color: colors.divider),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textPrimary,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask about your health...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary.withOpacity(0.55),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: r.wp(4),
                    vertical: r.hp(1.2),
                  ),
                ),
                onSubmitted: ai.isLoading ? null : (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: r.wp(2.5)),
          // Send button — gradient + shadow when active
          GestureDetector(
            onTap: ai.isLoading
                ? () => context.read<AIProvider>().cancelRequest()
                : _sendMessage,
            child: Container(
              width: btnSize,
              height: btnSize,
              decoration: BoxDecoration(
                gradient: ai.isLoading
                    ? const LinearGradient(
                        colors: [AppColors.error, Color(0xFFFF6B6B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (ai.isLoading ? AppColors.error : AppColors.primary)
                        .withOpacity(0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ai.isLoading
                  ? Icon(
                      Icons.stop_rounded,
                      color: AppColors.textWhite,
                      size: r.mediumIcon,
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: AppColors.textWhite,
                      size: r.smallIcon,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty chat — suggestion cards ──────────────────────────────────────────
  Widget _buildEmptyChat(ResponsiveHelper r) {
    final colors = AppColors.of(context);
    final suggestions = [
      [
        '💊',
        'Side effects of Paracetamol?',
        'What are the side effects of Paracetamol?',
      ],
      ['🩺', 'How to manage diabetes?', 'How to manage diabetes?'],
      [
        '🫀',
        'Foods to avoid with high BP',
        'What foods to avoid with high blood pressure?',
      ],
      [
        '💧',
        'Daily water intake guide',
        'How much water should I drink daily?',
      ],
    ];

    return SingleChildScrollView(
      padding: r.pagePadding,
      child: Column(
        children: [
          SizedBox(height: r.hp(5)),

          // Hero avatar with soft gradient ring
          Container(
            width: r.wp(22).clamp(76.0, 100.0),
            height: r.wp(22).clamp(76.0, 100.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.12),
                  AppColors.secondary.withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              size: r.wp(11).clamp(38.0, 52.0),
              color: AppColors.primary,
            ),
          ),

          SizedBox(height: r.mediumSpace),
          Text("Hi! I'm MediTrack AI", style: AppTextStyles.heading3),
          SizedBox(height: r.hp(0.8)),
          Text(
            'Ask me anything about your health,\nmedicines, or appointments.',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.65,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: r.largeSpace),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SUGGESTED QUESTIONS',
              style: AppTextStyles.label.copyWith(
                color: colors.textSecondary,
                fontSize: r.sp(10),
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(height: r.smallSpace),

          ...suggestions.map(
            (s) => GestureDetector(
              onTap: () {
                _messageController.text = s[2];
                _sendMessage();
              },
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: r.hp(1)),
                padding: EdgeInsets.symmetric(
                  horizontal: r.wp(4),
                  vertical: r.hp(1.6),
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(r.mediumRadius),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.13),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(s[0], style: TextStyle(fontSize: r.sp(18))),
                    SizedBox(width: r.wp(3)),
                    Expanded(
                      child: Text(
                        s[1],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: r.sp(12),
                      color: colors.textSecondary.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Message bubble ──────────────────────────────────────────────────────────
  Widget _buildMessageBubble(
    ResponsiveHelper r,
    ChatMessage message, {
    required String visibleMessage,
  }) {
    final isUser = message.isUser;
    final colors = AppColors.of(context);
    final avatarSize = r.wp(8).clamp(28.0, 38.0);
    final iconSize = r.wp(4).clamp(14.0, 20.0);

    return Padding(
      padding: EdgeInsets.only(bottom: r.hp(1.2)),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar — left side
          if (!isUser) ...[
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                color: AppColors.textWhite,
                size: iconSize,
              ),
            ),
            SizedBox(width: r.wp(2)),
          ],

          // Bubble — max 74% width
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.wp(74)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.wp(4),
                  vertical: r.hp(1.2),
                ),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.primary : colors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(r.largeRadius),
                    topRight: Radius.circular(r.largeRadius),
                    bottomLeft: isUser
                        ? Radius.circular(r.largeRadius)
                        : const Radius.circular(4),
                    bottomRight: isUser
                        ? const Radius.circular(4)
                        : Radius.circular(r.largeRadius),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: colors.divider, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: isUser
                          ? AppColors.primary.withOpacity(0.2)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    isUser
                        ? Text(
                            visibleMessage,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textWhite,
                              height: 1.55,
                            ),
                          )
                        : _buildMarkdownText(r, visibleMessage),
                    SizedBox(height: r.hp(0.4)),
                    Text(
                      '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isUser
                            ? AppColors.textWhite.withOpacity(0.65)
                            : colors.textSecondary,
                        fontSize: r.sp(9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // User avatar — right side
          if (isUser) ...[
            SizedBox(width: r.wp(2)),
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: iconSize,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Markdown renderer — logic identical to original ─────────────────────────
  Widget _buildMarkdownText(ResponsiveHelper r, String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty) {
        widgets.add(SizedBox(height: r.hp(0.6)));
        continue;
      }

      if (line.startsWith('### ')) {
        widgets.add(_styledLine(line.substring(4), r, level: 3));
        continue;
      }
      if (line.startsWith('## ')) {
        widgets.add(_styledLine(line.substring(3), r, level: 2));
        continue;
      }
      if (line.startsWith('# ')) {
        widgets.add(_styledLine(line.substring(2), r, level: 1));
        continue;
      }

      if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: r.wp(2), bottom: r.hp(0.3)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: r.hp(0.5)),
                  child: Container(
                    width: r.wp(1.5).clamp(4.0, 8.0),
                    height: r.wp(1.5).clamp(4.0, 8.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: r.wp(2)),
                Expanded(child: _inlineSpan(line.substring(2), r)),
              ],
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: r.hp(0.2)),
          child: _inlineSpan(line, r),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _inlineSpan(String text, ResponsiveHelper r) {
    final colors = AppColors.of(context);
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
          color: colors.textPrimary,
          height: 1.55,
        ),
        children: _parseInline(text, r),
      ),
    );
  }

  Widget _styledLine(String text, ResponsiveHelper r, {int level = 1}) {
    final colors = AppColors.of(context);
    final fontSize = level == 1
        ? r.sp(15.0)
        : level == 2
        ? r.sp(14.0)
        : r.sp(13.0);
    return Padding(
      padding: EdgeInsets.only(top: r.hp(0.5), bottom: r.hp(0.3)),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
          children: _parseInline(text, r),
        ),
      ),
    );
  }

  // Parse inline **bold**, ***bold+italic***, *italic* — logic identical to original
  List<TextSpan> _parseInline(String text, ResponsiveHelper r) {
    final spans = <TextSpan>[];
    int i = 0;
    final colors = AppColors.of(context);
    final baseStyle = AppTextStyles.bodySmall.copyWith(
      color: colors.textPrimary,
      height: 1.55,
    );

    while (i < text.length) {
      if (i + 2 < text.length && text.substring(i, i + 3) == '***') {
        final end = text.indexOf('***', i + 3);
        if (end != -1) {
          spans.add(
            TextSpan(
              text: text.substring(i + 3, end),
              style: baseStyle.copyWith(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
          i = end + 3;
          continue;
        }
      }
      if (i + 1 < text.length && text.substring(i, i + 2) == '**') {
        final end = text.indexOf('**', i + 2);
        if (end != -1) {
          spans.add(
            TextSpan(
              text: text.substring(i + 2, end),
              style: baseStyle.copyWith(fontWeight: FontWeight.w700),
            ),
          );
          i = end + 2;
          continue;
        }
      }
      if (text[i] == '*') {
        final end = text.indexOf('*', i + 1);
        if (end != -1) {
          spans.add(
            TextSpan(
              text: text.substring(i + 1, end),
              style: baseStyle.copyWith(fontStyle: FontStyle.italic),
            ),
          );
          i = end + 1;
          continue;
        }
      }
      int j = i + 1;
      while (j < text.length && text[j] != '*') j++;
      spans.add(TextSpan(text: text.substring(i, j), style: baseStyle));
      i = j;
    }

    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }

  // ── Clear chat dialog ───────────────────────────────────────────────────────
  void _showClearDialog(ResponsiveHelper r) {
    final outerContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Clear Chat', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to clear the chat history?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              outerContext.read<AIProvider>().clearChat();
              _animatedIndices.clear(); // reset so new messages animate again
              _visibleTokenCounts.clear();
              _completedTypewriterMessages.clear();
              for (final timer in _typewriterTimers.values) {
                timer.cancel();
              }
              _typewriterTimers.clear();
            },
            child: Text(
              'Clear',
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
}
