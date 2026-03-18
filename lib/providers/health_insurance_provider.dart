import 'dart:io';
import 'package:flutter/material.dart';
import '../models/health_insurance_model.dart';
import '../viewmodels/health_insurance_viewmodel.dart';
import '../core/errors/failures.dart';

class HealthInsuranceProvider extends ChangeNotifier {
  final HealthInsuranceViewModel _viewModel = HealthInsuranceViewModel();

  bool _isLoading = false;
  bool _isUploading = false;
  List<HealthInsuranceModel> _policies = [];
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  List<HealthInsuranceModel> get policies => _policies;
  String get errorMessage => _errorMessage;

  // ─────────────────────────────────────
  // GET POLICIES
  // ─────────────────────────────────────

  Future<void> getPolicies(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      _policies = await _viewModel.getPolicies(userId);
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // ADD POLICY
  // ─────────────────────────────────────

  Future<bool> addPolicy({
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
      if (docFile != null) {
        _isUploading = true;
        notifyListeners();
      } else {
        _setLoading(true);
      }
      _clearError();

      await _viewModel.addPolicy(
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

      await getPolicies(userId);
      return true;
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _isUploading = false;
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // UPDATE POLICY
  // ─────────────────────────────────────

  Future<bool> updatePolicy({
    required HealthInsuranceModel policy,
    File? newDocFile,
    String? newDocType,
  }) async {
    try {
      if (newDocFile != null) {
        _isUploading = true;
        notifyListeners();
      } else {
        _setLoading(true);
      }
      _clearError();

      await _viewModel.updatePolicy(
        policy: policy,
        newDocFile: newDocFile,
        newDocType: newDocType,
      );

      await getPolicies(policy.userId);
      return true;
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _isUploading = false;
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // DELETE POLICY
  // ─────────────────────────────────────

  Future<bool> deletePolicy(
    String userId,
    String policyId, {
    String? docType,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      await _viewModel.deletePolicy(userId, policyId, docType: docType);
      _policies.removeWhere((p) => p.id == policyId);
      notifyListeners();
      return true;
    } on CacheFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() => _errorMessage = '';
}
