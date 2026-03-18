import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─────────────────────────────────────
  // HEALTH RECORDS
  // ─────────────────────────────────────

  Future<String> uploadHealthRecord(
    String userId,
    String recordId,
    File file,
    String fileType,
  ) async {
    final ref = _storage
        .ref()
        .child('health_records')
        .child(userId)
        .child('$recordId.$fileType');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteHealthRecord(
    String userId,
    String recordId,
    String fileType,
  ) async {
    final ref = _storage
        .ref()
        .child('health_records')
        .child(userId)
        .child('$recordId.$fileType');
    await ref.delete();
  }

  // ─────────────────────────────────────
  // PROFILE PHOTO
  // ─────────────────────────────────────

  Future<String> uploadProfilePhoto(String userId, File file) async {
    final ref = _storage.ref().child('profile_photos').child('$userId.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteProfilePhoto(String userId) async {
    final ref = _storage.ref().child('profile_photos').child('$userId.jpg');
    await ref.delete();
  }

  // ─────────────────────────────────────
  // FAMILY MEMBER PHOTO
  // ─────────────────────────────────────

  Future<String> uploadFamilyPhoto(
    String userId,
    String memberId,
    File file,
  ) async {
    final ref = _storage
        .ref()
        .child('family_photos')
        .child(userId)
        .child('$memberId.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteFamilyPhoto(String userId, String memberId) async {
    final ref = _storage
        .ref()
        .child('family_photos')
        .child(userId)
        .child('$memberId.jpg');
    await ref.delete();
  }

  Future<String> uploadFamilyMemberPhoto(
    String userId,
    String memberId,
    File file,
  ) => uploadFamilyPhoto(userId, memberId, file);

  Future<void> deleteFamilyMemberPhoto(String userId, String memberId) =>
      deleteFamilyPhoto(userId, memberId);

  // ─────────────────────────────────────
  // INSURANCE DOCUMENT (Family Member)
  // ─────────────────────────────────────

  Future<String> uploadInsuranceDocument(
    String userId,
    String memberId,
    File file,
    String fileType,
  ) async {
    final ref = _storage
        .ref()
        .child('family_insurance')
        .child(userId)
        .child('$memberId.$fileType');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteInsuranceDocument(
    String userId,
    String memberId,
    String fileType,
  ) async {
    final ref = _storage
        .ref()
        .child('family_insurance')
        .child(userId)
        .child('$memberId.$fileType');
    await ref.delete();
  }

  Future<void> deleteAllMemberFiles({
    required String userId,
    required String memberId,
    String? insuranceDocType,
  }) async {
    try {
      await deleteFamilyPhoto(userId, memberId);
    } catch (_) {}
    if (insuranceDocType != null) {
      try {
        await deleteInsuranceDocument(userId, memberId, insuranceDocType);
      } catch (_) {}
    }
  }

  // ─────────────────────────────────────
  // HEALTH INSURANCE POLICY DOCUMENT
  // ─────────────────────────────────────

  Future<String> uploadInsurancePolicyDoc(
    String userId,
    String policyId,
    File file,
    String fileType,
  ) async {
    final ref = _storage
        .ref()
        .child('health_insurance')
        .child(userId)
        .child('$policyId.$fileType');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteInsurancePolicyDoc(
    String userId,
    String policyId,
    String fileType,
  ) async {
    final ref = _storage
        .ref()
        .child('health_insurance')
        .child(userId)
        .child('$policyId.$fileType');
    await ref.delete();
  }
}
