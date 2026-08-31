import 'package:flutter/material.dart';
import '../viewmodels/ai_viewmodel.dart';
import '../core/errors/failures.dart';
import '../models/medicine_model.dart';
import '../models/doctor_model.dart';
import '../models/health_record_model.dart';
import '../models/health_insurance_model.dart';
import 'medicine_provider.dart';
import 'doctor_provider.dart';
import 'health_record_provider.dart';
import 'health_insurance_provider.dart';
import 'auth_provider.dart';

// Chat message model
class ChatMessage {
  final String message;
  final bool isUser; // true = User, false = AI
  final DateTime time;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.time,
  });
}

class AIProvider extends ChangeNotifier {
  final AIViewModel _aiViewModel = AIViewModel();

  // ─────────────────────────────────────
  // STATES
  // ─────────────────────────────────────
  bool _isLoading = false;
  List<ChatMessage> _messages = [];
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  List<ChatMessage> get messages => _messages;
  String get errorMessage => _errorMessage;

  // ─────────────────────────────────────
  // SEND MESSAGE — RAG Enabled
  //
  // 1. Reads all provider data (medicines, doctors, records, insurance, user)
  // 2. Builds a structured text context string
  // 3. Passes context + user message to AIViewModel → Gemini API
  // ─────────────────────────────────────
  Future<void> sendMessage(
    String message, {
    required MedicineProvider medicineProvider,
    required DoctorProvider doctorProvider,
    required HealthRecordProvider healthRecordProvider,
    required HealthInsuranceProvider healthInsuranceProvider,
    required AuthProvider authProvider,
  }) async {
    try {
      // Add user message to chat UI immediately
      _messages.add(
        ChatMessage(message: message, isUser: true, time: DateTime.now()),
      );
      _setLoading(true);
      _clearError();

      // BUILD RAG CONTEXT — read all providers
      final context = _buildHealthContext(
        medicineProvider: medicineProvider,
        doctorProvider: doctorProvider,
        healthRecordProvider: healthRecordProvider,
        healthInsuranceProvider: healthInsuranceProvider,
        authProvider: authProvider,
      );

      // Send message + context to Gemini via AIViewModel
      final response = await _aiViewModel.sendMessage(
        message,
        context: context,
      );

      // Add AI response to chat UI
      _messages.add(
        ChatMessage(message: response, isUser: false, time: DateTime.now()),
      );
    } on ServerFailure catch (e) {
      final wasCancelled = e.message == AIViewModel.requestCancelledMessage;
      _errorMessage = wasCancelled ? '' : e.message;
      _messages.add(
        ChatMessage(
          message: wasCancelled
              ? 'Response stopped.'
              : _userFacingError(e.message),
          isUser: false,
          time: DateTime.now(),
        ),
      );
    } catch (e) {
      _errorMessage = 'Something went wrong!';
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // BUILD HEALTH CONTEXT (THE HEART OF RAG)
  //
  // Reads all providers and converts to structured
  // text that Gemini can understand and use.
  // ─────────────────────────────────────
  String _buildHealthContext({
    required MedicineProvider medicineProvider,
    required DoctorProvider doctorProvider,
    required HealthRecordProvider healthRecordProvider,
    required HealthInsuranceProvider healthInsuranceProvider,
    required AuthProvider authProvider,
  }) {
    final buffer = StringBuffer();

    // ── SECTION 1: PATIENT PROFILE ──
    final user = authProvider.currentUser;
    if (user != null) {
      buffer.writeln('## PATIENT PROFILE');
      buffer.writeln('Name: ${user.name}');
      buffer.writeln('Email: ${user.email}');
      if (user.age != null) buffer.writeln('Age: ${user.age} years');
      if (user.bloodGroup != null) {
        buffer.writeln('Blood Group: ${user.bloodGroup}');
      }
      if (user.phone != null) buffer.writeln('Phone: ${user.phone}');
      buffer.writeln('');
    }

    // ── SECTION 2: CURRENT MEDICINES ──
    final medicines = medicineProvider.medicines;
    buffer.writeln('## CURRENT MEDICINES (${medicines.length} total)');
    if (medicines.isNotEmpty) {
      for (final MedicineModel m in medicines) {
        final isActive =
            m.endDate == null || m.endDate!.isAfter(DateTime.now());
        buffer.writeln('- Medicine Name: ${m.name}');
        buffer.writeln('  Dosage: ${m.dosage}');
        buffer.writeln('  Type: ${m.type}');
        buffer.writeln('  Frequency: ${m.frequency}');
        if (m.reminderTimes.isNotEmpty) {
          buffer.writeln('  Reminder Times: ${m.reminderTimes.join(', ')}');
        }
        buffer.writeln('  Priority: ${m.priority}');
        buffer.writeln('  Status: ${isActive ? 'ACTIVE' : 'COMPLETED'}');
        buffer.writeln('  Start Date: ${_formatDate(m.startDate)}');
        if (m.endDate != null) {
          buffer.writeln('  End Date: ${_formatDate(m.endDate!)}');
        }
        if (m.notes != null && m.notes!.isNotEmpty) {
          buffer.writeln('  Notes: ${m.notes}');
        }
        buffer.writeln('');
      }
    } else {
      buffer.writeln('No medicines recorded in MediTrack.');
      buffer.writeln('');
    }

    // ── SECTION 3: DOCTOR APPOINTMENTS ──
    final upcomingDoctors = doctorProvider.upcomingDoctors;
    final pastDoctors = doctorProvider.pastDoctors;

    buffer.writeln('## DOCTOR APPOINTMENTS');

    if (upcomingDoctors.isNotEmpty) {
      buffer.writeln(
          '### UPCOMING APPOINTMENTS (${upcomingDoctors.length} total)');
      for (final DoctorModel d in upcomingDoctors) {
        buffer.writeln('- Doctor: Dr. ${d.doctorName}');
        buffer.writeln('  Speciality: ${d.speciality}');
        buffer.writeln('  Clinic: ${d.clinicName}');
        buffer.writeln(
            '  Appointment Date: ${_formatDateTime(d.appointmentDate)}');
        if (d.phone != null) buffer.writeln('  Contact: ${d.phone}');
        if (d.address != null) buffer.writeln('  Address: ${d.address}');
        if (d.notes != null && d.notes!.isNotEmpty) {
          buffer.writeln('  Notes: ${d.notes}');
        }
        buffer.writeln('');
      }
    } else {
      buffer.writeln('No upcoming doctor appointments.');
      buffer.writeln('');
    }

    if (pastDoctors.isNotEmpty) {
      // Only include last 5 past appointments to keep context lean
      final recentPast = pastDoctors.take(5).toList();
      buffer.writeln(
          '### RECENT PAST APPOINTMENTS (showing ${recentPast.length})');
      for (final DoctorModel d in recentPast) {
        buffer.writeln(
          '- Dr. ${d.doctorName} (${d.speciality}) — ${_formatDate(d.appointmentDate)}',
        );
      }
      buffer.writeln('');
    }

    // ── SECTION 4: HEALTH RECORDS ──
    final records = healthRecordProvider.records;
    buffer.writeln('## HEALTH RECORDS (${records.length} total)');
    if (records.isNotEmpty) {
      // Show latest 10 records
      final recentRecords = records.take(10).toList();
      for (final HealthRecordModel r in recentRecords) {
        buffer.writeln('- Title: ${r.title}');
        buffer.writeln('  Category: ${r.category}');
        buffer.writeln('  Date Uploaded: ${_formatDate(r.createdAt)}');
        buffer.writeln('  File Type: ${r.fileType}');
        if (r.notes != null && r.notes!.isNotEmpty) {
          buffer.writeln('  Notes: ${r.notes}');
        }
        buffer.writeln('');
      }
    } else {
      buffer.writeln('No health records uploaded.');
      buffer.writeln('');
    }

    // ── SECTION 5: HEALTH INSURANCE ──
    final policies = healthInsuranceProvider.policies;
    buffer.writeln('## HEALTH INSURANCE POLICIES (${policies.length} total)');
    if (policies.isNotEmpty) {
      for (final HealthInsuranceModel p in policies) {
        buffer.writeln('- Provider: ${p.providerName}');
        buffer.writeln('  Policy Number: ${p.policyNumber}');
        buffer.writeln('  Coverage Amount: ${p.coverageAmount}');
        buffer.writeln('  Valid From: ${_formatDate(p.startDate)}');
        buffer.writeln('  Valid Until: ${_formatDate(p.endDate)}');
        buffer.writeln(
            '  Status: ${p.isActive ? 'ACTIVE' : 'EXPIRED'}');
        buffer.writeln('  Agent Contact: ${p.agentContact}');
        if (p.coveredMembers.isNotEmpty) {
          buffer.writeln(
              '  Covered Members: ${p.coveredMembers.join(', ')}');
        }
        buffer.writeln('');
      }
    } else {
      buffer.writeln('No insurance policies recorded.');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  // ─────────────────────────────────────
  // DATE HELPERS
  // ─────────────────────────────────────
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${_formatDate(date)} at '
        '${hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')} $amPm';
  }

  // ─────────────────────────────────────
  // CLEAR CHAT
  // ─────────────────────────────────────
  void clearChat() {
    _messages = [];
    _aiViewModel.clearChat();
    notifyListeners();
  }

  void cancelRequest() {
    if (!_isLoading) return;
    _aiViewModel.cancelActiveRequest();
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }

  String _userFacingError(String error) {
    final normalized = error.toLowerCase();

    if (normalized.contains('api key') ||
        normalized.contains('permission') ||
        normalized.contains('denied') ||
        normalized.contains('forbidden') ||
        normalized.contains('403')) {
      return 'AI service access is currently blocked. Please check the Gemini API key and Google Cloud project access.';
    }

    if (normalized.contains('rate') || normalized.contains('quota')) {
      return 'AI service quota is currently limited. Please try again later.';
    }

    if (normalized.contains('network') || normalized.contains('timeout')) {
      return 'I could not reach the AI service. Please check your internet connection and try again.';
    }

    return 'Sorry, I am unable to process your request. Please try again!';
  }
}
