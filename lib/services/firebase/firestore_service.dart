import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/medicine_model.dart';
import '../../models/doctor_model.dart';
import '../../models/health_record_model.dart';
import '../../models/family_member_model.dart';
import '../../models/support_ticket_model.dart';
import '../../models/health_insurance_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─────────────────────────────────────
  // USERS
  // ─────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // ─────────────────────────────────────
  // MEDICINES
  // ─────────────────────────────────────

  Future<void> saveMedicine(MedicineModel medicine) async {
    await _firestore
        .collection('users')
        .doc(medicine.userId)
        .collection('medicines')
        .doc(medicine.id)
        .set(medicine.toMap());
  }

  Future<List<MedicineModel>> getMedicines(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .get();
    return snapshot.docs
        .map((doc) => MedicineModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<MedicineModel>> getMedicinesByMember(
    String userId,
    String? memberId,
  ) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('medicines');
    query = memberId == null
        ? query.where('memberId', isNull: true)
        : query.where('memberId', isEqualTo: memberId);
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => MedicineModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteMedicine(String userId, String medicineId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .doc(medicineId)
        .delete();
  }

  // ─────────────────────────────────────
  // DOCTORS
  // ─────────────────────────────────────

  Future<void> saveDoctor(DoctorModel doctor) async {
    await _firestore
        .collection('users')
        .doc(doctor.userId)
        .collection('doctors')
        .doc(doctor.id)
        .set(doctor.toMap());
  }

  Future<List<DoctorModel>> getDoctors(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('doctors')
        .get();
    return snapshot.docs.map((doc) => DoctorModel.fromMap(doc.data())).toList();
  }

  Future<List<DoctorModel>> getDoctorsByMember(
    String userId,
    String? memberId,
  ) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('doctors');
    query = memberId == null
        ? query.where('memberId', isNull: true)
        : query.where('memberId', isEqualTo: memberId);
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => DoctorModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteDoctor(String userId, String doctorId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('doctors')
        .doc(doctorId)
        .delete();
  }

  Future<void> updateDoctorUpcoming(
    String userId,
    String doctorId,
    bool isUpcoming,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('doctors')
        .doc(doctorId)
        .update({'isUpcoming': isUpcoming});
  }

  // ─────────────────────────────────────
  // HEALTH RECORDS
  // ─────────────────────────────────────

  Future<void> saveHealthRecord(HealthRecordModel record) async {
    await _firestore
        .collection('users')
        .doc(record.userId)
        .collection('health_records')
        .doc(record.id)
        .set(record.toMap());
  }

  Future<List<HealthRecordModel>> getHealthRecords(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_records')
        .get();
    return snapshot.docs
        .map((doc) => HealthRecordModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<HealthRecordModel>> getHealthRecordsByMember(
    String userId,
    String? memberId,
  ) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('health_records');
    query = memberId == null
        ? query.where('memberId', isNull: true)
        : query.where('memberId', isEqualTo: memberId);
    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) =>
              HealthRecordModel.fromMap(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> deleteHealthRecord(String userId, String recordId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_records')
        .doc(recordId)
        .delete();
  }

  // ─────────────────────────────────────
  // FAMILY MEMBERS
  // ─────────────────────────────────────

  Future<void> saveFamilyMember(FamilyMemberModel member) async {
    await _firestore
        .collection('users')
        .doc(member.userId)
        .collection('family_members')
        .doc(member.id)
        .set(member.toMap());
  }

  Future<void> updateFamilyMember(
    String userId,
    String memberId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('family_members')
        .doc(memberId)
        .update(data);
  }

  Future<List<FamilyMemberModel>> getFamilyMembers(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('family_members')
        .get();
    return snapshot.docs
        .map((doc) => FamilyMemberModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> deleteFamilyMember(String userId, String memberId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('family_members')
        .doc(memberId)
        .delete();
  }

  // ─────────────────────────────────────
  // HEALTH INSURANCE
  // ─────────────────────────────────────

  Future<void> saveHealthInsurance(HealthInsuranceModel policy) async {
    await _firestore
        .collection('users')
        .doc(policy.userId)
        .collection('health_insurance')
        .doc(policy.id)
        .set(policy.toMap());
  }

  Future<List<HealthInsuranceModel>> getHealthInsurances(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_insurance')
        .get();
    return snapshot.docs
        .map((doc) => HealthInsuranceModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> deleteHealthInsurance(String userId, String policyId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_insurance')
        .doc(policyId)
        .delete();
  }

  // ─────────────────────────────────────
  // SUPPORT TICKETS
  // ─────────────────────────────────────

  Future<void> saveSupportTicket(SupportTicketModel ticket) async {
    await _firestore
        .collection('support_tickets')
        .doc(ticket.id)
        .set(ticket.toMap());
  }

  Future<List<SupportTicketModel>> getSupportTickets(String userId) async {
    final snapshot = await _firestore
        .collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => SupportTicketModel.fromMap(doc.data()))
        .toList();
  }
}
