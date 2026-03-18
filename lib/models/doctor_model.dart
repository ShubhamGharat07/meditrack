// class DoctorModel {
//   final String id;
//   final String userId;
//   final String doctorName;
//   final String speciality;
//   final String clinicName;
//   final String? phone;
//   final String? address;
//   final DateTime appointmentDate;
//   final String? notes;
//   final bool isUpcoming;
//   final bool isSynced;
//   final DateTime createdAt;

//   const DoctorModel({
//     required this.id,
//     required this.userId,
//     required this.doctorName,
//     required this.speciality,
//     required this.clinicName,
//     this.phone,
//     this.address,
//     required this.appointmentDate,
//     this.notes,
//     this.isUpcoming = true,
//     this.isSynced = false,
//     required this.createdAt,
//   });

//   // Firestore se data aaya → DoctorModel banao
//   factory DoctorModel.fromMap(Map<String, dynamic> map) {
//     return DoctorModel(
//       id: map['id'] ?? '',
//       userId: map['userId'] ?? '',
//       doctorName: map['doctorName'] ?? '',
//       speciality: map['speciality'] ?? '',
//       clinicName: map['clinicName'] ?? '',
//       phone: map['phone'],
//       address: map['address'],
//       appointmentDate: DateTime.parse(map['appointmentDate']),
//       notes: map['notes'],
//       isUpcoming: map['isUpcoming'] ?? true,
//       isSynced: map['isSynced'] ?? false,
//       createdAt: DateTime.parse(map['createdAt']),
//     );
//   }

//   // DoctorModel → Firestore mein save karo
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'userId': userId,
//       'doctorName': doctorName,
//       'speciality': speciality,
//       'clinicName': clinicName,
//       'phone': phone,
//       'address': address,
//       'appointmentDate': appointmentDate.toIso8601String(),
//       'notes': notes,
//       'isUpcoming': isUpcoming,
//       'isSynced': isSynced,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }

class DoctorModel {
  final String id;
  final String userId;
  final String? memberId; // null = main user, non-null = family member
  final String doctorName;
  final String speciality;
  final String clinicName;
  final String? phone;
  final String? address;
  final DateTime appointmentDate;
  final String? notes;
  final bool isUpcoming;
  final bool isSynced;
  final DateTime createdAt;

  const DoctorModel({
    required this.id,
    required this.userId,
    this.memberId,
    required this.doctorName,
    required this.speciality,
    required this.clinicName,
    this.phone,
    this.address,
    required this.appointmentDate,
    this.notes,
    this.isUpcoming = true,
    this.isSynced = false,
    required this.createdAt,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      memberId: map['memberId'],
      doctorName: map['doctorName'] ?? '',
      speciality: map['speciality'] ?? '',
      clinicName: map['clinicName'] ?? '',
      phone: map['phone'],
      address: map['address'],
      appointmentDate: DateTime.parse(map['appointmentDate']),
      notes: map['notes'],
      isUpcoming: map['isUpcoming'] ?? true,
      isSynced: map['isSynced'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'memberId': memberId,
      'doctorName': doctorName,
      'speciality': speciality,
      'clinicName': clinicName,
      'phone': phone,
      'address': address,
      'appointmentDate': appointmentDate.toIso8601String(),
      'notes': notes,
      'isUpcoming': isUpcoming,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  DoctorModel copyWith({
    String? id,
    String? userId,
    String? memberId,
    String? doctorName,
    String? speciality,
    String? clinicName,
    String? phone,
    String? address,
    DateTime? appointmentDate,
    String? notes,
    bool? isUpcoming,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      memberId: memberId ?? this.memberId,
      doctorName: doctorName ?? this.doctorName,
      speciality: speciality ?? this.speciality,
      clinicName: clinicName ?? this.clinicName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      notes: notes ?? this.notes,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
