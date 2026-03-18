// class HealthRecordModel {
//   final String id;
//   final String userId;
//   final String title;
//   final String category; // Blood Test, X-Ray, Prescription, Other
//   final String fileUrl; // Firebase Storage URL
//   final String fileType; // pdf, image
//   final String? notes;
//   final bool isSynced;
//   final DateTime createdAt;

//   const HealthRecordModel({
//     required this.id,
//     required this.userId,
//     required this.title,
//     required this.category,
//     required this.fileUrl,
//     required this.fileType,
//     this.notes,
//     this.isSynced = false,
//     required this.createdAt,
//   });

//   // Firestore se data aaya → HealthRecordModel banao
//   factory HealthRecordModel.fromMap(Map<String, dynamic> map) {
//     return HealthRecordModel(
//       id: map['id'] ?? '',
//       userId: map['userId'] ?? '',
//       title: map['title'] ?? '',
//       category: map['category'] ?? '',
//       fileUrl: map['fileUrl'] ?? '',
//       fileType: map['fileType'] ?? '',
//       notes: map['notes'],
//       isSynced: map['isSynced'] ?? false,
//       createdAt: DateTime.parse(map['createdAt']),
//     );
//   }

//   // HealthRecordModel → Firestore mein save karo
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'userId': userId,
//       'title': title,
//       'category': category,
//       'fileUrl': fileUrl,
//       'fileType': fileType,
//       'notes': notes,
//       'isSynced': isSynced,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }

class HealthRecordModel {
  final String id;
  final String userId;
  final String? memberId; // null = main user, non-null = family member
  final String title;
  final String category; // Blood Test, X-Ray, Prescription, Other
  final String fileUrl; // Firebase Storage URL
  final String fileType; // pdf, image
  final String? notes;
  final bool isSynced;
  final DateTime createdAt;

  const HealthRecordModel({
    required this.id,
    required this.userId,
    this.memberId,
    required this.title,
    required this.category,
    required this.fileUrl,
    required this.fileType,
    this.notes,
    this.isSynced = false,
    required this.createdAt,
  });

  factory HealthRecordModel.fromMap(Map<String, dynamic> map) {
    return HealthRecordModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      memberId: map['memberId'],
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileType: map['fileType'] ?? '',
      notes: map['notes'],
      isSynced: map['isSynced'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'memberId': memberId,
      'title': title,
      'category': category,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'notes': notes,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  HealthRecordModel copyWith({
    String? id,
    String? userId,
    String? memberId,
    String? title,
    String? category,
    String? fileUrl,
    String? fileType,
    String? notes,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return HealthRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      memberId: memberId ?? this.memberId,
      title: title ?? this.title,
      category: category ?? this.category,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      notes: notes ?? this.notes,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
