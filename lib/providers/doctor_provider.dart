// import 'package:flutter/material.dart';
// import '../models/doctor_model.dart';
// import '../viewmodels/doctor_viewmodel.dart';
// import '../core/errors/failures.dart';
// import '../services/notification/notification_service.dart';

// class DoctorProvider extends ChangeNotifier {
//   final DoctorViewModel _doctorViewModel = DoctorViewModel();

//   // ─────────────────────────────────────
//   // STATES
//   // ─────────────────────────────────────

//   bool _isLoading = false;
//   List<DoctorModel> _doctors = [];
//   List<DoctorModel> _upcomingDoctors = [];
//   List<DoctorModel> _pastDoctors = [];
//   String _errorMessage = '';
//   String _searchQuery = '';

//   // Getters
//   bool get isLoading => _isLoading;
//   List<DoctorModel> get doctors => _doctors;
//   List<DoctorModel> get upcomingDoctors => _upcomingDoctors;
//   List<DoctorModel> get pastDoctors => _pastDoctors;
//   String get errorMessage => _errorMessage;
//   String get searchQuery => _searchQuery;

//   // ─────────────────────────────────────
//   // GET DOCTORS
//   // ─────────────────────────────────────

//   Future<void> getDoctors(String userId) async {
//     try {
//       _setLoading(true);
//       _clearError();

//       // DoctorViewModel se doctors lo
//       // ViewModel → Repository → SQLite/Firestore
//       _doctors = await _doctorViewModel.getDoctors(userId);

//       // Upcoming aur Past alag karo
//       _upcomingDoctors = _doctorViewModel.getUpcomingAppointments(_doctors);
//       _pastDoctors = _doctorViewModel.getPastAppointments(_doctors);
//     } on CacheFailure catch (e) {
//       _errorMessage = e.message;
//     } catch (e) {
//       _errorMessage = 'Something went wrong!';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // ─────────────────────────────────────
//   // ADD DOCTOR
//   // ─────────────────────────────────────

//   Future<bool> addDoctor({
//     required String userId,
//     required String doctorName,
//     required String speciality,
//     required String clinicName,
//     String? phone,
//     String? address,
//     required DateTime appointmentDate,
//     String? notes,
//   }) async {
//     try {
//       _setLoading(true);
//       _clearError();

//       // DoctorViewModel ko data do
//       // ViewModel → Repository → SQLite save → Firestore sync
//       await _doctorViewModel.addDoctor(
//         userId: userId,
//         doctorName: doctorName,
//         speciality: speciality,
//         clinicName: clinicName,
//         phone: phone,
//         address: address,
//         appointmentDate: appointmentDate,
//         notes: notes,
//       );

//       // Refresh doctors list
//       await getDoctors(userId);

//       // Schedule appointment notification
//       try {
//         final newDoctor = _doctors.firstWhere(
//           (d) =>
//               d.doctorName == doctorName &&
//               d.appointmentDate == appointmentDate,
//         );
//         await NotificationService().scheduleAppointmentReminder(newDoctor);
//       } catch (e) {
//         print(
//           "Could not find newly added appointment for notifications scheduling: $e",
//         );
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
//   // DELETE DOCTOR
//   // ─────────────────────────────────────

//   Future<bool> deleteDoctor(String userId, String doctorId) async {
//     try {
//       _setLoading(true);
//       _clearError();

//       // DoctorViewModel ko delete karne do
//       // ViewModel → Repository → SQLite delete → Firestore delete
//       await _doctorViewModel.deleteDoctor(userId, doctorId);

//       // Cancel notification before removing
//       try {
//         final doctorToDelete = _doctors.firstWhere((d) => d.id == doctorId);
//         await NotificationService().cancelAppointmentReminder(doctorToDelete);
//       } catch (e) {
//         print("Could not cancel notifications for deleted appointment: $e");
//       }

//       // Remove from local list — UI instantly update hoga
//       _doctors.removeWhere((d) => d.id == doctorId);
//       _upcomingDoctors.removeWhere((d) => d.id == doctorId);
//       _pastDoctors.removeWhere((d) => d.id == doctorId);
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
//   // MARK APPOINTMENT DONE
//   // ─────────────────────────────────────

//   Future<void> markAppointmentDone(String userId, String doctorId) async {
//     try {
//       // ViewModel → Repository → Firestore update
//       await _doctorViewModel.markAppointmentDone(userId, doctorId);

//       // Cancel notification as appointment is done
//       try {
//         final doctorMarkedDone = _doctors.firstWhere((d) => d.id == doctorId);
//         await NotificationService().cancelAppointmentReminder(doctorMarkedDone);
//       } catch (e) {
//         print("Could not cancel notifications for done appointment: $e");
//       }

//       // Refresh doctors list
//       await getDoctors(userId);
//     } catch (e) {
//       _errorMessage = 'Something went wrong!';
//       notifyListeners();
//     }
//   }

//   // ─────────────────────────────────────
//   // SEARCH
//   // ─────────────────────────────────────

//   void setSearchQuery(String query) {
//     _searchQuery = query;
//     if (query.isEmpty) {
//       _upcomingDoctors = _doctorViewModel.getUpcomingAppointments(_doctors);
//       _pastDoctors = _doctorViewModel.getPastAppointments(_doctors);
//     } else {
//       _upcomingDoctors = _doctorViewModel.searchDoctors(
//         _upcomingDoctors,
//         query,
//       );
//       _pastDoctors = _doctorViewModel.searchDoctors(_pastDoctors, query);
//     }
//     notifyListeners();
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
import '../models/doctor_model.dart';
import '../viewmodels/doctor_viewmodel.dart';
import '../core/errors/failures.dart';
import '../services/notification/notification_service.dart';

class DoctorProvider extends ChangeNotifier {
  final DoctorViewModel _doctorViewModel = DoctorViewModel();

  bool _isLoading = false;
  List<DoctorModel> _doctors = [];
  List<DoctorModel> _upcomingDoctors = [];
  List<DoctorModel> _pastDoctors = [];
  String _errorMessage = '';
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  List<DoctorModel> get doctors => _doctors;
  List<DoctorModel> get upcomingDoctors => _upcomingDoctors;
  List<DoctorModel> get pastDoctors => _pastDoctors;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // ─────────────────────────────────────
  // GET DOCTORS
  // ─────────────────────────────────────

  Future<void> getDoctors(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      _doctors = await _doctorViewModel.getDoctors(userId);
      _upcomingDoctors = _doctorViewModel.getUpcomingAppointments(_doctors);
      _pastDoctors = _doctorViewModel.getPastAppointments(_doctors);
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
    } on NetworkFailure catch (e) {
      // FIX: NetworkFailure bhi handle karo — pehle missing tha
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // ADD DOCTOR
  // ─────────────────────────────────────

  Future<bool> addDoctor({
    required String userId,
    required String doctorName,
    required String speciality,
    required String clinicName,
    String? phone,
    String? address,
    required DateTime appointmentDate,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _doctorViewModel.addDoctor(
        userId: userId,
        doctorName: doctorName,
        speciality: speciality,
        clinicName: clinicName,
        phone: phone,
        address: address,
        appointmentDate: appointmentDate,
        notes: notes,
      );

      // Refresh list
      await getDoctors(userId);

      // FIX: orElse diya — StateError nahi aayega
      // FIX: DateTime == comparison unreliable — doctor name + speciality se match karo
      //      aur appointmentDate ko minute level pe compare karo (milliseconds ignore)
      final newDoctor = _doctors.firstWhere(
        (d) =>
            d.doctorName == doctorName &&
            d.speciality == speciality &&
            d.appointmentDate.year == appointmentDate.year &&
            d.appointmentDate.month == appointmentDate.month &&
            d.appointmentDate.day == appointmentDate.day &&
            d.appointmentDate.hour == appointmentDate.hour &&
            d.appointmentDate.minute == appointmentDate.minute,
        orElse: () =>
            throw Exception('Newly added appointment not found in list'),
      );

      // Notification schedule karo
      await NotificationService().scheduleAppointmentReminder(newDoctor);

      return true;
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkFailure catch (e) {
      // FIX: NetworkFailure bhi handle karo
      _errorMessage = e.message;
      return false;
    } catch (e) {
      // Notification fail bhi ho to doctor toh add ho gaya
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
  // DELETE DOCTOR
  // ─────────────────────────────────────

  Future<bool> deleteDoctor(String userId, String doctorId) async {
    try {
      _setLoading(true);
      _clearError();

      // FIX: orElse diya — StateError nahi aayega
      final doctorToDelete = _doctors.firstWhere(
        (d) => d.id == doctorId,
        orElse: () => throw Exception('Doctor not found for ID: $doctorId'),
      );

      // Pehle notification cancel karo
      await NotificationService().cancelAppointmentReminder(doctorToDelete);

      // Phir delete karo
      await _doctorViewModel.deleteDoctor(userId, doctorId);

      _doctors.removeWhere((d) => d.id == doctorId);
      _upcomingDoctors.removeWhere((d) => d.id == doctorId);
      _pastDoctors.removeWhere((d) => d.id == doctorId);
      return true;
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkFailure catch (e) {
      // FIX: NetworkFailure bhi handle karo
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
  // MARK APPOINTMENT DONE
  // ─────────────────────────────────────

  Future<void> markAppointmentDone(String userId, String doctorId) async {
    try {
      await _doctorViewModel.markAppointmentDone(userId, doctorId);

      // FIX: orElse diya
      final doctorMarkedDone = _doctors.firstWhere(
        (d) => d.id == doctorId,
        orElse: () => throw Exception('Doctor not found: $doctorId'),
      );

      await NotificationService().cancelAppointmentReminder(doctorMarkedDone);

      await getDoctors(userId);
    } catch (e) {
      debugPrint('markAppointmentDone error: $e');
      _errorMessage = 'Something went wrong!';
      notifyListeners();
    }
  }

  // ─────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _upcomingDoctors = _doctorViewModel.getUpcomingAppointments(_doctors);
      _pastDoctors = _doctorViewModel.getPastAppointments(_doctors);
    } else {
      _upcomingDoctors = _doctorViewModel.searchDoctors(
        _upcomingDoctors,
        query,
      );
      _pastDoctors = _doctorViewModel.searchDoctors(_pastDoctors, query);
    }
    notifyListeners();
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
