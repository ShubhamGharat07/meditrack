// // // // import 'package:flutter/material.dart';
// // // // import '../models/medicine_model.dart';
// // // // import '../viewmodels/medicine_viewmodel.dart';
// // // // import '../core/errors/failures.dart';

// // // // class MedicineProvider extends ChangeNotifier {
// // // //   final MedicineViewModel _medicineViewModel = MedicineViewModel();

// // // //   // ─────────────────────────────────────
// // // //   // STATES
// // // //   // ─────────────────────────────────────

// // // //   bool _isLoading = false;
// // // //   List<MedicineModel> _medicines = [];
// // // //   List<MedicineModel> _filteredMedicines = [];
// // // //   String _errorMessage = '';
// // // //   String _selectedFilter = 'All';
// // // //   String _searchQuery = '';

// // // //   // Getters
// // // //   bool get isLoading => _isLoading;
// // // //   List<MedicineModel> get medicines => _medicines;
// // // //   List<MedicineModel> get filteredMedicines => _filteredMedicines;
// // // //   String get errorMessage => _errorMessage;
// // // //   String get selectedFilter => _selectedFilter;
// // // //   String get searchQuery => _searchQuery;

// // // //   // ─────────────────────────────────────
// // // //   // GET MEDICINES
// // // //   // ─────────────────────────────────────

// // // //   Future<void> getMedicines(String userId) async {
// // // //     try {
// // // //       _setLoading(true);
// // // //       _clearError();

// // // //       // MedicineViewModel se medicines lo
// // // //       // ViewModel → Repository → SQLite/Firestore
// // // //       _medicines = await _medicineViewModel.getMedicines(userId);

// // // //       // Apply current filter
// // // //       _applyFilter();
// // // //     } on CacheFailure catch (e) {
// // // //       _errorMessage = e.message;
// // // //     } catch (e) {
// // // //       _errorMessage = 'Something went wrong!';
// // // //     } finally {
// // // //       _setLoading(false);
// // // //     }
// // // //   }

// // // //   // ─────────────────────────────────────
// // // //   // ADD MEDICINE
// // // //   // ─────────────────────────────────────

// // // //   Future<bool> addMedicine({
// // // //     required String userId,
// // // //     required String name,
// // // //     required String dosage,
// // // //     required String type,
// // // //     required String frequency,
// // // //     required DateTime startDate,
// // // //     DateTime? endDate,
// // // //     required List<String> reminderTimes,
// // // //     required String priority,
// // // //     String? notes,
// // // //   }) async {
// // // //     try {
// // // //       _setLoading(true);
// // // //       _clearError();

// // // //       // MedicineViewModel ko data do
// // // //       // ViewModel → Repository → SQLite save → Firestore sync
// // // //       await _medicineViewModel.addMedicine(
// // // //         userId: userId,
// // // //         name: name,
// // // //         dosage: dosage,
// // // //         type: type,
// // // //         frequency: frequency,
// // // //         startDate: startDate,
// // // //         endDate: endDate,
// // // //         reminderTimes: reminderTimes,
// // // //         priority: priority,
// // // //         notes: notes,
// // // //       );

// // // //       // Refresh medicines list
// // // //       await getMedicines(userId);
// // // //       return true;
// // // //     } on CacheFailure catch (e) {
// // // //       _errorMessage = e.message;
// // // //       return false;
// // // //     } catch (e) {
// // // //       _errorMessage = 'Something went wrong!';
// // // //       return false;
// // // //     } finally {
// // // //       _setLoading(false);
// // // //     }
// // // //   }

// // // //   // ─────────────────────────────────────
// // // //   // DELETE MEDICINE
// // // //   // ─────────────────────────────────────

// // // //   Future<bool> deleteMedicine(String userId, String medicineId) async {
// // // //     try {
// // // //       _setLoading(true);
// // // //       _clearError();

// // // //       // MedicineViewModel ko delete karne do
// // // //       // ViewModel → Repository → SQLite delete → Firestore delete
// // // //       await _medicineViewModel.deleteMedicine(userId, medicineId);

// // // //       // Remove from local list — UI instantly update hoga
// // // //       _medicines.removeWhere((m) => m.id == medicineId);
// // // //       _applyFilter();
// // // //       return true;
// // // //     } on CacheFailure catch (e) {
// // // //       _errorMessage = e.message;
// // // //       return false;
// // // //     } catch (e) {
// // // //       _errorMessage = 'Something went wrong!';
// // // //       return false;
// // // //     } finally {
// // // //       _setLoading(false);
// // // //     }
// // // //   }

// // // //   // ─────────────────────────────────────
// // // //   // SYNC PENDING MEDICINES
// // // //   // ─────────────────────────────────────

// // // //   Future<void> syncPendingMedicines() async {
// // // //     // SQLite mein jo unsynced medicines hain
// // // //     // unhe Firestore mein sync karo
// // // //     await _medicineViewModel.syncPendingMedicines();
// // // //   }

// // // //   // ─────────────────────────────────────
// // // //   // FILTER & SEARCH
// // // //   // ─────────────────────────────────────

// // // //   // Filter change karo — All, Active, Completed
// // // //   void setFilter(String filter) {
// // // //     _selectedFilter = filter;
// // // //     _applyFilter();
// // // //     notifyListeners();
// // // //   }

// // // //   // Search query change karo
// // // //   void setSearchQuery(String query) {
// // // //     _searchQuery = query;
// // // //     _applyFilter();
// // // //     notifyListeners();
// // // //   }

// // // //   // Filter + Search apply karo
// // // //   void _applyFilter() {
// // // //     List<MedicineModel> result = _medicines;

// // // //     // Apply filter
// // // //     if (_selectedFilter == 'Active') {
// // // //       result = _medicineViewModel.getActiveMedicines(result);
// // // //     } else if (_selectedFilter == 'Completed') {
// // // //       result = _medicineViewModel.getCompletedMedicines(result);
// // // //     }

// // // //     // Apply search
// // // //     if (_searchQuery.isNotEmpty) {
// // // //       result = _medicineViewModel.searchMedicines(result, _searchQuery);
// // // //     }

// // // //     _filteredMedicines = result;
// // // //   }

// // // //   // ─────────────────────────────────────
// // // //   // HELPERS
// // // //   // ─────────────────────────────────────

// // // //   void _setLoading(bool value) {
// // // //     _isLoading = value;
// // // //     notifyListeners();
// // // //   }

// // // //   void _clearError() {
// // // //     _errorMessage = '';
// // // //   }
// // // // }

// // // import 'package:flutter/material.dart';
// // // import '../models/medicine_model.dart';
// // // import '../viewmodels/medicine_viewmodel.dart';
// // // import '../core/errors/failures.dart';

// // // class MedicineProvider extends ChangeNotifier {
// // //   final MedicineViewModel _medicineViewModel = MedicineViewModel();

// // //   bool _isLoading = false;
// // //   List<MedicineModel> _medicines = [];
// // //   List<MedicineModel> _filteredMedicines = [];
// // //   String _errorMessage = '';
// // //   String _selectedFilter = 'All';
// // //   String _searchQuery = '';

// // //   bool get isLoading => _isLoading;
// // //   List<MedicineModel> get medicines => _medicines;
// // //   List<MedicineModel> get filteredMedicines => _filteredMedicines;
// // //   String get errorMessage => _errorMessage;
// // //   String get selectedFilter => _selectedFilter;
// // //   String get searchQuery => _searchQuery;

// // //   Future<void> getMedicines(String userId) async {
// // //     try {
// // //       _setLoading(true);
// // //       _clearError();
// // //       _medicines = await _medicineViewModel.getMedicines(userId);
// // //       _applyFilter();
// // //     } on CacheFailure catch (e) {
// // //       _errorMessage = e.message;
// // //     } catch (e) {
// // //       _errorMessage = 'Something went wrong!';
// // //     } finally {
// // //       _setLoading(false);
// // //     }
// // //   }

// // //   Future<bool> addMedicine({
// // //     required String userId,
// // //     required String name,
// // //     required String dosage,
// // //     required String type,
// // //     required String frequency,
// // //     required DateTime startDate,
// // //     DateTime? endDate,
// // //     required List<String> reminderTimes,
// // //     required String priority,
// // //     String? notes,
// // //   }) async {
// // //     try {
// // //       _setLoading(true);
// // //       _clearError();
// // //       await _medicineViewModel.addMedicine(
// // //         userId: userId,
// // //         name: name,
// // //         dosage: dosage,
// // //         type: type,
// // //         frequency: frequency,
// // //         startDate: startDate,
// // //         endDate: endDate,
// // //         reminderTimes: reminderTimes,
// // //         priority: priority,
// // //         notes: notes,
// // //       );
// // //       await getMedicines(userId);
// // //       return true;
// // //     } on CacheFailure catch (e) {
// // //       _errorMessage = e.message;
// // //       return false;
// // //     } catch (e) {
// // //       _errorMessage = 'Something went wrong!';
// // //       return false;
// // //     } finally {
// // //       _setLoading(false);
// // //     }
// // //   }

// // //   Future<bool> deleteMedicine(String userId, String medicineId) async {
// // //     try {
// // //       _setLoading(true);
// // //       _clearError();
// // //       await _medicineViewModel.deleteMedicine(userId, medicineId);
// // //       _medicines.removeWhere((m) => m.id == medicineId);
// // //       _applyFilter();
// // //       return true;
// // //     } on CacheFailure catch (e) {
// // //       _errorMessage = e.message;
// // //       return false;
// // //     } catch (e) {
// // //       _errorMessage = 'Something went wrong!';
// // //       return false;
// // //     } finally {
// // //       _setLoading(false);
// // //     }
// // //   }

// // //   Future<void> syncPendingMedicines() async {
// // //     await _medicineViewModel.syncPendingMedicines();
// // //   }

// // //   // Get active medicines — Dashboard use karega
// // //   List<MedicineModel> getActiveMedicines() {
// // //     return _medicineViewModel.getActiveMedicines(_medicines);
// // //   }

// // //   // Get completed medicines
// // //   List<MedicineModel> getCompletedMedicines() {
// // //     return _medicineViewModel.getCompletedMedicines(_medicines);
// // //   }

// // //   // Search medicines
// // //   List<MedicineModel> searchMedicines(String query) {
// // //     return _medicineViewModel.searchMedicines(_medicines, query);
// // //   }

// // //   void setFilter(String filter) {
// // //     _selectedFilter = filter;
// // //     _applyFilter();
// // //     notifyListeners();
// // //   }

// // //   void setSearchQuery(String query) {
// // //     _searchQuery = query;
// // //     _applyFilter();
// // //     notifyListeners();
// // //   }

// // //   void _applyFilter() {
// // //     List<MedicineModel> result = _medicines;

// // //     if (_selectedFilter == 'Active') {
// // //       result = _medicineViewModel.getActiveMedicines(result);
// // //     } else if (_selectedFilter == 'Completed') {
// // //       result = _medicineViewModel.getCompletedMedicines(result);
// // //     }

// // //     if (_searchQuery.isNotEmpty) {
// // //       result = _medicineViewModel.searchMedicines(result, _searchQuery);
// // //     }

// // //     _filteredMedicines = result;
// // //   }

// // //   void _setLoading(bool value) {
// // //     _isLoading = value;
// // //     notifyListeners();
// // //   }

// // //   void _clearError() {
// // //     _errorMessage = '';
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import '../models/medicine_model.dart';
// // import '../viewmodels/medicine_viewmodel.dart';
// // import '../core/errors/failures.dart';
// // import '../services/notification/notification_service.dart';

// // class MedicineProvider extends ChangeNotifier {
// //   final MedicineViewModel _medicineViewModel = MedicineViewModel();

// //   bool _isLoading = false;
// //   List<MedicineModel> _medicines = [];
// //   List<MedicineModel> _filteredMedicines = [];
// //   String _errorMessage = '';
// //   String _selectedFilter = 'All';
// //   String _searchQuery = '';

// //   bool get isLoading => _isLoading;
// //   List<MedicineModel> get medicines => _medicines;
// //   List<MedicineModel> get filteredMedicines => _filteredMedicines;
// //   String get errorMessage => _errorMessage;
// //   String get selectedFilter => _selectedFilter;
// //   String get searchQuery => _searchQuery;

// //   Future<void> getMedicines(String userId) async {
// //     try {
// //       _setLoading(true);
// //       _clearError();
// //       _medicines = await _medicineViewModel.getMedicines(userId);
// //       _applyFilter();
// //     } on CacheFailure catch (_) {
// //       _errorMessage = 'Local data error!';
// //     } on NetworkFailure catch (_) {
// //       _errorMessage = 'No internet connection!';
// //     } catch (e) {
// //       _errorMessage = 'Something went wrong!';
// //     } finally {
// //       _setLoading(false);
// //     }
// //   }

// //   Future<bool> addMedicine({
// //     required String userId,
// //     required String name,
// //     required String dosage,
// //     required String type,
// //     required String frequency,
// //     required DateTime startDate,
// //     DateTime? endDate,
// //     required List<String> reminderTimes,
// //     required String priority,
// //     String? notes,
// //   }) async {
// //     try {
// //       _setLoading(true);
// //       _clearError();
// //       await _medicineViewModel.addMedicine(
// //         userId: userId,
// //         name: name,
// //         dosage: dosage,
// //         type: type,
// //         frequency: frequency,
// //         startDate: startDate,
// //         endDate: endDate,
// //         reminderTimes: reminderTimes,
// //         priority: priority,
// //         notes: notes,
// //       );

// //       // Refresh medicines list to get the newly added medicine with its ID
// //       await getMedicines(userId);

// //       // Find the newly added medicine and schedule notifications
// //       try {
// //         final newMedicine = _medicines.firstWhere(
// //           (m) =>
// //               m.name == name && m.dosage == dosage && m.frequency == frequency,
// //         );
// //         await NotificationService().scheduleMedicineReminder(newMedicine);
// //       } catch (e) {
// //         print(
// //           "Could not find newly added medicine for notifications scheduling: $e",
// //         );
// //       }

// //       return true;
// //     } on CacheFailure catch (_) {
// //       _errorMessage = 'Local data error!';
// //       return false;
// //     } on NetworkFailure catch (_) {
// //       _errorMessage = 'No internet connection!';
// //       return false;
// //     } catch (e) {
// //       _errorMessage = 'Something went wrong!';
// //       return false;
// //     } finally {
// //       _setLoading(false);
// //     }
// //   }

// //   Future<bool> deleteMedicine(String userId, String medicineId) async {
// //     try {
// //       _setLoading(true);
// //       _clearError();
// //       await _medicineViewModel.deleteMedicine(userId, medicineId);

// //       // Cancel notifications before removing from list
// //       try {
// //         final medicineToDelete = _medicines.firstWhere(
// //           (m) => m.id == medicineId,
// //         );
// //         await NotificationService().cancelMedicineReminders(medicineToDelete);
// //       } catch (e) {
// //         print("Could not cancel notifications for deleted medicine: $e");
// //       }

// //       _medicines.removeWhere((m) => m.id == medicineId);
// //       _applyFilter();
// //       return true;
// //     } on CacheFailure catch (_) {
// //       _errorMessage = 'Local data error!';
// //       return false;
// //     } on NetworkFailure catch (_) {
// //       _errorMessage = 'No internet connection!';
// //       return false;
// //     } catch (e) {
// //       _errorMessage = 'Something went wrong!';
// //       return false;
// //     } finally {
// //       _setLoading(false);
// //     }
// //   }

// //   Future<void> syncPendingMedicines() async {
// //     await _medicineViewModel.syncPendingMedicines();
// //   }

// //   List<MedicineModel> getActiveMedicines() {
// //     return _medicineViewModel.getActiveMedicines(_medicines);
// //   }

// //   List<MedicineModel> getCompletedMedicines() {
// //     return _medicineViewModel.getCompletedMedicines(_medicines);
// //   }

// //   List<MedicineModel> searchMedicines(String query) {
// //     return _medicineViewModel.searchMedicines(_medicines, query);
// //   }

// //   void setFilter(String filter) {
// //     _selectedFilter = filter;
// //     _applyFilter();
// //     notifyListeners();
// //   }

// //   void setSearchQuery(String query) {
// //     _searchQuery = query;
// //     _applyFilter();
// //     notifyListeners();
// //   }

// //   void _applyFilter() {
// //     List<MedicineModel> result = _medicines;

// //     if (_selectedFilter == 'Active') {
// //       result = _medicineViewModel.getActiveMedicines(result);
// //     } else if (_selectedFilter == 'Completed') {
// //       result = _medicineViewModel.getCompletedMedicines(result);
// //     }

// //     if (_searchQuery.isNotEmpty) {
// //       result = _medicineViewModel.searchMedicines(result, _searchQuery);
// //     }

// //     _filteredMedicines = result;
// //   }

// //   void _setLoading(bool value) {
// //     _isLoading = value;
// //     notifyListeners();
// //   }

// //   void _clearError() {
// //     _errorMessage = '';
// //   }
// // }

// import 'package:flutter/material.dart';
// import '../models/medicine_model.dart';
// import '../viewmodels/medicine_viewmodel.dart';
// import '../core/errors/failures.dart';
// import '../services/notification/notification_service.dart';

// class MedicineProvider extends ChangeNotifier {
//   final MedicineViewModel _medicineViewModel = MedicineViewModel();

//   bool _isLoading = false;
//   List<MedicineModel> _medicines = [];
//   List<MedicineModel> _filteredMedicines = [];
//   String _errorMessage = '';
//   String _selectedFilter = 'All';
//   String _searchQuery = '';

//   bool get isLoading => _isLoading;
//   List<MedicineModel> get medicines => _medicines;
//   List<MedicineModel> get filteredMedicines => _filteredMedicines;
//   String get errorMessage => _errorMessage;
//   String get selectedFilter => _selectedFilter;
//   String get searchQuery => _searchQuery;

//   // ─────────────────────────────────────
//   // GET MEDICINES
//   // ─────────────────────────────────────

//   Future<void> getMedicines(String userId) async {
//     try {
//       _setLoading(true);
//       _clearError();
//       _medicines = await _medicineViewModel.getMedicines(userId);
//       _applyFilter();
//     } on CacheFailure catch (e) {
//       _errorMessage = e.message;
//     } on NetworkFailure catch (e) {
//       _errorMessage = e.message;
//     } catch (e) {
//       _errorMessage = 'Something went wrong!';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // ─────────────────────────────────────
//   // ADD MEDICINE
//   // ─────────────────────────────────────

//   Future<bool> addMedicine({
//     required String userId,
//     required String name,
//     required String dosage,
//     required String type,
//     required String frequency,
//     required DateTime startDate,
//     DateTime? endDate,
//     required List<String> reminderTimes,
//     required String priority,
//     String? notes,
//   }) async {
//     try {
//       _setLoading(true);
//       _clearError();

//       await _medicineViewModel.addMedicine(
//         userId: userId,
//         name: name,
//         dosage: dosage,
//         type: type,
//         frequency: frequency,
//         startDate: startDate,
//         endDate: endDate,
//         reminderTimes: reminderTimes,
//         priority: priority,
//         notes: notes,
//       );

//       // Refresh list — newly added medicine ID ke saath
//       await getMedicines(userId);

//       // FIX: orElse diya — StateError nahi aayega ab
//       final newMedicine = _medicines.firstWhere(
//         (m) => m.name == name && m.dosage == dosage && m.frequency == frequency,
//         orElse: () => throw Exception('Newly added medicine not found'),
//       );

//       // Notification schedule karo
//       await NotificationService().scheduleMedicineReminder(newMedicine);

//       return true;
//     } on CacheFailure catch (e) {
//       _errorMessage = e.message;
//       return false;
//     } on NetworkFailure catch (e) {
//       _errorMessage = e.message;
//       return false;
//     } catch (e) {
//       // Notification scheduling fail bhi ho to medicine add toh ho gayi
//       // Sirf agar actual add fail hua to false return karo
//       if (_errorMessage.isEmpty) {
//         debugPrint('Notification scheduling failed (non-critical): $e');
//         return true;
//       }
//       _errorMessage = 'Something went wrong!';
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // ─────────────────────────────────────
//   // DELETE MEDICINE
//   // ─────────────────────────────────────

//   Future<bool> deleteMedicine(String userId, String medicineId) async {
//     try {
//       _setLoading(true);
//       _clearError();

//       // FIX: orElse diya — StateError nahi aayega
//       final medicineToDelete = _medicines.firstWhere(
//         (m) => m.id == medicineId,
//         orElse: () => throw Exception('Medicine not found for ID: $medicineId'),
//       );

//       // Pehle notification cancel karo
//       await NotificationService().cancelMedicineReminders(medicineToDelete);

//       // Phir delete karo
//       await _medicineViewModel.deleteMedicine(userId, medicineId);

//       _medicines.removeWhere((m) => m.id == medicineId);
//       _applyFilter();
//       return true;
//     } on CacheFailure catch (e) {
//       _errorMessage = e.message;
//       return false;
//     } on NetworkFailure catch (e) {
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
//   // SYNC
//   // ─────────────────────────────────────

//   Future<void> syncPendingMedicines() async {
//     await _medicineViewModel.syncPendingMedicines();
//   }

//   // ─────────────────────────────────────
//   // FILTER & SEARCH
//   // ─────────────────────────────────────

//   List<MedicineModel> getActiveMedicines() {
//     return _medicineViewModel.getActiveMedicines(_medicines);
//   }

//   List<MedicineModel> getCompletedMedicines() {
//     return _medicineViewModel.getCompletedMedicines(_medicines);
//   }

//   List<MedicineModel> searchMedicines(String query) {
//     return _medicineViewModel.searchMedicines(_medicines, query);
//   }

//   void setFilter(String filter) {
//     _selectedFilter = filter;
//     _applyFilter();
//     notifyListeners();
//   }

//   void setSearchQuery(String query) {
//     _searchQuery = query;
//     _applyFilter();
//     notifyListeners();
//   }

//   void _applyFilter() {
//     List<MedicineModel> result = _medicines;

//     if (_selectedFilter == 'Active') {
//       result = _medicineViewModel.getActiveMedicines(result);
//     } else if (_selectedFilter == 'Completed') {
//       result = _medicineViewModel.getCompletedMedicines(result);
//     }

//     if (_searchQuery.isNotEmpty) {
//       result = _medicineViewModel.searchMedicines(result, _searchQuery);
//     }

//     _filteredMedicines = result;
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

import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../viewmodels/medicine_viewmodel.dart';
import '../core/errors/failures.dart';
import '../services/notification/notification_service.dart';

class MedicineProvider extends ChangeNotifier {
  final MedicineViewModel _medicineViewModel = MedicineViewModel();

  bool _isLoading = false;
  List<MedicineModel> _medicines = [];
  List<MedicineModel> _filteredMedicines = [];
  String _errorMessage = '';
  String _selectedFilter = 'All';
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  List<MedicineModel> get medicines => _medicines;
  List<MedicineModel> get filteredMedicines => _filteredMedicines;
  String get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  // ─────────────────────────────────────
  // GET MEDICINES
  // ─────────────────────────────────────

  Future<void> getMedicines(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      _medicines = await _medicineViewModel.getMedicines(userId);
      _applyFilter();
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
    } on NetworkFailure catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // ADD MEDICINE
  // ─────────────────────────────────────

  Future<bool> addMedicine({
    required String userId,
    required String name,
    required String dosage,
    required String type,
    required String frequency,
    required DateTime startDate,
    DateTime? endDate,
    required List<String> reminderTimes,
    required String priority,
    String? notes,
    String? memberId, // null = main user, non-null = family member
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _medicineViewModel.addMedicine(
        userId: userId,
        name: name,
        dosage: dosage,
        type: type,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        reminderTimes: reminderTimes,
        priority: priority,
        notes: notes,
        memberId: memberId,
      );

      await getMedicines(userId);

      final newMedicine = _medicines.firstWhere(
        (m) => m.name == name && m.dosage == dosage && m.frequency == frequency,
        orElse: () => throw Exception('Newly added medicine not found'),
      );

      await NotificationService().scheduleMedicineReminder(newMedicine);

      return true;
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      if (_errorMessage.isEmpty) {
        debugPrint('Notification scheduling failed (non-critical): $e');
        return true;
      }
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // DELETE MEDICINE
  // ─────────────────────────────────────

  Future<bool> deleteMedicine(String userId, String medicineId) async {
    try {
      _setLoading(true);
      _clearError();

      final medicineToDelete = _medicines.firstWhere(
        (m) => m.id == medicineId,
        orElse: () => throw Exception('Medicine not found for ID: $medicineId'),
      );

      await NotificationService().cancelMedicineReminders(medicineToDelete);
      await _medicineViewModel.deleteMedicine(userId, medicineId);

      _medicines.removeWhere((m) => m.id == medicineId);
      _applyFilter();
      return true;
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkFailure catch (e) {
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
  // SYNC
  // ─────────────────────────────────────

  Future<void> syncPendingMedicines() async {
    await _medicineViewModel.syncPendingMedicines();
  }

  // ─────────────────────────────────────
  // FILTER & SEARCH
  // ─────────────────────────────────────

  List<MedicineModel> getActiveMedicines() {
    return _medicineViewModel.getActiveMedicines(_medicines);
  }

  List<MedicineModel> getCompletedMedicines() {
    return _medicineViewModel.getCompletedMedicines(_medicines);
  }

  List<MedicineModel> searchMedicines(String query) {
    return _medicineViewModel.searchMedicines(_medicines, query);
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    List<MedicineModel> result = _medicines;

    if (_selectedFilter == 'Active') {
      result = _medicineViewModel.getActiveMedicines(result);
    } else if (_selectedFilter == 'Completed') {
      result = _medicineViewModel.getCompletedMedicines(result);
    }

    if (_searchQuery.isNotEmpty) {
      result = _medicineViewModel.searchMedicines(result, _searchQuery);
    }

    _filteredMedicines = result;
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
