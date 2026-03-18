// import 'dart:io';
// import '../models/family_member_model.dart';
// import '../repositories/family_repository.dart';
// import '../core/errors/failures.dart';

// class FamilyViewModel {
//   final FamilyRepository _familyRepository = FamilyRepository();

//   // ─────────────────────────────────────
//   // ADD FAMILY MEMBER
//   // ─────────────────────────────────────

//   Future<void> addFamilyMember({
//     required String userId,
//     required String name,
//     required String relation,
//     int? age,
//     String? bloodGroup,
//     File? photo,
//     List<String>? allergies,
//   }) async {
//     // Validate fields
//     if (name.isEmpty) {
//       throw CacheFailure();
//     }
//     if (relation.isEmpty) {
//       throw CacheFailure();
//     }

//     await _familyRepository.addFamilyMember(
//       userId: userId,
//       name: name,
//       relation: relation,
//       age: age,
//       bloodGroup: bloodGroup,
//       photo: photo,
//       allergies: allergies,
//     );
//   }

//   // ─────────────────────────────────────
//   // GET FAMILY MEMBERS
//   // ─────────────────────────────────────

//   Future<List<FamilyMemberModel>> getFamilyMembers(String userId) async {
//     if (userId.isEmpty) throw CacheFailure();
//     return await _familyRepository.getFamilyMembers(userId);
//   }

//   // ─────────────────────────────────────
//   // DELETE FAMILY MEMBER
//   // ─────────────────────────────────────

//   Future<void> deleteFamilyMember(String userId, String memberId) async {
//     if (userId.isEmpty || memberId.isEmpty) throw CacheFailure();
//     await _familyRepository.deleteFamilyMember(userId, memberId);
//   }

//   // ─────────────────────────────────────
//   // SELECT FAMILY MEMBER
//   // ─────────────────────────────────────

//   Future<void> selectFamilyMember(String memberId) async {
//     await _familyRepository.selectFamilyMember(memberId);
//   }

//   Future<String?> getSelectedFamilyMember() async {
//     return await _familyRepository.getSelectedFamilyMember();
//   }

//   // ─────────────────────────────────────
//   // FILTER FAMILY MEMBERS
//   // ─────────────────────────────────────

//   // Search family members by name
//   List<FamilyMemberModel> searchMembers(
//     List<FamilyMemberModel> members,
//     String query,
//   ) {
//     if (query.isEmpty) return members;
//     return members
//         .where(
//           (m) =>
//               m.name.toLowerCase().contains(query.toLowerCase()) ||
//               m.relation.toLowerCase().contains(query.toLowerCase()),
//         )
//         .toList();
//   }

//   // Get emergency info — for Emergency Screen
//   Map<String, dynamic> getEmergencyInfo(FamilyMemberModel member) {
//     return {
//       'name': member.name,
//       'relation': member.relation,
//       'age': member.age,
//       'bloodGroup': member.bloodGroup ?? 'Unknown',
//       'allergies': member.allergies ?? [],
//     };
//   }
// }

import 'dart:io';
import '../models/family_member_model.dart';
import '../models/medicine_model.dart';
import '../models/doctor_model.dart';
import '../models/health_record_model.dart';
import '../repositories/family_repository.dart';
import '../core/errors/failures.dart';

class FamilyViewModel {
  final FamilyRepository _familyRepository = FamilyRepository();

  // ─────────────────────────────────────
  // ADD FAMILY MEMBER
  // ─────────────────────────────────────

  Future<void> addFamilyMember({
    required String userId,
    required String name,
    required String relation,
    int? age,
    String? gender,
    DateTime? dob,
    String? bloodGroup,
    File? photo,
    List<String>? allergies,
    List<String>? medicalConditions,
    String? emergencyContactName,
    String? emergencyContact,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    DateTime? insuranceExpiry,
    File? insuranceDoc,
    String? insuranceDocType,
  }) async {
    if (name.isEmpty) throw CacheFailure();
    if (relation.isEmpty) throw CacheFailure();

    await _familyRepository.addFamilyMember(
      userId: userId,
      name: name,
      relation: relation,
      age: age,
      gender: gender,
      dob: dob,
      bloodGroup: bloodGroup,
      photo: photo,
      allergies: allergies,
      medicalConditions: medicalConditions,
      emergencyContactName: emergencyContactName,
      emergencyContact: emergencyContact,
      insuranceProvider: insuranceProvider,
      insurancePolicyNumber: insurancePolicyNumber,
      insuranceExpiry: insuranceExpiry,
      insuranceDoc: insuranceDoc,
      insuranceDocType: insuranceDocType,
    );
  }

  // ─────────────────────────────────────
  // UPDATE FAMILY MEMBER
  // ─────────────────────────────────────

  Future<void> updateFamilyMember({
    required FamilyMemberModel member,
    File? newPhoto,
    File? newInsuranceDoc,
    String? insuranceDocType,
  }) async {
    if (member.name.isEmpty) throw CacheFailure();

    await _familyRepository.updateFamilyMember(
      member: member,
      newPhoto: newPhoto,
      newInsuranceDoc: newInsuranceDoc,
      insuranceDocType: insuranceDocType,
    );
  }

  // ─────────────────────────────────────
  // GET / DELETE
  // ─────────────────────────────────────

  Future<List<FamilyMemberModel>> getFamilyMembers(String userId) async {
    if (userId.isEmpty) throw CacheFailure();
    return await _familyRepository.getFamilyMembers(userId);
  }

  Future<void> deleteFamilyMember(String userId, String memberId) async {
    if (userId.isEmpty || memberId.isEmpty) throw CacheFailure();
    await _familyRepository.deleteFamilyMember(userId, memberId);
  }

  // ─────────────────────────────────────
  // SELECT MEMBER
  // ─────────────────────────────────────

  Future<void> selectFamilyMember(String memberId) async {
    await _familyRepository.selectFamilyMember(memberId);
  }

  Future<String?> getSelectedFamilyMember() async {
    return await _familyRepository.getSelectedFamilyMember();
  }

  // ─────────────────────────────────────
  // MEMBER DATA
  // ─────────────────────────────────────

  Future<List<MedicineModel>> getMemberMedicines(
    String userId,
    String memberId,
  ) async {
    return await _familyRepository.getMemberMedicines(userId, memberId);
  }

  Future<List<DoctorModel>> getMemberDoctors(
    String userId,
    String memberId,
  ) async {
    return await _familyRepository.getMemberDoctors(userId, memberId);
  }

  Future<List<HealthRecordModel>> getMemberHealthRecords(
    String userId,
    String memberId,
  ) async {
    return await _familyRepository.getMemberHealthRecords(userId, memberId);
  }

  // ─────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────

  List<FamilyMemberModel> searchMembers(
    List<FamilyMemberModel> members,
    String query,
  ) {
    if (query.isEmpty) return members;
    return members
        .where(
          (m) =>
              m.name.toLowerCase().contains(query.toLowerCase()) ||
              m.relation.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // ─────────────────────────────────────
  // EMERGENCY INFO
  // ─────────────────────────────────────

  Map<String, dynamic> getEmergencyInfo(FamilyMemberModel member) {
    return _familyRepository.getEmergencyInfo(member);
  }
}
