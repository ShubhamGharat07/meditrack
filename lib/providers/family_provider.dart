// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../models/family_member_model.dart';
// import '../viewmodels/family_viewmodel.dart';
// import '../core/errors/failures.dart';

// class FamilyProvider extends ChangeNotifier {
//   final FamilyViewModel _familyViewModel = FamilyViewModel();

//   // ─────────────────────────────────────
//   // STATES
//   // ─────────────────────────────────────

//   bool _isLoading = false;
//   List<FamilyMemberModel> _members = [];
//   FamilyMemberModel? _selectedMember;
//   String _errorMessage = '';

//   // Getters
//   bool get isLoading => _isLoading;
//   List<FamilyMemberModel> get members => _members;
//   FamilyMemberModel? get selectedMember => _selectedMember;
//   String get errorMessage => _errorMessage;

//   // ─────────────────────────────────────
//   // GET FAMILY MEMBERS
//   // ─────────────────────────────────────

//   Future<void> getFamilyMembers(String userId) async {
//     try {
//       _setLoading(true);
//       _clearError();

//       // FamilyViewModel se members lo
//       // ViewModel → Repository → SQLite/Firestore
//       _members = await _familyViewModel.getFamilyMembers(userId);

//       // Get selected member from SharedPreferences
//       final selectedId = await _familyViewModel.getSelectedFamilyMember();

//       if (selectedId != null) {
//         // SharedPref mein jo member save tha usse select karo
//         _selectedMember = _members.firstWhere(
//           (m) => m.id == selectedId,
//           orElse: () => _members.first,
//         );
//       } else if (_members.isNotEmpty) {
//         // Default — pehla member select karo
//         _selectedMember = _members.first;
//       }
//     } on CacheFailure catch (e) {
//       _errorMessage = e.message;
//     } catch (e) {
//       _errorMessage = 'Something went wrong!';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // ─────────────────────────────────────
//   // ADD FAMILY MEMBER
//   // ─────────────────────────────────────

//   Future<bool> addFamilyMember({
//     required String userId,
//     required String name,
//     required String relation,
//     int? age,
//     String? bloodGroup,
//     File? photo,
//     List<String>? allergies,
//   }) async {
//     try {
//       _setLoading(true);
//       _clearError();

//       // FamilyViewModel ko data do
//       // ViewModel → Repository → SQLite save → Firestore sync
//       await _familyViewModel.addFamilyMember(
//         userId: userId,
//         name: name,
//         relation: relation,
//         age: age,
//         bloodGroup: bloodGroup,
//         photo: photo,
//         allergies: allergies,
//       );

//       // Refresh members list
//       await getFamilyMembers(userId);
//       return true;
//     } on CacheFailure catch (e) {
//       _errorMessage = e.message;
//       return false;
//     } catch (e) {
//       _errorMessage = 'Something went wrong!';
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // ─────────────────────────────────────
//   // DELETE FAMILY MEMBER
//   // ─────────────────────────────────────

//   Future<bool> deleteFamilyMember(String userId, String memberId) async {
//     try {
//       _setLoading(true);
//       _clearError();

//       // FamilyViewModel ko delete karne do
//       // ViewModel → Repository → SQLite delete → Firestore delete
//       await _familyViewModel.deleteFamilyMember(userId, memberId);

//       // Remove from local list
//       _members.removeWhere((m) => m.id == memberId);

//       // Agar selected member delete hua to first member select karo
//       if (_selectedMember?.id == memberId) {
//         _selectedMember = _members.isNotEmpty ? _members.first : null;
//       }

//       return true;
//     } on CacheFailure catch (e) {
//       _errorMessage = e.message;
//       return false;
//     } catch (e) {
//       _errorMessage = 'Something went wrong!';
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // ─────────────────────────────────────
//   // SELECT FAMILY MEMBER
//   // ─────────────────────────────────────

//   Future<void> selectMember(FamilyMemberModel member) async {
//     // UI instantly update karo
//     _selectedMember = member;
//     notifyListeners();

//     // SharedPref mein save karo
//     // Taaki app restart pe bhi same member selected rahe
//     await _familyViewModel.selectFamilyMember(member.id);
//   }

//   // ─────────────────────────────────────
//   // GET EMERGENCY INFO
//   // ─────────────────────────────────────

//   Map<String, dynamic>? getEmergencyInfo() {
//     if (_selectedMember == null) return null;
//     // Emergency Screen ke liye selected member ki info
//     return _familyViewModel.getEmergencyInfo(_selectedMember!);
//   }

//   // ─────────────────────────────────────
//   // HELPERS
//   // ─────────────────────────────────────

//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   void _clearError() {
//     _errorMessage = '';
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/family_member_model.dart';
import '../models/medicine_model.dart';
import '../models/doctor_model.dart';
import '../models/health_record_model.dart';
import '../viewmodels/family_viewmodel.dart';
import '../core/errors/failures.dart';

class FamilyProvider extends ChangeNotifier {
  final FamilyViewModel _familyViewModel = FamilyViewModel();

  // ─────────────────────────────────────
  // STATES
  // ─────────────────────────────────────

  bool _isLoading = false;
  bool _isMemberDataLoading = false; // Detail screen ke liye alag loader
  List<FamilyMemberModel> _members = [];
  FamilyMemberModel? _selectedMember;
  String _errorMessage = '';

  // Member ka data (detail screen mein dikhega)
  List<MedicineModel> _memberMedicines = [];
  List<DoctorModel> _memberDoctors = [];
  List<HealthRecordModel> _memberHealthRecords = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isMemberDataLoading => _isMemberDataLoading;
  List<FamilyMemberModel> get members => _members;
  FamilyMemberModel? get selectedMember => _selectedMember;
  String get errorMessage => _errorMessage;
  List<MedicineModel> get memberMedicines => _memberMedicines;
  List<DoctorModel> get memberDoctors => _memberDoctors;
  List<HealthRecordModel> get memberHealthRecords => _memberHealthRecords;

  // ─────────────────────────────────────
  // GET FAMILY MEMBERS
  // ─────────────────────────────────────

  Future<void> getFamilyMembers(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _members = await _familyViewModel.getFamilyMembers(userId);

      final selectedId = await _familyViewModel.getSelectedFamilyMember();
      if (selectedId != null && _members.isNotEmpty) {
        _selectedMember = _members.firstWhere(
          (m) => m.id == selectedId,
          orElse: () => _members.first,
        );
      } else if (_members.isNotEmpty) {
        _selectedMember = _members.first;
      }
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // ADD FAMILY MEMBER
  // ─────────────────────────────────────

  Future<bool> addFamilyMember({
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
    try {
      _setLoading(true);
      _clearError();

      await _familyViewModel.addFamilyMember(
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

      await getFamilyMembers(userId);
      return true;
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // UPDATE FAMILY MEMBER
  // ─────────────────────────────────────

  Future<bool> updateFamilyMember({
    required String userId,
    required FamilyMemberModel member,
    File? newPhoto,
    File? newInsuranceDoc,
    String? insuranceDocType,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _familyViewModel.updateFamilyMember(
        member: member,
        newPhoto: newPhoto,
        newInsuranceDoc: newInsuranceDoc,
        insuranceDocType: insuranceDocType,
      );

      // Local list mein bhi update karo
      final index = _members.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _members[index] = member;
        if (_selectedMember?.id == member.id) {
          _selectedMember = member;
        }
      }

      notifyListeners();
      return true;
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // DELETE FAMILY MEMBER
  // ─────────────────────────────────────

  Future<bool> deleteFamilyMember(String userId, String memberId) async {
    try {
      _setLoading(true);
      _clearError();

      await _familyViewModel.deleteFamilyMember(userId, memberId);

      _members.removeWhere((m) => m.id == memberId);
      if (_selectedMember?.id == memberId) {
        _selectedMember = _members.isNotEmpty ? _members.first : null;
      }

      notifyListeners();
      return true;
    } on NetworkFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // SELECT MEMBER
  // ─────────────────────────────────────

  Future<void> selectMember(FamilyMemberModel member) async {
    _selectedMember = member;
    notifyListeners();
    await _familyViewModel.selectFamilyMember(member.id);
  }

  // ─────────────────────────────────────
  // LOAD MEMBER DATA — Detail screen ke liye
  // ─────────────────────────────────────

  Future<void> loadMemberData(String userId, String memberId) async {
    try {
      _isMemberDataLoading = true;
      notifyListeners();

      // Parallel fetch — fast loading
      final results = await Future.wait([
        _familyViewModel.getMemberMedicines(userId, memberId),
        _familyViewModel.getMemberDoctors(userId, memberId),
        _familyViewModel.getMemberHealthRecords(userId, memberId),
      ]);

      _memberMedicines = results[0] as List<MedicineModel>;
      _memberDoctors = results[1] as List<DoctorModel>;
      _memberHealthRecords = results[2] as List<HealthRecordModel>;
    } catch (e) {
      _errorMessage = 'Could not load member data!';
    } finally {
      _isMemberDataLoading = false;
      notifyListeners();
    }
  }

  // Data clear karo jab detail screen se bahar jaao
  void clearMemberData() {
    _memberMedicines = [];
    _memberDoctors = [];
    _memberHealthRecords = [];
    notifyListeners();
  }

  // ─────────────────────────────────────
  // EMERGENCY INFO
  // ─────────────────────────────────────

  Map<String, dynamic>? getEmergencyInfo() {
    if (_selectedMember == null) return null;
    return _familyViewModel.getEmergencyInfo(_selectedMember!);
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }
}
