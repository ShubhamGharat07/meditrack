import '../models/medicine_model.dart';
import '../repositories/medicine_repository.dart';
import '../core/errors/failures.dart';

class MedicineViewModel {
  final MedicineRepository _medicineRepository = MedicineRepository();

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
    if (name.isEmpty) throw CacheFailure();
    if (dosage.isEmpty) throw CacheFailure();
    if (type.isEmpty) throw CacheFailure();
    if (frequency.isEmpty) throw CacheFailure();
    if (reminderTimes.isEmpty) throw CacheFailure();

    await _medicineRepository.addMedicine(
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
  }

  // ─────────────────────────────────────
  // GET MEDICINES
  // ─────────────────────────────────────

  Future<List<MedicineModel>> getMedicines(String userId) async {
    if (userId.isEmpty) throw CacheFailure();
    return await _medicineRepository.getMedicines(userId);
  }

  // ─────────────────────────────────────
  // DELETE MEDICINE
  // ─────────────────────────────────────

  Future<void> deleteMedicine(String userId, String medicineId) async {
    if (userId.isEmpty || medicineId.isEmpty) throw CacheFailure();
    await _medicineRepository.deleteMedicine(userId, medicineId);
  }

  // ─────────────────────────────────────
  // SYNC PENDING MEDICINES
  // ─────────────────────────────────────

  Future<void> syncPendingMedicines() async {
    await _medicineRepository.syncPendingMedicines();
  }

  // ─────────────────────────────────────
  // FILTER MEDICINES
  // ─────────────────────────────────────

  List<MedicineModel> filterByPriority(
    List<MedicineModel> medicines,
    String priority,
  ) {
    if (priority == 'All') return medicines;
    return medicines.where((m) => m.priority == priority).toList();
  }

  List<MedicineModel> getActiveMedicines(List<MedicineModel> medicines) {
    final now = DateTime.now();
    return medicines.where((m) {
      if (m.endDate == null) return true;
      return m.endDate!.isAfter(now);
    }).toList();
  }

  List<MedicineModel> getCompletedMedicines(List<MedicineModel> medicines) {
    final now = DateTime.now();
    return medicines.where((m) {
      if (m.endDate == null) return false;
      return m.endDate!.isBefore(now);
    }).toList();
  }

  List<MedicineModel> searchMedicines(
    List<MedicineModel> medicines,
    String query,
  ) {
    if (query.isEmpty) return medicines;
    return medicines
        .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
