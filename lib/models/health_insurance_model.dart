class HealthInsuranceModel {
  final String id;
  final String userId;
  final String providerName;
  final String policyNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String coverageAmount;
  final String agentContact;
  final List<String> coveredMembers;
  final String? docUrl;
  final String? docType; // 'pdf' or 'image'
  final bool isSynced;
  final DateTime createdAt;

  const HealthInsuranceModel({
    required this.id,
    required this.userId,
    required this.providerName,
    required this.policyNumber,
    required this.startDate,
    required this.endDate,
    required this.coverageAmount,
    required this.agentContact,
    required this.coveredMembers,
    this.docUrl,
    this.docType,
    this.isSynced = false,
    required this.createdAt,
  });

  bool get isActive => endDate.isAfter(DateTime.now());

  factory HealthInsuranceModel.fromMap(Map<String, dynamic> map) {
    List<String> parseMembers(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return List<String>.from(raw);
      return (raw as String).split(',').where((e) => e.isNotEmpty).toList();
    }

    return HealthInsuranceModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      providerName: map['providerName'] as String? ?? '',
      policyNumber: map['policyNumber'] as String? ?? '',
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      coverageAmount: map['coverageAmount'] as String? ?? '',
      agentContact: map['agentContact'] as String? ?? '',
      coveredMembers: parseMembers(map['coveredMembers']),
      docUrl: map['docUrl'] as String?,
      docType: map['docType'] as String?,
      isSynced: map['isSynced'] == true || map['isSynced'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'providerName': providerName,
      'policyNumber': policyNumber,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'coverageAmount': coverageAmount,
      'agentContact': agentContact,
      'coveredMembers': coveredMembers,
      'docUrl': docUrl,
      'docType': docType,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  HealthInsuranceModel copyWith({
    String? id,
    String? userId,
    String? providerName,
    String? policyNumber,
    DateTime? startDate,
    DateTime? endDate,
    String? coverageAmount,
    String? agentContact,
    List<String>? coveredMembers,
    String? docUrl,
    String? docType,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return HealthInsuranceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerName: providerName ?? this.providerName,
      policyNumber: policyNumber ?? this.policyNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coverageAmount: coverageAmount ?? this.coverageAmount,
      agentContact: agentContact ?? this.agentContact,
      coveredMembers: coveredMembers ?? this.coveredMembers,
      docUrl: docUrl ?? this.docUrl,
      docType: docType ?? this.docType,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
