import 'dart:io';
import '../models/health_insurance_model.dart';
import '../repositories/health_insurance_repository.dart';

class HealthInsuranceViewModel {
  final HealthInsuranceRepository _repository = HealthInsuranceRepository();

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
    await _repository.addPolicy(
      userId: userId,
      providerName: providerName,
      policyNumber: policyNumber,
      startDate: startDate,
      endDate: endDate,
      coverageAmount: coverageAmount,
      agentContact: agentContact,
      coveredMembers: coveredMembers,
      docFile: docFile,
      docType: docType,
    );
  }

  Future<List<HealthInsuranceModel>> getPolicies(String userId) async {
    return await _repository.getPolicies(userId);
  }

  Future<void> updatePolicy({
    required HealthInsuranceModel policy,
    File? newDocFile,
    String? newDocType,
  }) async {
    await _repository.updatePolicy(
      policy: policy,
      newDocFile: newDocFile,
      newDocType: newDocType,
    );
  }

  Future<void> deletePolicy(
    String userId,
    String policyId, {
    String? docType,
  }) async {
    await _repository.deletePolicy(userId, policyId, docType: docType);
  }
}
