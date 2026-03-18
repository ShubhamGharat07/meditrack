import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/health_insurance_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/storage_service.dart';
import '../services/local/sqlite_service.dart';
import '../core/errors/failures.dart';
import '../core/network/internet_checker.dart';

class HealthInsuranceRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final SQLiteService _sqliteService = SQLiteService();
  final StorageService _storageService = StorageService();
  final InternetChecker _internetChecker = InternetChecker();
  final Uuid _uuid = const Uuid();

  // ─────────────────────────────────────
  // ADD POLICY
  // ─────────────────────────────────────

  Future<void> addPolicy({
    required String userId,
    required String providerName,
    required String policyNumber,
    required DateTime startDate,
    required DateTime endDate,
    required String coverageAmount,
    required String agentContact,
    required List<String> coveredMembers,
    File? docFile,
    String? docType,
  }) async {
    try {
      final id = _uuid.v4();
      String? docUrl;

      // Doc upload — requires internet
      final isConnected = await _internetChecker.isConnected();
      if (docFile != null && docType != null && isConnected) {
        docUrl = await _storageService.uploadInsurancePolicyDoc(
          userId,
          id,
          docFile,
          docType,
        );
      }

      final policy = HealthInsuranceModel(
        id: id,
        userId: userId,
        providerName: providerName,
        policyNumber: policyNumber,
        startDate: startDate,
        endDate: endDate,
        coverageAmount: coverageAmount,
        agentContact: agentContact,
        coveredMembers: coveredMembers,
        docUrl: docUrl,
        docType: docType,
        isSynced: false,
        createdAt: DateTime.now(),
      );

      await _sqliteService.saveHealthInsurance(policy);

      if (isConnected) {
        await _firestoreService.saveHealthInsurance(policy);
        await _sqliteService.markHealthInsuranceSynced(id);
      }
    } catch (e) {
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // GET POLICIES
  // ─────────────────────────────────────

  Future<List<HealthInsuranceModel>> getPolicies(String userId) async {
    try {
      final localPolicies = await _sqliteService.getHealthInsurances(userId);
      final isConnected = await _internetChecker.isConnected();

      if (isConnected) {
        final remotePolicies = await _firestoreService.getHealthInsurances(
          userId,
        );
        for (final p in remotePolicies) {
          await _sqliteService.saveHealthInsurance(p);
        }
        return remotePolicies;
      }

      return localPolicies;
    } catch (e) {
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // UPDATE POLICY
  // ─────────────────────────────────────

  Future<void> updatePolicy({
    required HealthInsuranceModel policy,
    File? newDocFile,
    String? newDocType,
  }) async {
    try {
      final isConnected = await _internetChecker.isConnected();
      String? docUrl = policy.docUrl;
      String? docType = policy.docType;

      if (newDocFile != null && newDocType != null && isConnected) {
        docUrl = await _storageService.uploadInsurancePolicyDoc(
          policy.userId,
          policy.id,
          newDocFile,
          newDocType,
        );
        docType = newDocType;
      }

      final updated = policy.copyWith(docUrl: docUrl, docType: docType);

      await _sqliteService.saveHealthInsurance(updated);

      if (isConnected) {
        await _firestoreService.saveHealthInsurance(updated);
        await _sqliteService.markHealthInsuranceSynced(policy.id);
      }
    } catch (e) {
      throw CacheFailure();
    }
  }

  // ─────────────────────────────────────
  // DELETE POLICY
  // ─────────────────────────────────────

  Future<void> deletePolicy(
    String userId,
    String policyId, {
    String? docType,
  }) async {
    try {
      await _sqliteService.deleteHealthInsurance(policyId);

      final isConnected = await _internetChecker.isConnected();
      if (isConnected) {
        await _firestoreService.deleteHealthInsurance(userId, policyId);
        if (docType != null) {
          try {
            await _storageService.deleteInsurancePolicyDoc(
              userId,
              policyId,
              docType,
            );
          } catch (_) {}
        }
      }
    } catch (e) {
      throw CacheFailure();
    }
  }
}
