// import 'dart:io';
// import 'package:uuid/uuid.dart';
// import '../models/health_record_model.dart';
// import '../services/firebase/firestore_service.dart';
// import '../services/firebase/storage_service.dart';
// import '../services/local/sqlite_service.dart';
// import '../core/errors/failures.dart';
// import '../core/network/internet_checker.dart';

// class HealthRecordRepository {
//   final FirestoreService _firestoreService = FirestoreService();
//   final StorageService _storageService = StorageService();
//   final SQLiteService _sqliteService = SQLiteService();
//   final InternetChecker _internetChecker = InternetChecker();
//   final Uuid _uuid = const Uuid();

//   // ─────────────────────────────────────
//   // ADD HEALTH RECORD
//   // ─────────────────────────────────────

//   Future<void> addHealthRecord({
//     required String userId,
//     required String title,
//     required String category,
//     required File file,
//     required String fileType,
//     String? notes,
//   }) async {
//     try {
//       final isConnected = await _internetChecker.isConnected();
//       if (!isConnected) throw NetworkFailure();

//       final recordId = _uuid.v4();

//       // Upload file to Firebase Storage
//       final fileUrl = await _storageService.uploadHealthRecord(
//         userId,
//         recordId,
//         file,
//         fileType,
//       );

//       final record = HealthRecordModel(
//         id: recordId,
//         userId: userId,
//         title: title,
//         category: category,
//         fileUrl: fileUrl,
//         fileType: fileType,
//         notes: notes,
//         isSynced: true,
//         createdAt: DateTime.now(),
//       );

//       // Save to Firestore
//       await _firestoreService.saveHealthRecord(record);

//       // Save to SQLite
//       await _sqliteService.saveHealthRecord(record);
//     } on NetworkFailure {
//       rethrow;
//     } catch (e) {
//       throw ServerFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // GET HEALTH RECORDS
//   // ─────────────────────────────────────

//   Future<List<HealthRecordModel>> getHealthRecords(String userId) async {
//     try {
//       // Load from SQLite first — instant load
//       final localRecords = await _sqliteService.getHealthRecords(userId);

//       // If online — sync from Firestore
//       final isConnected = await _internetChecker.isConnected();
//       if (isConnected) {
//         final remoteRecords = await _firestoreService.getHealthRecords(userId);

//         // Save remote records to SQLite
//         for (final record in remoteRecords) {
//           await _sqliteService.saveHealthRecord(record);
//         }

//         return remoteRecords;
//       }

//       return localRecords;
//     } catch (e) {
//       throw CacheFailure();
//     }
//   }

//   // ─────────────────────────────────────
//   // DELETE HEALTH RECORD
//   // ─────────────────────────────────────

//   Future<void> deleteHealthRecord(
//     String userId,
//     String recordId,
//     String fileType,
//   ) async {
//     try {
//       final isConnected = await _internetChecker.isConnected();
//       if (!isConnected) throw NetworkFailure();

//       // Delete file from Firebase Storage
//       await _storageService.deleteHealthRecord(userId, recordId, fileType);

//       // Delete from Firestore
//       await _firestoreService.deleteHealthRecord(userId, recordId);

//       // Delete from SQLite
//       await _sqliteService.deleteHealthRecord(recordId);
//     } on NetworkFailure {
//       rethrow;
//     } catch (e) {
//       throw ServerFailure(e.toString());
//     }
//   }
// }

import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/health_record_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/storage_service.dart';
import '../services/local/sqlite_service.dart';
import '../core/errors/failures.dart';
import '../core/network/internet_checker.dart';

class HealthRecordRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final SQLiteService _sqliteService = SQLiteService();
  final InternetChecker _internetChecker = InternetChecker();
  final Uuid _uuid = const Uuid();

  // ADD HEALTH RECORD
  Future<void> addHealthRecord({
    required String userId,
    required String title,
    required String category,
    File? file,
    String fileType = '',
    String? notes,
  }) async {
    try {
      final recordId = _uuid.v4();
      String fileUrl = '';

      // File upload sirf tab karo jab file ho aur internet ho
      if (file != null) {
        final isConnected = await _internetChecker.isConnected();
        if (!isConnected) throw NetworkFailure();

        fileUrl = await _storageService.uploadHealthRecord(
          userId,
          recordId,
          file,
          fileType,
        );
      }

      final record = HealthRecordModel(
        id: recordId,
        userId: userId,
        title: title,
        category: category,
        fileUrl: fileUrl,
        fileType: fileType,
        notes: notes,
        isSynced: file != null, // File hai to synced, nahi to false
        createdAt: DateTime.now(),
      );

      // File hai to Firestore mein save karo
      if (file != null) {
        await _firestoreService.saveHealthRecord(record);
      }

      // SQLite mein hamesha save karo
      await _sqliteService.saveHealthRecord(record);
    } on NetworkFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  // GET HEALTH RECORDS
  Future<List<HealthRecordModel>> getHealthRecords(String userId) async {
    try {
      // SQLite se pehle load karo
      final localRecords = await _sqliteService.getHealthRecords(userId);

      // Online hai to Firestore se sync karo
      final isConnected = await _internetChecker.isConnected();
      if (isConnected) {
        final remoteRecords = await _firestoreService.getHealthRecords(userId);

        for (final record in remoteRecords) {
          await _sqliteService.saveHealthRecord(record);
        }

        return remoteRecords;
      }

      return localRecords;
    } catch (e) {
      throw CacheFailure();
    }
  }

  // DELETE HEALTH RECORD
  Future<void> deleteHealthRecord(
    String userId,
    String recordId,
    String fileUrl,
  ) async {
    try {
      final isConnected = await _internetChecker.isConnected();
      if (!isConnected) throw NetworkFailure();

      // FileUrl hai to Storage se delete karo
      if (fileUrl.isNotEmpty) {
        await _storageService.deleteHealthRecord(userId, recordId, fileUrl);
      }

      // Firestore se delete karo
      await _firestoreService.deleteHealthRecord(userId, recordId);

      // SQLite se delete karo
      await _sqliteService.deleteHealthRecord(recordId);
    } on NetworkFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
