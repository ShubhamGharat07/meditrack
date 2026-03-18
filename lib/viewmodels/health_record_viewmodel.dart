import 'dart:io';
import '../models/health_record_model.dart';
import '../repositories/health_record_repository.dart';
import '../core/errors/failures.dart';

class HealthRecordViewModel {
  final HealthRecordRepository _healthRecordRepository =
      HealthRecordRepository();

  Future<void> addHealthRecord({
    required String userId,
    required String title,
    required String category,
    File? file,
    String? fileType,
    String? notes,
  }) async {
    if (title.isEmpty) throw ServerFailure('Title is required!');
    if (category.isEmpty) throw ServerFailure('Category is required!');

    await _healthRecordRepository.addHealthRecord(
      userId: userId,
      title: title,
      category: category,
      file: file,
      fileType: fileType ?? '',
      notes: notes,
    );
  }

  Future<List<HealthRecordModel>> getHealthRecords(String userId) async {
    if (userId.isEmpty) throw ServerFailure('User ID is required!');
    return await _healthRecordRepository.getHealthRecords(userId);
  }

  Future<void> deleteHealthRecord(
    String userId,
    String recordId,
    String fileUrl,
  ) async {
    if (userId.isEmpty || recordId.isEmpty) {
      throw ServerFailure('Invalid record!');
    }
    await _healthRecordRepository.deleteHealthRecord(userId, recordId, fileUrl);
  }

  List<HealthRecordModel> filterByCategory(
    List<HealthRecordModel> records,
    String category,
  ) {
    if (category.isEmpty || category == 'All') return records;
    return records.where((r) => r.category == category).toList();
  }

  List<HealthRecordModel> searchRecords(
    List<HealthRecordModel> records,
    String query,
  ) {
    if (query.isEmpty) return records;
    return records
        .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<HealthRecordModel> sortByDate(List<HealthRecordModel> records) {
    return records..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
