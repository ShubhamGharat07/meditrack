// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../../models/medicine_model.dart';
// import '../../models/doctor_model.dart';
// import '../../models/health_record_model.dart';
// import '../../models/family_member_model.dart';

// class SQLiteService {
//   static Database? _database;

//   // Get database instance
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   // Initialize database
//   Future<Database> _initDatabase() async {
//     final path = join(await getDatabasesPath(), 'meditrack.db');
//     return await openDatabase(path, version: 1, onCreate: _createTables);
//   }

//   // Create all tables
//   Future<void> _createTables(Database db, int version) async {
//     // Medicines table
//     await db.execute('''
//       CREATE TABLE medicines(
//         id TEXT PRIMARY KEY,
//         userId TEXT NOT NULL,
//         name TEXT NOT NULL,
//         dosage TEXT NOT NULL,
//         type TEXT NOT NULL,
//         frequency TEXT NOT NULL,
//         startDate TEXT NOT NULL,
//         endDate TEXT,
//         reminderTimes TEXT NOT NULL,
//         priority TEXT NOT NULL,
//         notes TEXT,
//         isSynced INTEGER DEFAULT 0,
//         createdAt TEXT NOT NULL
//       )
//     ''');

//     // Doctors table
//     await db.execute('''
//       CREATE TABLE doctors(
//         id TEXT PRIMARY KEY,
//         userId TEXT NOT NULL,
//         doctorName TEXT NOT NULL,
//         speciality TEXT NOT NULL,
//         clinicName TEXT NOT NULL,
//         phone TEXT,
//         address TEXT,
//         appointmentDate TEXT NOT NULL,
//         notes TEXT,
//         isUpcoming INTEGER DEFAULT 1,
//         isSynced INTEGER DEFAULT 0,
//         createdAt TEXT NOT NULL
//       )
//     ''');

//     // Health Records table
//     await db.execute('''
//       CREATE TABLE health_records(
//         id TEXT PRIMARY KEY,
//         userId TEXT NOT NULL,
//         title TEXT NOT NULL,
//         category TEXT NOT NULL,
//         fileUrl TEXT NOT NULL,
//         fileType TEXT NOT NULL,
//         notes TEXT,
//         isSynced INTEGER DEFAULT 0,
//         createdAt TEXT NOT NULL
//       )
//     ''');

//     // Family Members table
//     await db.execute('''
//       CREATE TABLE family_members(
//         id TEXT PRIMARY KEY,
//         userId TEXT NOT NULL,
//         name TEXT NOT NULL,
//         relation TEXT NOT NULL,
//         age INTEGER,
//         bloodGroup TEXT,
//         photoUrl TEXT,
//         allergies TEXT,
//         isSynced INTEGER DEFAULT 0,
//         createdAt TEXT NOT NULL
//       )
//     ''');
//   }

//   // ─────────────────────────────────────
//   // MEDICINES
//   // ─────────────────────────────────────

//   // Save medicine locally
//   Future<void> saveMedicine(MedicineModel medicine) async {
//     final db = await database;
//     final map = medicine.toMap();
//     // Convert list to string for SQLite
//     map['reminderTimes'] = medicine.reminderTimes.join(',');
//     map['isSynced'] = medicine.isSynced ? 1 : 0;
//     await db.insert(
//       'medicines',
//       map,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // Get all medicines by userId
//   Future<List<MedicineModel>> getMedicines(String userId) async {
//     final db = await database;
//     final maps = await db.query(
//       'medicines',
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );
//     return maps.map((map) {
//       final updatedMap = Map<String, dynamic>.from(map);
//       // Convert string back to list
//       updatedMap['reminderTimes'] = (map['reminderTimes'] as String).split(',');
//       updatedMap['isSynced'] = map['isSynced'] == 1;
//       return MedicineModel.fromMap(updatedMap);
//     }).toList();
//   }

//   // Delete medicine
//   Future<void> deleteMedicine(String id) async {
//     final db = await database;
//     await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
//   }

//   // Get unsynced medicines
//   Future<List<MedicineModel>> getUnsyncedMedicines() async {
//     final db = await database;
//     final maps = await db.query(
//       'medicines',
//       where: 'isSynced = ?',
//       whereArgs: [0],
//     );
//     return maps.map((map) {
//       final updatedMap = Map<String, dynamic>.from(map);
//       updatedMap['reminderTimes'] = (map['reminderTimes'] as String).split(',');
//       updatedMap['isSynced'] = map['isSynced'] == 1;
//       return MedicineModel.fromMap(updatedMap);
//     }).toList();
//   }

//   // Mark medicine as synced
//   Future<void> markMedicineSynced(String id) async {
//     final db = await database;
//     await db.update(
//       'medicines',
//       {'isSynced': 1},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   // ─────────────────────────────────────
//   // DOCTORS
//   // ─────────────────────────────────────

//   // Save doctor locally
//   Future<void> saveDoctor(DoctorModel doctor) async {
//     final db = await database;
//     final map = doctor.toMap();
//     map['isSynced'] = doctor.isSynced ? 1 : 0;
//     map['isUpcoming'] = doctor.isUpcoming ? 1 : 0;
//     await db.insert(
//       'doctors',
//       map,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // Get all doctors by userId
//   Future<List<DoctorModel>> getDoctors(String userId) async {
//     final db = await database;
//     final maps = await db.query(
//       'doctors',
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );
//     return maps.map((map) {
//       final updatedMap = Map<String, dynamic>.from(map);
//       updatedMap['isSynced'] = map['isSynced'] == 1;
//       updatedMap['isUpcoming'] = map['isUpcoming'] == 1;
//       return DoctorModel.fromMap(updatedMap);
//     }).toList();
//   }

//   // Delete doctor
//   Future<void> deleteDoctor(String id) async {
//     final db = await database;
//     await db.delete('doctors', where: 'id = ?', whereArgs: [id]);
//   }

//   // ─────────────────────────────────────
//   // HEALTH RECORDS
//   // ─────────────────────────────────────

//   // Save health record locally
//   Future<void> saveHealthRecord(HealthRecordModel record) async {
//     final db = await database;
//     final map = record.toMap();
//     map['isSynced'] = record.isSynced ? 1 : 0;
//     await db.insert(
//       'health_records',
//       map,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // Get all health records by userId
//   Future<List<HealthRecordModel>> getHealthRecords(String userId) async {
//     final db = await database;
//     final maps = await db.query(
//       'health_records',
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );
//     return maps.map((map) {
//       final updatedMap = Map<String, dynamic>.from(map);
//       updatedMap['isSynced'] = map['isSynced'] == 1;
//       return HealthRecordModel.fromMap(updatedMap);
//     }).toList();
//   }

//   // Delete health record
//   Future<void> deleteHealthRecord(String id) async {
//     final db = await database;
//     await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
//   }

//   // ─────────────────────────────────────
//   // FAMILY MEMBERS
//   // ─────────────────────────────────────

//   // Save family member locally
//   Future<void> saveFamilyMember(FamilyMemberModel member) async {
//     final db = await database;
//     final map = member.toMap();
//     map['isSynced'] = member.isSynced ? 1 : 0;
//     map['allergies'] = member.allergies?.join(',');
//     await db.insert(
//       'family_members',
//       map,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // Get all family members by userId
//   Future<List<FamilyMemberModel>> getFamilyMembers(String userId) async {
//     final db = await database;
//     final maps = await db.query(
//       'family_members',
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );
//     return maps.map((map) {
//       final updatedMap = Map<String, dynamic>.from(map);
//       updatedMap['isSynced'] = map['isSynced'] == 1;
//       updatedMap['allergies'] = map['allergies'] != null
//           ? (map['allergies'] as String).split(',')
//           : null;
//       return FamilyMemberModel.fromMap(updatedMap);
//     }).toList();
//   }

//   // Delete family member
//   Future<void> deleteFamilyMember(String id) async {
//     final db = await database;
//     await db.delete('family_members', where: 'id = ?', whereArgs: [id]);
//   }

//   // ─────────────────────────────────────
//   // CLEAR ALL — Logout
//   // ─────────────────────────────────────

//   Future<void> clearAll() async {
//     final db = await database;
//     await db.delete('medicines');
//     await db.delete('doctors');
//     await db.delete('health_records');
//     await db.delete('family_members');
//   }
// }

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../../models/medicine_model.dart';
// import '../../models/doctor_model.dart';
// import '../../models/health_record_model.dart';
// import '../../models/family_member_model.dart';

// class SQLiteService {
//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final path = join(await getDatabasesPath(), 'meditrack.db');
//     return await openDatabase(
//       path,
//       version:
//           2, // v1 → v2: memberId added in medicines/doctors, family_members extended
//       onCreate: _createTables,
//       onUpgrade: _onUpgrade,
//     );
//   }

//   // ─────────────────────────────────────
//   // MIGRATION: v1 → v2
//   // ─────────────────────────────────────

//   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     if (oldVersion < 2) {
//       // medicines — memberId column add
//       await db.execute('ALTER TABLE medicines ADD COLUMN memberId TEXT');

//       // doctors — memberId column add
//       await db.execute('ALTER TABLE doctors ADD COLUMN memberId TEXT');

//       // family_members — purani table drop, nayi banao (SQLite mein ALTER TABLE limited hai)
//       await db.execute('DROP TABLE IF EXISTS family_members');
//       await db.execute('''
//         CREATE TABLE family_members(
//           id TEXT PRIMARY KEY,
//           userId TEXT NOT NULL,
//           name TEXT NOT NULL,
//           relation TEXT NOT NULL,
//           age INTEGER,
//           gender TEXT,
//           dob TEXT,
//           bloodGroup TEXT,
//           photoUrl TEXT,
//           allergies TEXT,
//           medicalConditions TEXT,
//           emergencyContactName TEXT,
//           emergencyContact TEXT,
//           insuranceProvider TEXT,
//           insurancePolicyNumber TEXT,
//           insuranceExpiry TEXT,
//           insuranceDocUrl TEXT,
//           isSynced INTEGER DEFAULT 0,
//           createdAt TEXT NOT NULL
//         )
//       ''');
//     }
//   }

//   // ─────────────────────────────────────
//   // CREATE TABLES (fresh install)
//   // ─────────────────────────────────────

//   Future<void> _createTables(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE medicines(
//         id TEXT PRIMARY KEY,
//         userId TEXT NOT NULL,
//         memberId TEXT,
//         name TEXT NOT NULL,
//         dosage TEXT NOT NULL,
//         type TEXT NOT NULL,
//         frequency TEXT NOT NULL,
//         startDate TEXT NOT NULL,
//         endDate TEXT,
//         reminderTimes TEXT NOT NULL,
//         priority TEXT NOT NULL,
//         notes TEXT,
//         isSynced INTEGER DEFAULT 0,
//         createdAt TEXT NOT NULL
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE doctors(
//         id TEXT PRIMARY KEY,
//         userId TEXT NOT NULL,
//         memberId TEXT,
//         doctorName TEXT NOT NULL,
//         speciality TEXT NOT NULL,
//         clinicName TEXT NOT NULL,
//         phone TEXT,
//         address TEXT,
//         appointmentDate TEXT NOT NULL,
//         notes TEXT,
//         isUpcoming INTEGER DEFAULT 1,
//         isSynced INTEGER DEFAULT 0,
//         createdAt TEXT NOT NULL
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE health_records(
//         id TEXT PRIMARY KEY,
//         userId TEXT NOT NULL,
//         memberId TEXT,
//         title TEXT NOT NULL,
//         category TEXT NOT NULL,
//         fileUrl TEXT NOT NULL,
//         fileType TEXT NOT NULL,
//         notes TEXT,
//         isSynced INTEGER DEFAULT 0,
//         createdAt TEXT NOT NULL
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE family_members(
//         id TEXT PRIMARY KEY,
//         userId TEXT NOT NULL,
//         name TEXT NOT NULL,
//         relation TEXT NOT NULL,
//         age INTEGER,
//         gender TEXT,
//         dob TEXT,
//         bloodGroup TEXT,
//         photoUrl TEXT,
//         allergies TEXT,
//         medicalConditions TEXT,
//         emergencyContactName TEXT,
//         emergencyContact TEXT,
//         insuranceProvider TEXT,
//         insurancePolicyNumber TEXT,
//         insuranceExpiry TEXT,
//         insuranceDocUrl TEXT,
//         isSynced INTEGER DEFAULT 0,
//         createdAt TEXT NOT NULL
//       )
//     ''');
//   }

//   // ─────────────────────────────────────
//   // MEDICINES
//   // ─────────────────────────────────────

//   Future<void> saveMedicine(MedicineModel medicine) async {
//     final db = await database;
//     final map = medicine.toMap();
//     map['reminderTimes'] = medicine.reminderTimes.join(',');
//     map['isSynced'] = medicine.isSynced ? 1 : 0;
//     await db.insert(
//       'medicines',
//       map,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // userId ke saare medicines (main user + family sab)
//   Future<List<MedicineModel>> getMedicines(String userId) async {
//     final db = await database;
//     final maps = await db.query(
//       'medicines',
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );
//     return maps.map((map) => _parseMedicine(map)).toList();
//   }

//   // Specific member ke medicines
//   Future<List<MedicineModel>> getMedicinesByMember(
//     String userId,
//     String? memberId,
//   ) async {
//     final db = await database;
//     final maps = memberId == null
//         ? await db.query(
//             'medicines',
//             where: 'userId = ? AND memberId IS NULL',
//             whereArgs: [userId],
//           )
//         : await db.query(
//             'medicines',
//             where: 'userId = ? AND memberId = ?',
//             whereArgs: [userId, memberId],
//           );
//     return maps.map((map) => _parseMedicine(map)).toList();
//   }

//   MedicineModel _parseMedicine(Map<String, dynamic> map) {
//     final updatedMap = Map<String, dynamic>.from(map);
//     final raw = map['reminderTimes'] as String? ?? '';
//     updatedMap['reminderTimes'] = raw.isNotEmpty ? raw.split(',') : <String>[];
//     updatedMap['isSynced'] = map['isSynced'] == 1;
//     return MedicineModel.fromMap(updatedMap);
//   }

//   Future<void> deleteMedicine(String id) async {
//     final db = await database;
//     await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<List<MedicineModel>> getUnsyncedMedicines() async {
//     final db = await database;
//     final maps = await db.query(
//       'medicines',
//       where: 'isSynced = ?',
//       whereArgs: [0],
//     );
//     return maps.map((map) => _parseMedicine(map)).toList();
//   }

//   Future<void> markMedicineSynced(String id) async {
//     final db = await database;
//     await db.update(
//       'medicines',
//       {'isSynced': 1},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   // ─────────────────────────────────────
//   // DOCTORS
//   // ─────────────────────────────────────

//   Future<void> saveDoctor(DoctorModel doctor) async {
//     final db = await database;
//     final map = doctor.toMap();
//     map['isSynced'] = doctor.isSynced ? 1 : 0;
//     map['isUpcoming'] = doctor.isUpcoming ? 1 : 0;
//     await db.insert(
//       'doctors',
//       map,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<DoctorModel>> getDoctors(String userId) async {
//     final db = await database;
//     final maps = await db.query(
//       'doctors',
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );
//     return maps.map((map) => _parseDoctor(map)).toList();
//   }

//   // Specific member ke doctors
//   Future<List<DoctorModel>> getDoctorsByMember(
//     String userId,
//     String? memberId,
//   ) async {
//     final db = await database;
//     final maps = memberId == null
//         ? await db.query(
//             'doctors',
//             where: 'userId = ? AND memberId IS NULL',
//             whereArgs: [userId],
//           )
//         : await db.query(
//             'doctors',
//             where: 'userId = ? AND memberId = ?',
//             whereArgs: [userId, memberId],
//           );
//     return maps.map((map) => _parseDoctor(map)).toList();
//   }

//   DoctorModel _parseDoctor(Map<String, dynamic> map) {
//     final updatedMap = Map<String, dynamic>.from(map);
//     updatedMap['isSynced'] = map['isSynced'] == 1;
//     updatedMap['isUpcoming'] = map['isUpcoming'] == 1;
//     return DoctorModel.fromMap(updatedMap);
//   }

//   Future<void> deleteDoctor(String id) async {
//     final db = await database;
//     await db.delete('doctors', where: 'id = ?', whereArgs: [id]);
//   }

//   // ─────────────────────────────────────
//   // HEALTH RECORDS
//   // ─────────────────────────────────────

//   Future<void> saveHealthRecord(HealthRecordModel record) async {
//     final db = await database;
//     final map = record.toMap();
//     map['isSynced'] = record.isSynced ? 1 : 0;
//     await db.insert(
//       'health_records',
//       map,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<HealthRecordModel>> getHealthRecords(String userId) async {
//     final db = await database;
//     final maps = await db.query(
//       'health_records',
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );
//     return maps.map((map) {
//       final updatedMap = Map<String, dynamic>.from(map);
//       updatedMap['isSynced'] = map['isSynced'] == 1;
//       return HealthRecordModel.fromMap(updatedMap);
//     }).toList();
//   }

//   // Specific member ke health records
//   Future<List<HealthRecordModel>> getHealthRecordsByMember(
//     String userId,
//     String? memberId,
//   ) async {
//     final db = await database;
//     final maps = memberId == null
//         ? await db.query(
//             'health_records',
//             where: 'userId = ? AND memberId IS NULL',
//             whereArgs: [userId],
//           )
//         : await db.query(
//             'health_records',
//             where: 'userId = ? AND memberId = ?',
//             whereArgs: [userId, memberId],
//           );
//     return maps.map((map) {
//       final updatedMap = Map<String, dynamic>.from(map);
//       updatedMap['isSynced'] = map['isSynced'] == 1;
//       return HealthRecordModel.fromMap(updatedMap);
//     }).toList();
//   }

//   Future<void> deleteHealthRecord(String id) async {
//     final db = await database;
//     await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
//   }

//   // ─────────────────────────────────────
//   // FAMILY MEMBERS
//   // ─────────────────────────────────────

//   Future<void> saveFamilyMember(FamilyMemberModel member) async {
//     final db = await database;
//     final map = member.toMap();
//     map['isSynced'] = member.isSynced ? 1 : 0;
//     // Lists → comma string
//     map['allergies'] = member.allergies?.join(',');
//     map['medicalConditions'] = member.medicalConditions?.join(',');
//     await db.insert(
//       'family_members',
//       map,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<FamilyMemberModel>> getFamilyMembers(String userId) async {
//     final db = await database;
//     final maps = await db.query(
//       'family_members',
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );
//     return maps.map((map) => _parseFamilyMember(map)).toList();
//   }

//   FamilyMemberModel _parseFamilyMember(Map<String, dynamic> map) {
//     final updatedMap = Map<String, dynamic>.from(map);
//     updatedMap['isSynced'] = map['isSynced'] == 1;
//     updatedMap['allergies'] = map['allergies'] != null
//         ? (map['allergies'] as String)
//               .split(',')
//               .where((e) => e.isNotEmpty)
//               .toList()
//         : null;
//     updatedMap['medicalConditions'] = map['medicalConditions'] != null
//         ? (map['medicalConditions'] as String)
//               .split(',')
//               .where((e) => e.isNotEmpty)
//               .toList()
//         : null;
//     return FamilyMemberModel.fromMap(updatedMap);
//   }

//   Future<void> deleteFamilyMember(String id) async {
//     final db = await database;
//     await db.delete('family_members', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<void> updateFamilyMember(FamilyMemberModel member) async {
//     final db = await database;
//     final map = member.toMap();
//     map['isSynced'] = member.isSynced ? 1 : 0;
//     map['allergies'] = member.allergies?.join(',');
//     map['medicalConditions'] = member.medicalConditions?.join(',');
//     await db.update(
//       'family_members',
//       map,
//       where: 'id = ?',
//       whereArgs: [member.id],
//     );
//   }

//   // ─────────────────────────────────────
//   // CLEAR ALL — Logout
//   // ─────────────────────────────────────

//   Future<void> clearAll() async {
//     final db = await database;
//     await db.delete('medicines');
//     await db.delete('doctors');
//     await db.delete('health_records');
//     await db.delete('family_members');
//   }
// }

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/medicine_model.dart';
import '../../models/doctor_model.dart';
import '../../models/health_record_model.dart';
import '../../models/family_member_model.dart';
import '../../models/health_insurance_model.dart';

class SQLiteService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'meditrack.db');
    return await openDatabase(
      path,
      version: 3, // v1→v2: memberId added, v2→v3: health_insurance table
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  // ─────────────────────────────────────
  // MIGRATIONS
  // ─────────────────────────────────────

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE medicines ADD COLUMN memberId TEXT');
      await db.execute('ALTER TABLE doctors ADD COLUMN memberId TEXT');
      await db.execute('DROP TABLE IF EXISTS family_members');
      await db.execute('''
        CREATE TABLE family_members(
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          name TEXT NOT NULL,
          relation TEXT NOT NULL,
          age INTEGER,
          gender TEXT,
          dob TEXT,
          bloodGroup TEXT,
          photoUrl TEXT,
          allergies TEXT,
          medicalConditions TEXT,
          emergencyContactName TEXT,
          emergencyContact TEXT,
          insuranceProvider TEXT,
          insurancePolicyNumber TEXT,
          insuranceExpiry TEXT,
          insuranceDocUrl TEXT,
          isSynced INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE health_insurance(
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          providerName TEXT NOT NULL,
          policyNumber TEXT NOT NULL,
          startDate TEXT NOT NULL,
          endDate TEXT NOT NULL,
          coverageAmount TEXT NOT NULL,
          agentContact TEXT NOT NULL,
          coveredMembers TEXT,
          docUrl TEXT,
          docType TEXT,
          isSynced INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL
        )
      ''');
    }
  }

  // ─────────────────────────────────────
  // CREATE TABLES (fresh install)
  // ─────────────────────────────────────

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        memberId TEXT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        type TEXT NOT NULL,
        frequency TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT,
        reminderTimes TEXT NOT NULL,
        priority TEXT NOT NULL,
        notes TEXT,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE doctors(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        memberId TEXT,
        doctorName TEXT NOT NULL,
        speciality TEXT NOT NULL,
        clinicName TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        appointmentDate TEXT NOT NULL,
        notes TEXT,
        isUpcoming INTEGER DEFAULT 1,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE health_records(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        memberId TEXT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        fileUrl TEXT NOT NULL,
        fileType TEXT NOT NULL,
        notes TEXT,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE family_members(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        relation TEXT NOT NULL,
        age INTEGER,
        gender TEXT,
        dob TEXT,
        bloodGroup TEXT,
        photoUrl TEXT,
        allergies TEXT,
        medicalConditions TEXT,
        emergencyContactName TEXT,
        emergencyContact TEXT,
        insuranceProvider TEXT,
        insurancePolicyNumber TEXT,
        insuranceExpiry TEXT,
        insuranceDocUrl TEXT,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE health_insurance(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        providerName TEXT NOT NULL,
        policyNumber TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        coverageAmount TEXT NOT NULL,
        agentContact TEXT NOT NULL,
        coveredMembers TEXT,
        docUrl TEXT,
        docType TEXT,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // ─────────────────────────────────────
  // MEDICINES
  // ─────────────────────────────────────

  Future<void> saveMedicine(MedicineModel medicine) async {
    final db = await database;
    final map = medicine.toMap();
    map['reminderTimes'] = medicine.reminderTimes.join(',');
    map['isSynced'] = medicine.isSynced ? 1 : 0;
    await db.insert(
      'medicines',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MedicineModel>> getMedicines(String userId) async {
    final db = await database;
    final maps = await db.query(
      'medicines',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => _parseMedicine(map)).toList();
  }

  Future<List<MedicineModel>> getMedicinesByMember(
    String userId,
    String? memberId,
  ) async {
    final db = await database;
    final maps = memberId == null
        ? await db.query(
            'medicines',
            where: 'userId = ? AND memberId IS NULL',
            whereArgs: [userId],
          )
        : await db.query(
            'medicines',
            where: 'userId = ? AND memberId = ?',
            whereArgs: [userId, memberId],
          );
    return maps.map((map) => _parseMedicine(map)).toList();
  }

  MedicineModel _parseMedicine(Map<String, dynamic> map) {
    final updatedMap = Map<String, dynamic>.from(map);
    final raw = map['reminderTimes'] as String? ?? '';
    updatedMap['reminderTimes'] = raw.isNotEmpty ? raw.split(',') : <String>[];
    updatedMap['isSynced'] = map['isSynced'] == 1;
    return MedicineModel.fromMap(updatedMap);
  }

  Future<void> deleteMedicine(String id) async {
    final db = await database;
    await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MedicineModel>> getUnsyncedMedicines() async {
    final db = await database;
    final maps = await db.query(
      'medicines',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => _parseMedicine(map)).toList();
  }

  Future<void> markMedicineSynced(String id) async {
    final db = await database;
    await db.update(
      'medicines',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────────────────
  // DOCTORS
  // ─────────────────────────────────────

  Future<void> saveDoctor(DoctorModel doctor) async {
    final db = await database;
    final map = doctor.toMap();
    map['isSynced'] = doctor.isSynced ? 1 : 0;
    map['isUpcoming'] = doctor.isUpcoming ? 1 : 0;
    await db.insert(
      'doctors',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DoctorModel>> getDoctors(String userId) async {
    final db = await database;
    final maps = await db.query(
      'doctors',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => _parseDoctor(map)).toList();
  }

  Future<List<DoctorModel>> getDoctorsByMember(
    String userId,
    String? memberId,
  ) async {
    final db = await database;
    final maps = memberId == null
        ? await db.query(
            'doctors',
            where: 'userId = ? AND memberId IS NULL',
            whereArgs: [userId],
          )
        : await db.query(
            'doctors',
            where: 'userId = ? AND memberId = ?',
            whereArgs: [userId, memberId],
          );
    return maps.map((map) => _parseDoctor(map)).toList();
  }

  DoctorModel _parseDoctor(Map<String, dynamic> map) {
    final updatedMap = Map<String, dynamic>.from(map);
    updatedMap['isSynced'] = map['isSynced'] == 1;
    updatedMap['isUpcoming'] = map['isUpcoming'] == 1;
    return DoctorModel.fromMap(updatedMap);
  }

  Future<void> deleteDoctor(String id) async {
    final db = await database;
    await db.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────
  // HEALTH RECORDS
  // ─────────────────────────────────────

  Future<void> saveHealthRecord(HealthRecordModel record) async {
    final db = await database;
    final map = record.toMap();
    map['isSynced'] = record.isSynced ? 1 : 0;
    await db.insert(
      'health_records',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HealthRecordModel>> getHealthRecords(String userId) async {
    final db = await database;
    final maps = await db.query(
      'health_records',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) {
      final updatedMap = Map<String, dynamic>.from(map);
      updatedMap['isSynced'] = map['isSynced'] == 1;
      return HealthRecordModel.fromMap(updatedMap);
    }).toList();
  }

  Future<List<HealthRecordModel>> getHealthRecordsByMember(
    String userId,
    String? memberId,
  ) async {
    final db = await database;
    final maps = memberId == null
        ? await db.query(
            'health_records',
            where: 'userId = ? AND memberId IS NULL',
            whereArgs: [userId],
          )
        : await db.query(
            'health_records',
            where: 'userId = ? AND memberId = ?',
            whereArgs: [userId, memberId],
          );
    return maps.map((map) {
      final updatedMap = Map<String, dynamic>.from(map);
      updatedMap['isSynced'] = map['isSynced'] == 1;
      return HealthRecordModel.fromMap(updatedMap);
    }).toList();
  }

  Future<void> deleteHealthRecord(String id) async {
    final db = await database;
    await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────
  // FAMILY MEMBERS
  // ─────────────────────────────────────

  Future<void> saveFamilyMember(FamilyMemberModel member) async {
    final db = await database;
    final map = member.toMap();
    map['isSynced'] = member.isSynced ? 1 : 0;
    map['allergies'] = member.allergies?.join(',');
    map['medicalConditions'] = member.medicalConditions?.join(',');
    await db.insert(
      'family_members',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FamilyMemberModel>> getFamilyMembers(String userId) async {
    final db = await database;
    final maps = await db.query(
      'family_members',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => _parseFamilyMember(map)).toList();
  }

  FamilyMemberModel _parseFamilyMember(Map<String, dynamic> map) {
    final updatedMap = Map<String, dynamic>.from(map);
    updatedMap['isSynced'] = map['isSynced'] == 1;
    updatedMap['allergies'] = map['allergies'] != null
        ? (map['allergies'] as String)
              .split(',')
              .where((e) => e.isNotEmpty)
              .toList()
        : null;
    updatedMap['medicalConditions'] = map['medicalConditions'] != null
        ? (map['medicalConditions'] as String)
              .split(',')
              .where((e) => e.isNotEmpty)
              .toList()
        : null;
    return FamilyMemberModel.fromMap(updatedMap);
  }

  Future<void> deleteFamilyMember(String id) async {
    final db = await database;
    await db.delete('family_members', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateFamilyMember(FamilyMemberModel member) async {
    final db = await database;
    final map = member.toMap();
    map['isSynced'] = member.isSynced ? 1 : 0;
    map['allergies'] = member.allergies?.join(',');
    map['medicalConditions'] = member.medicalConditions?.join(',');
    await db.update(
      'family_members',
      map,
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  // ─────────────────────────────────────
  // HEALTH INSURANCE
  // ─────────────────────────────────────

  Future<void> saveHealthInsurance(HealthInsuranceModel policy) async {
    final db = await database;
    final map = policy.toMap();
    map['coveredMembers'] = policy.coveredMembers.join(',');
    map['isSynced'] = policy.isSynced ? 1 : 0;
    await db.insert(
      'health_insurance',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HealthInsuranceModel>> getHealthInsurances(String userId) async {
    final db = await database;
    final maps = await db.query(
      'health_insurance',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => _parseHealthInsurance(map)).toList();
  }

  HealthInsuranceModel _parseHealthInsurance(Map<String, dynamic> map) {
    final updatedMap = Map<String, dynamic>.from(map);
    updatedMap['isSynced'] = map['isSynced'] == 1;
    updatedMap['coveredMembers'] = map['coveredMembers'] != null
        ? (map['coveredMembers'] as String)
              .split(',')
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];
    return HealthInsuranceModel.fromMap(updatedMap);
  }

  Future<void> deleteHealthInsurance(String id) async {
    final db = await database;
    await db.delete('health_insurance', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markHealthInsuranceSynced(String id) async {
    final db = await database;
    await db.update(
      'health_insurance',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────────────────
  // CLEAR ALL — Logout
  // ─────────────────────────────────────

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('medicines');
    await db.delete('doctors');
    await db.delete('health_records');
    await db.delete('family_members');
    await db.delete('health_insurance');
  }
}
