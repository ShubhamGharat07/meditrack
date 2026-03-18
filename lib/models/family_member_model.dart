// class FamilyMemberModel {
//   final String id;
//   final String userId;
//   final String name;
//   final String relation;
//   final int? age;
//   final String? bloodGroup;
//   final String? photoUrl;
//   final List<String>? allergies;
//   final bool isSynced;
//   final DateTime createdAt;

//   const FamilyMemberModel({
//     required this.id,
//     required this.userId,
//     required this.name,
//     required this.relation,
//     this.age,
//     this.bloodGroup,
//     this.photoUrl,
//     this.allergies,
//     this.isSynced = false,
//     required this.createdAt,
//   });

//   factory FamilyMemberModel.fromMap(Map<String, dynamic> map) {
//     return FamilyMemberModel(
//       id: map['id'] ?? '',
//       userId: map['userId'] ?? '',
//       name: map['name'] ?? '',
//       relation: map['relation'] ?? '',
//       age: map['age'],
//       bloodGroup: map['bloodGroup'],
//       photoUrl: map['photoUrl'],
//       allergies: map['allergies'] != null
//           ? List<String>.from(map['allergies'])
//           : null,
//       isSynced: map['isSynced'] ?? false,
//       createdAt: DateTime.parse(map['createdAt']),
//     );
//   }

//   // FamilyMemberModel → Firestore mein save karo
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'userId': userId,
//       'name': name,
//       'relation': relation,
//       'age': age,
//       'bloodGroup': bloodGroup,
//       'photoUrl': photoUrl,
//       'allergies': allergies,
//       'isSynced': isSynced,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }

class FamilyMemberModel {
  final String id;
  final String userId;
  final String name;
  final String relation;
  final int? age;
  final String? gender; // Male, Female, Other
  final DateTime? dob;
  final String? bloodGroup;
  final String? photoUrl;
  final List<String>? allergies;
  final List<String>? medicalConditions; // Diabetes, BP, etc.

  // Emergency Contact
  final String? emergencyContactName;
  final String? emergencyContact; // phone number

  // Insurance
  final String? insuranceProvider; // Star Health, etc.
  final String? insurancePolicyNumber;
  final DateTime? insuranceExpiry;
  final String? insuranceDocUrl; // Firebase Storage URL

  final bool isSynced;
  final DateTime createdAt;

  const FamilyMemberModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.relation,
    this.age,
    this.gender,
    this.dob,
    this.bloodGroup,
    this.photoUrl,
    this.allergies,
    this.medicalConditions,
    this.emergencyContactName,
    this.emergencyContact,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.insuranceExpiry,
    this.insuranceDocUrl,
    this.isSynced = false,
    required this.createdAt,
  });

  factory FamilyMemberModel.fromMap(Map<String, dynamic> map) {
    return FamilyMemberModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      relation: map['relation'] ?? '',
      age: map['age'],
      gender: map['gender'],
      dob: map['dob'] != null ? DateTime.parse(map['dob']) : null,
      bloodGroup: map['bloodGroup'],
      photoUrl: map['photoUrl'],
      allergies: map['allergies'] != null
          ? List<String>.from(map['allergies'])
          : null,
      medicalConditions: map['medicalConditions'] != null
          ? List<String>.from(map['medicalConditions'])
          : null,
      emergencyContactName: map['emergencyContactName'],
      emergencyContact: map['emergencyContact'],
      insuranceProvider: map['insuranceProvider'],
      insurancePolicyNumber: map['insurancePolicyNumber'],
      insuranceExpiry: map['insuranceExpiry'] != null
          ? DateTime.parse(map['insuranceExpiry'])
          : null,
      insuranceDocUrl: map['insuranceDocUrl'],
      isSynced: map['isSynced'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'relation': relation,
      'age': age,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'bloodGroup': bloodGroup,
      'photoUrl': photoUrl,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'emergencyContactName': emergencyContactName,
      'emergencyContact': emergencyContact,
      'insuranceProvider': insuranceProvider,
      'insurancePolicyNumber': insurancePolicyNumber,
      'insuranceExpiry': insuranceExpiry?.toIso8601String(),
      'insuranceDocUrl': insuranceDocUrl,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  FamilyMemberModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? relation,
    int? age,
    String? gender,
    DateTime? dob,
    String? bloodGroup,
    String? photoUrl,
    List<String>? allergies,
    List<String>? medicalConditions,
    String? emergencyContactName,
    String? emergencyContact,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    DateTime? insuranceExpiry,
    String? insuranceDocUrl,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return FamilyMemberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoUrl: photoUrl ?? this.photoUrl,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insurancePolicyNumber:
          insurancePolicyNumber ?? this.insurancePolicyNumber,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      insuranceDocUrl: insuranceDocUrl ?? this.insuranceDocUrl,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
