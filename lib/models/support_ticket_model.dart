class SupportTicketModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String title;
  final String description;
  final String status; // open, in_progress, resolved
  final String? adminReply;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const SupportTicketModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.title,
    required this.description,
    this.status = 'open',
    this.adminReply,
    this.attachmentUrl,
    required this.createdAt,
    this.resolvedAt,
  });

  // Firestore se data aaya → SupportTicketModel banao
  factory SupportTicketModel.fromMap(Map<String, dynamic> map) {
    return SupportTicketModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'open',
      adminReply: map['adminReply'],
      attachmentUrl: map['attachmentUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'])
          : null,
    );
  }

  // SupportTicketModel → Firestore mein save karo
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'title': title,
      'description': description,
      'status': status,
      'adminReply': adminReply,
      'attachmentUrl': attachmentUrl,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }
}
