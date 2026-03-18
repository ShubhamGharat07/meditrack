class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bloodGroup;
  final int? age;
  final String? phone;
  final bool isBlocked;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bloodGroup,
    this.age,
    this.phone,
    this.isBlocked = false,
    required this.createdAt,
  });

  // Firestore se data aaya → UserModel banao
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      bloodGroup: map['bloodGroup'],
      age: map['age'],
      phone: map['phone'],
      isBlocked: map['isBlocked'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // UserModel → Firestore mein save karo
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bloodGroup': bloodGroup,
      'age': age,
      'phone': phone,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
