// import 'package:flutter/material.dart';
// import 'package:meditrack/core/constants/app_text_style.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/responsive_helper.dart';
// import '../../providers/ai_provider.dart';

// class AIAssistantScreen extends StatefulWidget {
//   const AIAssistantScreen({super.key});

//   @override
//   State<AIAssistantScreen> createState() => _AIAssistantScreenState();
// }

// class _AIAssistantScreenState extends State<AIAssistantScreen> {
//   final _messageController = TextEditingController();
//   final _scrollController = ScrollController();

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // Scroll to bottom after new message
//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   // Send message
//   Future<void> _sendMessage() async {
//     final message = _messageController.text.trim();
//     if (message.isEmpty) return;

//     _messageController.clear();
//     await context.read<AIProvider>().sendMessage(message);
//     _scrollToBottom();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);
//     final ai = context.watch<AIProvider>();

//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Padding(
//               padding: r.pagePadding,
//               child: Column(
//                 children: [
//                   SizedBox(height: r.mediumSpace),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(r.wp(2)),
//                             decoration: BoxDecoration(
//                               color: AppColors.primary.withOpacity(0.1),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.smart_toy,
//                               color: AppColors.primary,
//                               size: r.mediumIcon,
//                             ),
//                           ),
//                           SizedBox(width: r.wp(3)),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'MediTrack AI',
//                                 style: AppTextStyles.heading3,
//                               ),
//                               Text(
//                                 'Your Health Assistant',
//                                 style: AppTextStyles.bodySmall.copyWith(
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.onSurfaceVariant,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),

//                       // Clear chat button
//                       if (ai.messages.isNotEmpty)
//                         IconButton(
//                           onPressed: () => _showClearDialog(r),
//                           icon: Icon(
//                             Icons.delete_outline,
//                             color: AppColors.error,
//                             size: r.mediumIcon,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const Divider(height: 1),

//             // Chat messages
//             Expanded(
//               child: ai.messages.isEmpty
//                   ? _buildEmptyChat(r)
//                   : ListView.builder(
//                       controller: _scrollController,
//                       padding: EdgeInsets.symmetric(
//                         horizontal: r.wp(4),
//                         vertical: r.hp(2),
//                       ),
//                       itemCount: ai.messages.length,
//                       itemBuilder: (context, index) {
//                         final message = ai.messages[index];
//                         return _buildMessageBubble(r, message);
//                       },
//                     ),
//             ),

//             // Loading indicator
//             if (ai.isLoading)
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: r.wp(4),
//                   vertical: r.hp(1),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(r.wp(2)),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.smart_toy,
//                         color: AppColors.primary,
//                         size: r.smallIcon,
//                       ),
//                     ),
//                     SizedBox(width: r.wp(2)),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: r.wp(4),
//                         vertical: r.hp(1),
//                       ),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.surface,
//                         borderRadius: BorderRadius.circular(r.mediumRadius),
//                       ),
//                       child: Row(
//                         children: [
//                           _buildTypingDot(r, 0),
//                           SizedBox(width: r.wp(1)),
//                           _buildTypingDot(r, 1),
//                           SizedBox(width: r.wp(1)),
//                           _buildTypingDot(r, 2),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             // Message input
//             Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: r.wp(4),
//                 vertical: r.hp(1.5),
//               ),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, -4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   // Text field
//                   Expanded(
//                     child: TextField(
//                       controller: _messageController,
//                       maxLines: null,
//                       textCapitalization: TextCapitalization.sentences,
//                       decoration: InputDecoration(
//                         hintText: 'Ask about your health...',
//                         hintStyle: AppTextStyles.bodySmall.copyWith(
//                           color: Theme.of(
//                             context,
//                           ).colorScheme.onSurfaceVariant.withOpacity(0.5),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(r.largeRadius),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Theme.of(context).colorScheme.surface,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: r.wp(4),
//                           vertical: r.hp(1.2),
//                         ),
//                       ),
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),

//                   SizedBox(width: r.wp(2)),

//                   // Send button
//                   GestureDetector(
//                     onTap: ai.isLoading ? null : _sendMessage,
//                     child: Container(
//                       padding: EdgeInsets.all(r.wp(3)),
//                       decoration: BoxDecoration(
//                         color: ai.isLoading
//                             ? Theme.of(
//                                 context,
//                               ).colorScheme.onSurfaceVariant.withOpacity(0.3)
//                             : AppColors.primary,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.send,
//                         color: AppColors.textWhite,
//                         size: r.smallIcon,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Empty chat — suggestions
//   Widget _buildEmptyChat(ResponsiveHelper r) {
//     final suggestions = [
//       'What are the side effects of Paracetamol?',
//       'How to manage diabetes?',
//       'What foods to avoid with high blood pressure?',
//       'How much water should I drink daily?',
//     ];

//     return SingleChildScrollView(
//       padding: r.pagePadding,
//       child: Column(
//         children: [
//           SizedBox(height: r.largeSpace),

//           // AI Icon
//           Container(
//             width: r.wp(25),
//             height: r.wp(25),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.smart_toy,
//               size: r.wp(12),
//               color: AppColors.primary,
//             ),
//           ),

//           SizedBox(height: r.mediumSpace),

//           Text('Hi! I am MediTrack AI', style: AppTextStyles.heading3),
//           SizedBox(height: r.smallSpace),
//           Text(
//             'Ask me anything about your health!',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//             ),
//             textAlign: TextAlign.center,
//           ),

//           SizedBox(height: r.largeSpace),

//           // Suggestion chips
//           Text('Try asking:', style: AppTextStyles.label),
//           SizedBox(height: r.mediumSpace),
//           ...suggestions.map(
//             (suggestion) => GestureDetector(
//               onTap: () {
//                 _messageController.text = suggestion;
//                 _sendMessage();
//               },
//               child: Container(
//                 width: double.infinity,
//                 margin: EdgeInsets.only(bottom: r.smallSpace),
//                 padding: r.cardPadding,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surface,
//                   borderRadius: BorderRadius.circular(r.mediumRadius),
//                   border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.lightbulb_outline,
//                       color: AppColors.primary,
//                       size: r.smallIcon,
//                     ),
//                     SizedBox(width: r.wp(3)),
//                     Expanded(
//                       child: Text(
//                         suggestion,
//                         style: AppTextStyles.bodySmall.copyWith(
//                           color: Theme.of(context).colorScheme.onSurface,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Message bubble
//   Widget _buildMessageBubble(ResponsiveHelper r, dynamic message) {
//     final isUser = message.isUser;

//     return Padding(
//       padding: EdgeInsets.only(bottom: r.mediumSpace),
//       child: Row(
//         mainAxisAlignment: isUser
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           // AI icon — left side
//           if (!isUser) ...[
//             Container(
//               padding: EdgeInsets.all(r.wp(1.5)),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.smart_toy,
//                 color: AppColors.primary,
//                 size: r.wp(4),
//               ),
//             ),
//             SizedBox(width: r.wp(2)),
//           ],

//           // Message bubble
//           Flexible(
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: r.wp(4),
//                 vertical: r.hp(1.2),
//               ),
//               decoration: BoxDecoration(
//                 color: isUser
//                     ? AppColors.primary
//                     : Theme.of(context).colorScheme.surfaceVariant,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(r.mediumRadius),
//                   topRight: Radius.circular(r.mediumRadius),
//                   bottomLeft: isUser
//                       ? Radius.circular(r.mediumRadius)
//                       : Radius.zero,
//                   bottomRight: isUser
//                       ? Radius.zero
//                       : Radius.circular(r.mediumRadius),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 5,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     message.message,
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: isUser
//                           ? AppColors.textWhite
//                           : Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                   SizedBox(height: r.hp(0.3)),
//                   Text(
//                     '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: isUser
//                           ? AppColors.textWhite.withOpacity(0.7)
//                           : Theme.of(context).colorScheme.onSurfaceVariant,
//                       fontSize: r.sp(9),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // User icon — right side
//           if (isUser) ...[
//             SizedBox(width: r.wp(2)),
//             Container(
//               padding: EdgeInsets.all(r.wp(1.5)),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.person,
//                 color: AppColors.primary,
//                 size: r.wp(4),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // Typing dots
//   Widget _buildTypingDot(ResponsiveHelper r, int index) {
//     return TweenAnimationBuilder(
//       tween: Tween<double>(begin: 0, end: 1),
//       duration: Duration(milliseconds: 600 + (index * 200)),
//       builder: (context, value, child) {
//         return Container(
//           width: r.wp(2),
//           height: r.wp(2),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.3 + (value * 0.7)),
//             shape: BoxShape.circle,
//           ),
//         );
//       },
//     );
//   }

//   // Clear chat dialog
//   void _showClearDialog(ResponsiveHelper r) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Clear Chat', style: AppTextStyles.heading3),
//         content: Text(
//           'Are you sure you want to clear the chat history?',
//           style: AppTextStyles.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               context.read<AIProvider>().clearChat();
//             },
//             child: Text(
//               'Clear',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.error,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/ai_provider.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll to bottom after new message
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Send message
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    await context.read<AIProvider>().sendMessage(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final ai = context.watch<AIProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: r.pagePadding,
              child: Column(
                children: [
                  SizedBox(height: r.mediumSpace),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(r.wp(2)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.smart_toy,
                              color: AppColors.primary,
                              size: r.mediumIcon,
                            ),
                          ),
                          SizedBox(width: r.wp(3)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MediTrack AI',
                                style: AppTextStyles.heading3,
                              ),
                              Text(
                                'Your Health Assistant',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Clear chat button
                      if (ai.messages.isNotEmpty)
                        IconButton(
                          onPressed: () => _showClearDialog(r),
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: r.mediumIcon,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Chat messages
            Expanded(
              child: ai.messages.isEmpty
                  ? _buildEmptyChat(r)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: r.wp(4),
                        vertical: r.hp(2),
                      ),
                      itemCount: ai.messages.length,
                      itemBuilder: (context, index) {
                        final message = ai.messages[index];
                        return _buildMessageBubble(r, message);
                      },
                    ),
            ),

            // Loading indicator
            if (ai.isLoading)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.wp(4),
                  vertical: r.hp(1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(r.wp(2)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.smart_toy,
                        color: AppColors.primary,
                        size: r.smallIcon,
                      ),
                    ),
                    SizedBox(width: r.wp(2)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.wp(4),
                        vertical: r.hp(1),
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                      ),
                      child: Row(
                        children: [
                          _buildTypingDot(r, 0),
                          SizedBox(width: r.wp(1)),
                          _buildTypingDot(r, 1),
                          SizedBox(width: r.wp(1)),
                          _buildTypingDot(r, 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Message input
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.wp(4),
                vertical: r.hp(1.5),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ask about your health...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(r.largeRadius),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: r.wp(4),
                          vertical: r.hp(1.2),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),

                  SizedBox(width: r.wp(2)),

                  // Send button
                  GestureDetector(
                    onTap: ai.isLoading ? null : _sendMessage,
                    child: Container(
                      padding: EdgeInsets.all(r.wp(3)),
                      decoration: BoxDecoration(
                        color: ai.isLoading
                            ? Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant.withOpacity(0.3)
                            : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: AppColors.textWhite,
                        size: r.smallIcon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty chat — suggestions
  Widget _buildEmptyChat(ResponsiveHelper r) {
    final suggestions = [
      'What are the side effects of Paracetamol?',
      'How to manage diabetes?',
      'What foods to avoid with high blood pressure?',
      'How much water should I drink daily?',
    ];

    return SingleChildScrollView(
      padding: r.pagePadding,
      child: Column(
        children: [
          SizedBox(height: r.largeSpace),

          // AI Icon
          Container(
            width: r.wp(25),
            height: r.wp(25),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: r.wp(12),
              color: AppColors.primary,
            ),
          ),

          SizedBox(height: r.mediumSpace),

          Text('Hi! I am MediTrack AI', style: AppTextStyles.heading3),
          SizedBox(height: r.smallSpace),
          Text(
            'Ask me anything about your health!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: r.largeSpace),

          // Suggestion chips
          Text('Try asking:', style: AppTextStyles.label),
          SizedBox(height: r.mediumSpace),
          ...suggestions.map(
            (suggestion) => GestureDetector(
              onTap: () {
                _messageController.text = suggestion;
                _sendMessage();
              },
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: r.smallSpace),
                padding: r.cardPadding,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(r.mediumRadius),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                      size: r.smallIcon,
                    ),
                    SizedBox(width: r.wp(3)),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
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

  // Message bubble
  Widget _buildMessageBubble(ResponsiveHelper r, dynamic message) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: r.mediumSpace),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI icon — left side
          if (!isUser) ...[
            Container(
              padding: EdgeInsets.all(r.wp(1.5)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: AppColors.primary,
                size: r.wp(4),
              ),
            ),
            SizedBox(width: r.wp(2)),
          ],

          // Message bubble
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.wp(4),
                vertical: r.hp(1.2),
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(r.mediumRadius),
                  topRight: Radius.circular(r.mediumRadius),
                  bottomLeft: isUser
                      ? Radius.circular(r.mediumRadius)
                      : Radius.zero,
                  bottomRight: isUser
                      ? Radius.zero
                      : Radius.circular(r.mediumRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  isUser
                      ? Text(
                          message.message,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textWhite,
                          ),
                        )
                      : _buildMarkdownText(r, message.message),
                  SizedBox(height: r.hp(0.3)),
                  Text(
                    '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isUser
                          ? AppColors.textWhite.withOpacity(0.7)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: r.sp(9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User icon — right side
          if (isUser) ...[
            SizedBox(width: r.wp(2)),
            Container(
              padding: EdgeInsets.all(r.wp(1.5)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.primary,
                size: r.wp(4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Markdown text renderer — handles **, ***, #, bullet points ──
  Widget _buildMarkdownText(ResponsiveHelper r, String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty) {
        widgets.add(SizedBox(height: r.hp(0.6)));
        continue;
      }

      // Heading: # or ## or ###
      if (line.startsWith('### ')) {
        widgets.add(
          _styledLine(line.substring(4), r, isHeading: true, level: 3),
        );
        continue;
      }
      if (line.startsWith('## ')) {
        widgets.add(
          _styledLine(line.substring(3), r, isHeading: true, level: 2),
        );
        continue;
      }
      if (line.startsWith('# ')) {
        widgets.add(
          _styledLine(line.substring(2), r, isHeading: true, level: 1),
        );
        continue;
      }

      // Bullet: - or * at line start
      if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: r.wp(2), bottom: r.hp(0.3)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: r.hp(0.4)),
                  child: Container(
                    width: r.wp(1.5),
                    height: r.wp(1.5),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
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

      // Normal line with inline formatting
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

  // Single line with bold/italic inline spans
  Widget _inlineSpan(String text, ResponsiveHelper r) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.5,
        ),
        children: _parseInline(text, r),
      ),
    );
  }

  // Heading line widget
  Widget _styledLine(
    String text,
    ResponsiveHelper r, {
    bool isHeading = false,
    int level = 1,
  }) {
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
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
          children: _parseInline(text, r),
        ),
      ),
    );
  }

  // Parse inline **bold**, ***bold***, *italic*
  List<TextSpan> _parseInline(String text, ResponsiveHelper r) {
    final spans = <TextSpan>[];
    int i = 0;
    final baseStyle = AppTextStyles.bodySmall.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.5,
    );

    while (i < text.length) {
      // *** bold+italic ***
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
      // ** bold **
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
      // * italic *
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
      // Normal char — collect until next special char
      int j = i + 1;
      while (j < text.length && text[j] != '*') j++;
      spans.add(TextSpan(text: text.substring(i, j), style: baseStyle));
      i = j;
    }

    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }

  // Typing dots
  Widget _buildTypingDot(ResponsiveHelper r, int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: r.wp(2),
          height: r.wp(2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  // Clear chat dialog
  void _showClearDialog(ResponsiveHelper r) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to clear the chat history?',
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
            onPressed: () {
              Navigator.pop(context);
              context.read<AIProvider>().clearChat();
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
