// import 'dart:io';
// import 'package:uuid/uuid.dart';
// import '../models/family_member_model.dart';
// import '../services/firebase/firestore_service.dart';
// import '../services/firebase/storage_service.dart';
// import '../services/local/sqlite_service.dart';
// import '../services/local/shared_pref_service.dart';
// import '../core/errors/failures.dart';
// import '../core/network/internet_checker.dart';

// class FamilyRepository {
//   final FirestoreService _firestoreService = FirestoreService();
//   final StorageService _storageService = StorageService();
//   final SQLiteService _sqliteService = SQLiteService();
//   final SharedPrefService _sharedPrefService = SharedPrefService();
//   final InternetChecker _internetChecker = InternetChecker();
//   final Uuid _uuid = const Uuid();

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
//     try {
//       final memberId = _uuid.v4();
//       String? photoUrl;

//       // Upload photo if provided
//       final isConnected = await _internetChecker.isConnected();
//       if (photo != null && isConnected) {
//         photoUrl = await _storageService.uploadFamilyMemberPhoto(
//           userId,
//           memberId,
//           photo,
//         );
//       }

//       final member = FamilyMemberModel(
//         id: memberId,
//         userId: userId,
//         name: name,
//         relation: relation,
//         age: age,
//         bloodGroup: bloodGroup,
//         photoUrl: photoUrl,
//         allergies: allergies,
//         isSynced: false,
//         createdAt: DateTime.now(),
//       );

//       // Save to SQLite first — offline safe
//       await _sqliteService.saveFamilyMember(member);

//       // If online — sync to Firestore
//       if (isConnected) {
//         await _firestoreService.saveFamilyMember(member);
//       }
//     } catch (e) {
//       throw CacheFailure();
//     }
//   }

//   // ─────────────────────────────────────
//   // GET FAMILY MEMBERS
//   // ─────────────────────────────────────

//   Future<List<FamilyMemberModel>> getFamilyMembers(String userId) async {
//     try {
//       // Load from SQLite first — instant load
//       final localMembers = await _sqliteService.getFamilyMembers(userId);

//       // If online — sync from Firestore
//       final isConnected = await _internetChecker.isConnected();
//       if (isConnected) {
//         final remoteMembers = await _firestoreService.getFamilyMembers(userId);

//         // Save remote members to SQLite
//         for (final member in remoteMembers) {
//           await _sqliteService.saveFamilyMember(member);
//         }

//         return remoteMembers;
//       }

//       return localMembers;
//     } catch (e) {
//       throw CacheFailure();
//     }
//   }

//   // ─────────────────────────────────────
//   // DELETE FAMILY MEMBER
//   // ─────────────────────────────────────

//   Future<void> deleteFamilyMember(String userId, String memberId) async {
//     try {
//       // Delete from SQLite
//       await _sqliteService.deleteFamilyMember(memberId);

//       // If online — delete from Firestore and Storage
//       final isConnected = await _internetChecker.isConnected();
//       if (isConnected) {
//         await _firestoreService.deleteFamilyMember(userId, memberId);
//         await _storageService.deleteFamilyMemberPhoto(userId, memberId);
//       }
//     } catch (e) {
//       throw CacheFailure();
//     }
//   }

//   // ─────────────────────────────────────
//   // SELECT FAMILY MEMBER
//   // ─────────────────────────────────────

//   // Save selected family member to SharedPreferences
//   Future<void> selectFamilyMember(String memberId) async {
//     await _sharedPrefService.saveSelectedFamilyMember(memberId);
//   }

//   // Get selected family member from SharedPreferences
//   Future<String?> getSelectedFamilyMember() async {
//     return await _sharedPrefService.getSelectedFamilyMember();
//   }
// }

import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/family_member_model.dart';
import '../models/medicine_model.dart';
import '../models/doctor_model.dart';
import '../models/health_record_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/storage_service.dart';
import '../services/local/sqlite_service.dart';
import '../services/local/shared_pref_service.dart';
import '../core/errors/failures.dart';
import '../core/network/internet_checker.dart';

class FamilyRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final SQLiteService _sqliteService = SQLiteService();
  final SharedPrefService _sharedPrefService = SharedPrefService();
  final InternetChecker _internetChecker = InternetChecker();
  final _uuid = const Uuid();

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
    String? insuranceDocType, // 'pdf' or 'image'
  }) async {
    try {
      final memberId = _uuid.v4();
      String? photoUrl;
      String? insuranceDocUrl;

      final isConnected = await _internetChecker.isConnected();

      if (isConnected) {
        // Photo upload
        if (photo != null) {
          photoUrl = await _storageService.uploadFamilyPhoto(
            userId,
            memberId,
            photo,
          );
        }

        // Insurance doc upload
        if (insuranceDoc != null && insuranceDocType != null) {
          insuranceDocUrl = await _storageService.uploadInsuranceDocument(
            userId,
            memberId,
            insuranceDoc,
            insuranceDocType,
          );
        }
      }

      final member = FamilyMemberModel(
        id: memberId,
        userId: userId,
        name: name,
        relation: relation,
        age: age,
        gender: gender,
        dob: dob,
        bloodGroup: bloodGroup,
        photoUrl: photoUrl,
        allergies: allergies,
        medicalConditions: medicalConditions,
        emergencyContactName: emergencyContactName,
        emergencyContact: emergencyContact,
        insuranceProvider: insuranceProvider,
        insurancePolicyNumber: insurancePolicyNumber,
        insuranceExpiry: insuranceExpiry,
        insuranceDocUrl: insuranceDocUrl,
        isSynced: isConnected,
        createdAt: DateTime.now(),
      );

      // SQLite mein save (offline-first)
      await _sqliteService.saveFamilyMember(member);

      // Internet ho to Firestore mein bhi
      if (isConnected) {
        await _firestoreService.saveFamilyMember(member);
      }
    } catch (e) {
      throw CacheFailure();
    }
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
    try {
      String? photoUrl = member.photoUrl;
      String? insuranceDocUrl = member.insuranceDocUrl;

      final isConnected = await _internetChecker.isConnected();

      if (isConnected) {
        if (newPhoto != null) {
          photoUrl = await _storageService.uploadFamilyPhoto(
            member.userId,
            member.id,
            newPhoto,
          );
        }

        if (newInsuranceDoc != null && insuranceDocType != null) {
          insuranceDocUrl = await _storageService.uploadInsuranceDocument(
            member.userId,
            member.id,
            newInsuranceDoc,
            insuranceDocType,
          );
        }
      }

      final updatedMember = member.copyWith(
        photoUrl: photoUrl,
        insuranceDocUrl: insuranceDocUrl,
        isSynced: isConnected,
      );

      await _sqliteService.updateFamilyMember(updatedMember);

      if (isConnected) {
        await _firestoreService.saveFamilyMember(updatedMember);
      }
    } catch (e) {
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // GET FAMILY MEMBERS
  // ─────────────────────────────────────

  Future<List<FamilyMemberModel>> getFamilyMembers(String userId) async {
    try {
      final isConnected = await _internetChecker.isConnected();

      if (isConnected) {
        // Firestore se fetch karo aur SQLite update karo
        final members = await _firestoreService.getFamilyMembers(userId);
        for (final m in members) {
          await _sqliteService.saveFamilyMember(m);
        }
        return members;
      } else {
        // Offline — SQLite se lo
        return await _sqliteService.getFamilyMembers(userId);
      }
    } catch (e) {
      // Fallback to SQLite
      return await _sqliteService.getFamilyMembers(userId);
    }
  }

  // ─────────────────────────────────────
  // DELETE FAMILY MEMBER
  // ─────────────────────────────────────

  Future<void> deleteFamilyMember(String userId, String memberId) async {
    try {
      final isConnected = await _internetChecker.isConnected();

      if (!isConnected) {
        throw NetworkFailure();
      }

      await _sqliteService.deleteFamilyMember(memberId);
      await _firestoreService.deleteFamilyMember(userId, memberId);

      // Member ki saari medicines/doctors/records delete karo
      // Note: Storage files manually delete karni padegi if needed
    } catch (e) {
      if (e is NetworkFailure) rethrow;
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // SELECT FAMILY MEMBER (SharedPref)
  // ─────────────────────────────────────

  Future<void> selectFamilyMember(String memberId) async {
    await _sharedPrefService.saveSelectedFamilyMember(memberId);
  }

  Future<String?> getSelectedFamilyMember() async {
    return await _sharedPrefService.getSelectedFamilyMember();
  }

  // ─────────────────────────────────────
  // MEMBER KE MEDICINES
  // ─────────────────────────────────────

  Future<List<MedicineModel>> getMemberMedicines(
    String userId,
    String memberId,
  ) async {
    try {
      final isConnected = await _internetChecker.isConnected();

      if (isConnected) {
        return await _firestoreService.getMedicinesByMember(userId, memberId);
      } else {
        return await _sqliteService.getMedicinesByMember(userId, memberId);
      }
    } catch (e) {
      return await _sqliteService.getMedicinesByMember(userId, memberId);
    }
  }

  // ─────────────────────────────────────
  // MEMBER KE DOCTORS
  // ─────────────────────────────────────

  Future<List<DoctorModel>> getMemberDoctors(
    String userId,
    String memberId,
  ) async {
    try {
      final isConnected = await _internetChecker.isConnected();

      if (isConnected) {
        return await _firestoreService.getDoctorsByMember(userId, memberId);
      } else {
        return await _sqliteService.getDoctorsByMember(userId, memberId);
      }
    } catch (e) {
      return await _sqliteService.getDoctorsByMember(userId, memberId);
    }
  }

  // ─────────────────────────────────────
  // MEMBER KE HEALTH RECORDS
  // ─────────────────────────────────────

  Future<List<HealthRecordModel>> getMemberHealthRecords(
    String userId,
    String memberId,
  ) async {
    try {
      final isConnected = await _internetChecker.isConnected();

      if (isConnected) {
        return await _firestoreService.getHealthRecordsByMember(
          userId,
          memberId,
        );
      } else {
        return await _sqliteService.getHealthRecordsByMember(userId, memberId);
      }
    } catch (e) {
      return await _sqliteService.getHealthRecordsByMember(userId, memberId);
    }
  }

  // ─────────────────────────────────────
  // EMERGENCY INFO
  // ─────────────────────────────────────

  Map<String, dynamic> getEmergencyInfo(FamilyMemberModel member) {
    return {
      'name': member.name,
      'relation': member.relation,
      'age': member.age,
      'bloodGroup': member.bloodGroup ?? 'Unknown',
      'allergies': member.allergies ?? [],
      'medicalConditions': member.medicalConditions ?? [],
      'emergencyContactName': member.emergencyContactName,
      'emergencyContact': member.emergencyContact,
    };
  }
}
