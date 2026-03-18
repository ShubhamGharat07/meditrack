// import 'package:uuid/uuid.dart';
// import '../models/doctor_model.dart';
// import '../services/firebase/firestore_service.dart';
// import '../services/local/sqlite_service.dart';
// import '../core/errors/failures.dart';
// import '../core/network/internet_checker.dart';

// class DoctorRepository {
//   final FirestoreService _firestoreService = FirestoreService();
//   final SQLiteService _sqliteService = SQLiteService();
//   final InternetChecker _internetChecker = InternetChecker();
//   final Uuid _uuid = const Uuid();

//   // ─────────────────────────────────────
//   // ADD DOCTOR
//   // ─────────────────────────────────────

//   Future<void> addDoctor({
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
//       final doctor = DoctorModel(
//         id: _uuid.v4(),
//         userId: userId,
//         doctorName: doctorName,
//         speciality: speciality,
//         clinicName: clinicName,
//         phone: phone,
//         address: address,
//         appointmentDate: appointmentDate,
//         notes: notes,
//         isUpcoming: true,
//         isSynced: false,
//         createdAt: DateTime.now(),
//       );

//       // Save to SQLite first — offline safe
//       await _sqliteService.saveDoctor(doctor);

//       // If online — sync to Firestore
//       final isConnected = await _internetChecker.isConnected();
//       if (isConnected) {
//         await _firestoreService.saveDoctor(doctor);
//         await _sqliteService.markMedicineSynced(doctor.id);
//       }
//     } catch (e) {
//       throw CacheFailure();
//     }
//   }

//   // ─────────────────────────────────────
//   // GET DOCTORS
//   // ─────────────────────────────────────

//   Future<List<DoctorModel>> getDoctors(String userId) async {
//     try {
//       // Always load from SQLite first — instant load
//       final localDoctors = await _sqliteService.getDoctors(userId);

//       // If online — sync from Firestore
//       final isConnected = await _internetChecker.isConnected();
//       if (isConnected) {
//         final remoteDoctors = await _firestoreService.getDoctors(userId);

//         // Save remote doctors to SQLite
//         for (final doctor in remoteDoctors) {
//           await _sqliteService.saveDoctor(doctor);
//         }

//         return remoteDoctors;
//       }

//       return localDoctors;
//     } catch (e) {
//       throw CacheFailure();
//     }
//   }

//   // ─────────────────────────────────────
//   // DELETE DOCTOR
//   // ─────────────────────────────────────

//   Future<void> deleteDoctor(String userId, String doctorId) async {
//     try {
//       // Delete from SQLite
//       await _sqliteService.deleteDoctor(doctorId);

//       // If online — delete from Firestore
//       final isConnected = await _internetChecker.isConnected();
//       if (isConnected) {
//         await _firestoreService.deleteDoctor(userId, doctorId);
//       }
//     } catch (e) {
//       throw CacheFailure();
//     }
//   }

//   // ─────────────────────────────────────
//   // UPDATE DOCTOR — Mark as Past
//   // ─────────────────────────────────────

//   Future<void> markAppointmentDone(String userId, String doctorId) async {
//     try {
//       // Update in Firestore
//       final isConnected = await _internetChecker.isConnected();
//       if (isConnected) {
//         await _firestoreService.updateUser(userId, {'isUpcoming': false});
//       }
//     } catch (e) {
//       throw ServerFailure(e.toString());
//     }
//   }
// }

import 'package:uuid/uuid.dart';
import '../models/doctor_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/local/sqlite_service.dart';
import '../core/errors/failures.dart';
import '../core/network/internet_checker.dart';

class DoctorRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final SQLiteService _sqliteService = SQLiteService();
  final InternetChecker _internetChecker = InternetChecker();
  final Uuid _uuid = const Uuid();

  // ─────────────────────────────────────
  // ADD DOCTOR
  // ─────────────────────────────────────

  Future<void> addDoctor({
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
      final doctor = DoctorModel(
        id: _uuid.v4(),
        userId: userId,
        doctorName: doctorName,
        speciality: speciality,
        clinicName: clinicName,
        phone: phone,
        address: address,
        appointmentDate: appointmentDate,
        notes: notes,
        isUpcoming: true,
        isSynced: false,
        createdAt: DateTime.now(),
      );

      // SQLite mein pehle save karo — offline safe
      await _sqliteService.saveDoctor(doctor);

      // Online ho to Firestore mein bhi save karo
      final isConnected = await _internetChecker.isConnected();
      if (isConnected) {
        await _firestoreService.saveDoctor(doctor);
      }
    } catch (e) {
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // GET DOCTORS
  // ─────────────────────────────────────

  Future<List<DoctorModel>> getDoctors(String userId) async {
    try {
      final localDoctors = await _sqliteService.getDoctors(userId);
      final isConnected = await _internetChecker.isConnected();

      if (isConnected) {
        final remoteDoctors = await _firestoreService.getDoctors(userId);
        for (final doctor in remoteDoctors) {
          await _sqliteService.saveDoctor(doctor);
        }
        return remoteDoctors;
      }

      return localDoctors;
    } catch (e) {
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // DELETE DOCTOR
  // ─────────────────────────────────────

  Future<void> deleteDoctor(String userId, String doctorId) async {
    try {
      await _sqliteService.deleteDoctor(doctorId);
      final isConnected = await _internetChecker.isConnected();
      if (isConnected) {
        await _firestoreService.deleteDoctor(userId, doctorId);
      }
    } catch (e) {
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // MARK APPOINTMENT DONE — FIX: correct Firestore method
  // ─────────────────────────────────────

  Future<void> markAppointmentDone(String userId, String doctorId) async {
    try {
      // SQLite update
      final localDoctors = await _sqliteService.getDoctors(userId);
      final doctor = localDoctors.firstWhere(
        (d) => d.id == doctorId,
        orElse: () => throw Exception('Doctor not found'),
      );
      final updated = DoctorModel(
        id: doctor.id,
        userId: doctor.userId,
        memberId: doctor.memberId,
        doctorName: doctor.doctorName,
        speciality: doctor.speciality,
        clinicName: doctor.clinicName,
        phone: doctor.phone,
        address: doctor.address,
        appointmentDate: doctor.appointmentDate,
        notes: doctor.notes,
        isUpcoming: false, // ← mark done
        isSynced: doctor.isSynced,
        createdAt: doctor.createdAt,
      );
      await _sqliteService.saveDoctor(updated);

      // Firestore update — correct method
      final isConnected = await _internetChecker.isConnected();
      if (isConnected) {
        await _firestoreService.updateDoctorUpcoming(userId, doctorId, false);
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
