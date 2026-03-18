// class MedicineModel {
//   final String id;
//   final String userId;
//   final String name;
//   final String dosage;
//   final String type; // Tablet, Syrup, Injection
//   final String frequency; // Once, Twice, Thrice Daily
//   final DateTime startDate;
//   final DateTime? endDate;
//   final List<String> reminderTimes; // ['08:00 AM', '08:00 PM']
//   final String priority; // High, Medium, Low
//   final String? notes;
//   final bool isSynced; // Offline sync ke liye
//   final DateTime createdAt;

//   const MedicineModel({
//     required this.id,
//     required this.userId,
//     required this.name,
//     required this.dosage,
//     required this.type,
//     required this.frequency,
//     required this.startDate,
//     this.endDate,
//     required this.reminderTimes,
//     required this.priority,
//     this.notes,
//     this.isSynced = false,
//     required this.createdAt,
//   });

//   // Firestore se data aaya → MedicineModel banao
//   factory MedicineModel.fromMap(Map<String, dynamic> map) {
//     return MedicineModel(
//       id: map['id'] ?? '',
//       userId: map['userId'] ?? '',
//       name: map['name'] ?? '',
//       dosage: map['dosage'] ?? '',
//       type: map['type'] ?? '',
//       frequency: map['frequency'] ?? '',
//       startDate: DateTime.parse(map['startDate']),
//       endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
//       reminderTimes: List<String>.from(map['reminderTimes'] ?? []),
//       priority: map['priority'] ?? 'Low',
//       notes: map['notes'],
//       isSynced: map['isSynced'] ?? false,
//       createdAt: DateTime.parse(map['createdAt']),
//     );
//   }

//   // MedicineModel → Firestore mein save karo
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'userId': userId,
//       'name': name,
//       'dosage': dosage,
//       'type': type,
//       'frequency': frequency,
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate?.toIso8601String(),
//       'reminderTimes': reminderTimes,
//       'priority': priority,
//       'notes': notes,
//       'isSynced': isSynced,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }

class MedicineModel {
  final String id;
  final String userId;
  final String? memberId; // null = main user, non-null = family member
  final String name;
  final String dosage;
  final String type; // Tablet, Syrup, Injection
  final String frequency; // Once, Twice, Thrice Daily
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> reminderTimes; // ['08:00 AM', '08:00 PM']
  final String priority; // High, Medium, Low
  final String? notes;
  final bool isSynced;
  final DateTime createdAt;

  const MedicineModel({
    required this.id,
    required this.userId,
    this.memberId,
    required this.name,
    required this.dosage,
    required this.type,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.reminderTimes,
    required this.priority,
    this.notes,
    this.isSynced = false,
    required this.createdAt,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      memberId: map['memberId'],
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      type: map['type'] ?? '',
      frequency: map['frequency'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      reminderTimes: List<String>.from(map['reminderTimes'] ?? []),
      priority: map['priority'] ?? 'Low',
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
      'name': name,
      'dosage': dosage,
      'type': type,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderTimes': reminderTimes,
      'priority': priority,
      'notes': notes,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MedicineModel copyWith({
    String? id,
    String? userId,
    String? memberId,
    String? name,
    String? dosage,
    String? type,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? reminderTimes,
    String? priority,
    String? notes,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
