// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../models/health_record_model.dart';
// import '../viewmodels/health_record_viewmodel.dart';
// import '../core/errors/failures.dart';

// class HealthRecordProvider extends ChangeNotifier {
//   final HealthRecordViewModel _healthRecordViewModel = HealthRecordViewModel();

//   // ─────────────────────────────────────
//   // STATES
//   // ─────────────────────────────────────

//   bool _isLoading = false;
//   bool _isUploading = false;
//   List<HealthRecordModel> _records = [];
//   List<HealthRecordModel> _filteredRecords = [];
//   String _errorMessage = '';
//   String _selectedCategory = 'All';

//   // Getters
//   bool get isLoading => _isLoading;
//   bool get isUploading => _isUploading;
//   List<HealthRecordModel> get records => _records;
//   List<HealthRecordModel> get filteredRecords => _filteredRecords;
//   String get errorMessage => _errorMessage;
//   String get selectedCategory => _selectedCategory;

//   // ─────────────────────────────────────
//   // GET HEALTH RECORDS
//   // ─────────────────────────────────────

//   Future<void> getHealthRecords(String userId) async {
//     try {
//       _setLoading(true);
//       _clearError();

//       // HealthRecordViewModel se records lo
//       // ViewModel → Repository → SQLite/Firestore
//       _records = await _healthRecordViewModel.getHealthRecords(userId);

//       // Sort by date — latest first
//       _records = _healthRecordViewModel.sortByDate(_records);

//       // Apply current filter
//       _applyFilter();
//     } on ServerFailure catch (e) {
//       _errorMessage = e.message;
//     } catch (e) {
//       _errorMessage = 'Something went wrong!';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // ─────────────────────────────────────
//   // ADD HEALTH RECORD
//   // ─────────────────────────────────────

//   Future<bool> addHealthRecord({
//     required String userId,
//     required String title,
//     required String category,
//     required File file,
//     required String fileType,
//     String? notes,
//   }) async {
//     try {
//       // isUploading alag state hai
//       // Kyunki file upload time leta hai
//       _isUploading = true;
//       notifyListeners();
//       _clearError();

//       // HealthRecordViewModel ko data do
//       // ViewModel → Repository → Storage upload → Firestore save
//       await _healthRecordViewModel.addHealthRecord(
//         userId: userId,
//         title: title,
//         category: category,
//         file: file,
//         fileType: fileType,
//         notes: notes,
//       );

//       // Refresh records list
//       await getHealthRecords(userId);
//       return true;
//     } on NetworkFailure catch (e) {
//       _errorMessage = e.message;
//       return false;
//     } on ServerFailure catch (e) {
//       _errorMessage = e.message;
//       return false;
//     } catch (e) {
//       _errorMessage = 'Something went wrong!';
//       return false;
//     } finally {
//       _isUploading = false;
//       notifyListeners();
//     }
//   }

//   // ─────────────────────────────────────
//   // DELETE HEALTH RECORD
//   // ─────────────────────────────────────

//   Future<bool> deleteHealthRecord(
//     String userId,
//     String recordId,
//     String fileType,
//   ) async {
//     try {
//       _setLoading(true);
//       _clearError();

//       // HealthRecordViewModel ko delete karne do
//       // ViewModel → Repository → Storage delete → Firestore delete
//       await _healthRecordViewModel.deleteHealthRecord(
//         userId,
//         recordId,
//         fileType,
//       );

//       // Remove from local list — UI instantly update hoga
//       _records.removeWhere((r) => r.id == recordId);
//       _applyFilter();
//       return true;
//     } on NetworkFailure catch (e) {
//       _errorMessage = e.message;
//       return false;
//     } on ServerFailure catch (e) {
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
//   // FILTER BY CATEGORY
//   // ─────────────────────────────────────

//   void setCategory(String category) {
//     _selectedCategory = category;
//     _applyFilter();
//     notifyListeners();
//   }

//   // Search records by title
//   void searchRecords(String query) {
//     _filteredRecords = _healthRecordViewModel.searchRecords(_records, query);
//     notifyListeners();
//   }

//   void _applyFilter() {
//     _filteredRecords = _healthRecordViewModel.filterByCategory(
//       _records,
//       _selectedCategory,
//     );
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
import '../models/health_record_model.dart';
import '../viewmodels/health_record_viewmodel.dart';
import '../core/errors/failures.dart';

class HealthRecordProvider extends ChangeNotifier {
  final HealthRecordViewModel _healthRecordViewModel = HealthRecordViewModel();

  bool _isLoading = false;
  bool _isUploading = false;
  List<HealthRecordModel> _records = [];
  List<HealthRecordModel> _filteredRecords = [];
  String _errorMessage = '';
  String _selectedCategory = 'All';

  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  List<HealthRecordModel> get records => _records;
  List<HealthRecordModel> get filteredRecords => _filteredRecords;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  Future<void> getHealthRecords(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      _records = await _healthRecordViewModel.getHealthRecords(userId);
      _records = _healthRecordViewModel.sortByDate(_records);
      _applyFilter();
    } on ServerFailure catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addHealthRecord({
    required String userId,
    required String title,
    required String category,
    File? file,
    String? fileType,
    String? notes,
  }) async {
    try {
      _isUploading = file != null;
      notifyListeners();
      _clearError();

      await _healthRecordViewModel.addHealthRecord(
        userId: userId,
        title: title,
        category: category,
        file: file,
        fileType: fileType,
        notes: notes,
      );

      await getHealthRecords(userId);
      return true;
    } on NetworkFailure catch (_) {
      _errorMessage = 'No internet connection!';
      return false;
    } on ServerFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteHealthRecord(
    String userId,
    String recordId,
    String? fileUrl,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      await _healthRecordViewModel.deleteHealthRecord(
        userId,
        recordId,
        fileUrl ?? '',
      );

      _records.removeWhere((r) => r.id == recordId);
      _applyFilter();
      return true;
    } on NetworkFailure catch (_) {
      _errorMessage = 'No internet connection!';
      return false;
    } on ServerFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void searchRecords(String query) {
    _filteredRecords = _healthRecordViewModel.searchRecords(_records, query);
    notifyListeners();
  }

  void _applyFilter() {
    _filteredRecords = _healthRecordViewModel.filterByCategory(
      _records,
      _selectedCategory,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }
}
