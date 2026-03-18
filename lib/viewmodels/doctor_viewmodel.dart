import '../models/doctor_model.dart';
import '../repositories/doctor_repository.dart';
import '../core/errors/failures.dart';

class DoctorViewModel {
  final DoctorRepository _doctorRepository = DoctorRepository();

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
    // Validate fields
    if (doctorName.isEmpty) {
      throw CacheFailure();
    }
    if (speciality.isEmpty) {
      throw CacheFailure();
    }
    if (clinicName.isEmpty) {
      throw CacheFailure();
    }

    await _doctorRepository.addDoctor(
      userId: userId,
      doctorName: doctorName,
      speciality: speciality,
      clinicName: clinicName,
      phone: phone,
      address: address,
      appointmentDate: appointmentDate,
      notes: notes,
    );
  }

  // ─────────────────────────────────────
  // GET DOCTORS
  // ─────────────────────────────────────

  Future<List<DoctorModel>> getDoctors(String userId) async {
    if (userId.isEmpty) throw CacheFailure();
    return await _doctorRepository.getDoctors(userId);
  }

  // ─────────────────────────────────────
  // DELETE DOCTOR
  // ─────────────────────────────────────

  Future<void> deleteDoctor(String userId, String doctorId) async {
    if (userId.isEmpty || doctorId.isEmpty) throw CacheFailure();
    await _doctorRepository.deleteDoctor(userId, doctorId);
  }

  // ─────────────────────────────────────
  // MARK APPOINTMENT DONE
  // ─────────────────────────────────────

  Future<void> markAppointmentDone(String userId, String doctorId) async {
    await _doctorRepository.markAppointmentDone(userId, doctorId);
  }

  // ─────────────────────────────────────
  // FILTER DOCTORS
  // ─────────────────────────────────────

  // Get upcoming appointments
  List<DoctorModel> getUpcomingAppointments(List<DoctorModel> doctors) {
    return doctors.where((d) => d.isUpcoming).toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  // Get past appointments
  List<DoctorModel> getPastAppointments(List<DoctorModel> doctors) {
    return doctors.where((d) => !d.isUpcoming).toList()
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
  }

  // Search doctors by name
  List<DoctorModel> searchDoctors(List<DoctorModel> doctors, String query) {
    if (query.isEmpty) return doctors;
    return doctors
        .where(
          (d) =>
              d.doctorName.toLowerCase().contains(query.toLowerCase()) ||
              d.speciality.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
