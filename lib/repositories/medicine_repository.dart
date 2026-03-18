// import 'package:uuid/uuid.dart';
// import '../models/medicine_model.dart';
// import '../services/firebase/firestore_service.dart';
// import '../services/local/sqlite_service.dart';
// import '../services/local/shared_pref_service.dart';
// import '../core/errors/failures.dart';
// import '../core/network/internet_checker.dart';

// class MedicineRepository {
//   final FirestoreService _firestoreService = FirestoreService();
//   final SQLiteService _sqliteService = SQLiteService();
//   final SharedPrefService _sharedPrefService = SharedPrefService();
//   final InternetChecker _internetChecker = InternetChecker();
//   final Uuid _uuid = const Uuid();

//   // ─────────────────────────────────────
//   // ADD MEDICINE
//   // ─────────────────────────────────────

//   Future<void> addMedicine({
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
//       final medicine = MedicineModel(
//         id: _uuid.v4(),
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
//         isSynced: false,
//         createdAt: DateTime.now(),
//       );

//       // Save to SQLite first — offline safe
//       await _sqliteService.saveMedicine(medicine);

//       // If online — sync to Firestore
//       final isConnected = await _internetChecker.isConnected();
//       if (isConnected) {
//         await _firestoreService.saveMedicine(medicine);
//         await _sqliteService.markMedicineSynced(medicine.id);
//       }
//     } catch (e) {
//       throw CacheFailure();
//     }
//   }

//   // ─────────────────────────────────────
//   // GET MEDICINES
//   // ─────────────────────────────────────

//   Future<List<MedicineModel>> getMedicines(String userId) async {
//     try {
//       // Always load from SQLite first — instant load
//       final localMedicines = await _sqliteService.getMedicines(userId);

//       // If online — sync from Firestore in background
//       final isConnected = await _internetChecker.isConnected();
//       if (isConnected) {
//         final remoteMedicines = await _firestoreService.getMedicines(userId);

//         // Save remote medicines to SQLite
//         for (final medicine in remoteMedicines) {
//           await _sqliteService.saveMedicine(medicine);
//         }

//         return remoteMedicines;
//       }

//       return localMedicines;
//     } catch (e) {
//       throw CacheFailure();
//     }
//   }

//   // ─────────────────────────────────────
//   // DELETE MEDICINE
//   // ─────────────────────────────────────

//   Future<void> deleteMedicine(String userId, String medicineId) async {
//     try {
//       // Delete from SQLite
//       await _sqliteService.deleteMedicine(medicineId);

//       // If online — delete from Firestore
//       final isConnected = await _internetChecker.isConnected();
//       if (isConnected) {
//         await _firestoreService.deleteMedicine(userId, medicineId);
//       }
//     } catch (e) {
//       throw CacheFailure();
//     }
//   }

//   // ─────────────────────────────────────
//   // SYNC PENDING MEDICINES
//   // ─────────────────────────────────────

//   // Sync all unsynced medicines to Firestore
//   Future<void> syncPendingMedicines() async {
//     try {
//       final isConnected = await _internetChecker.isConnected();
//       if (!isConnected) return;

//       // Get all unsynced medicines from SQLite
//       final unsyncedMedicines = await _sqliteService.getUnsyncedMedicines();

//       // Sync each medicine to Firestore
//       for (final medicine in unsyncedMedicines) {
//         await _firestoreService.saveMedicine(medicine);
//         await _sqliteService.markMedicineSynced(medicine.id);
//       }
//     } catch (e) {
//       throw ServerFailure(e.toString());
//     }
//   }
// }

import 'package:uuid/uuid.dart';
import '../models/medicine_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/local/sqlite_service.dart';
import '../services/local/shared_pref_service.dart';
import '../core/errors/failures.dart';
import '../core/network/internet_checker.dart';

class MedicineRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final SQLiteService _sqliteService = SQLiteService();
  final SharedPrefService _sharedPrefService = SharedPrefService();
  final InternetChecker _internetChecker = InternetChecker();
  final Uuid _uuid = const Uuid();

  // ─────────────────────────────────────
  // ADD MEDICINE
  // ─────────────────────────────────────

  Future<void> addMedicine({
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
      final medicine = MedicineModel(
        id: _uuid.v4(),
        userId: userId,
        memberId: memberId,
        name: name,
        dosage: dosage,
        type: type,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        reminderTimes: reminderTimes,
        priority: priority,
        notes: notes,
        isSynced: false,
        createdAt: DateTime.now(),
      );

      await _sqliteService.saveMedicine(medicine);

      final isConnected = await _internetChecker.isConnected();
      if (isConnected) {
        await _firestoreService.saveMedicine(medicine);
        await _sqliteService.markMedicineSynced(medicine.id);
      }
    } catch (e) {
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // GET MEDICINES
  // ─────────────────────────────────────

  Future<List<MedicineModel>> getMedicines(String userId) async {
    try {
      final localMedicines = await _sqliteService.getMedicines(userId);

      final isConnected = await _internetChecker.isConnected();
      if (isConnected) {
        final remoteMedicines = await _firestoreService.getMedicines(userId);
        for (final medicine in remoteMedicines) {
          await _sqliteService.saveMedicine(medicine);
        }
        return remoteMedicines;
      }

      return localMedicines;
    } catch (e) {
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // DELETE MEDICINE
  // ─────────────────────────────────────

  Future<void> deleteMedicine(String userId, String medicineId) async {
    try {
      await _sqliteService.deleteMedicine(medicineId);

      final isConnected = await _internetChecker.isConnected();
      if (isConnected) {
        await _firestoreService.deleteMedicine(userId, medicineId);
      }
    } catch (e) {
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // SYNC PENDING MEDICINES
  // ─────────────────────────────────────

  Future<void> syncPendingMedicines() async {
    try {
      final isConnected = await _internetChecker.isConnected();
      if (!isConnected) return;

      final unsyncedMedicines = await _sqliteService.getUnsyncedMedicines();
      for (final medicine in unsyncedMedicines) {
        await _firestoreService.saveMedicine(medicine);
        await _sqliteService.markMedicineSynced(medicine.id);
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
