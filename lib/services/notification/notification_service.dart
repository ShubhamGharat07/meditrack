import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../../models/medicine_model.dart';
import '../../models/doctor_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (d) =>
          debugPrint('Notification tapped: ${d.payload}'),
    );

    if (Platform.isAndroid) {
      final ap = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await ap?.requestNotificationsPermission();
      final canExact = await ap?.canScheduleExactNotifications();
      if (canExact == false) await ap?.requestExactAlarmsPermission();
    }
    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  // ── NOTIFICATION DETAILS ──

  NotificationDetails get _medicineDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      'meditrack_reminders',
      'Medicine Reminders',
      channelDescription: 'Daily medicine reminders',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // Same channel as medicine — confirmed working on device.
  // Android caches channel settings on first creation; a new channel ID
  // may silently get low importance if the app was installed before.
  NotificationDetails get _appointmentDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      'meditrack_reminders',
      'MediTrack Reminders',
      channelDescription: 'Medicine and appointment reminders',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // ── INSTANT ──

  Future<void> showTestNotification() async {
    await _notifications.show(
      id: 99999,
      title: '✅ Notification Test',
      body: 'MediTrack notifications are working!',
      notificationDetails: _medicineDetails,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _medicineDetails,
    );
  }

  // ── MEDICINE REMINDERS ──

  Future<void> scheduleMedicineReminder(MedicineModel medicine) async {
    if (medicine.id == null || medicine.id!.isEmpty) return;
    if (medicine.reminderTimes.isEmpty) return;

    final ap = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canExact = await ap?.canScheduleExactNotifications();
    final mode = canExact == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (int i = 0; i < medicine.reminderTimes.length; i++) {
      final t = _parseTime(medicine.reminderTimes[i]);
      if (t == null) continue;
      final id = _medicineId(medicine.id!, i);
      try {
        await _notifications.cancel(id: id);
        await _notifications.zonedSchedule(
          id: id,
          title: '💊 Medicine Reminder',
          body: 'Time to take ${medicine.name} — ${medicine.dosage}',
          scheduledDate: t,
          notificationDetails: _medicineDetails,
          androidScheduleMode: mode,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e) {
        debugPrint('Medicine schedule failed: $e');
      }
    }
  }

  Future<void> cancelMedicineReminders(MedicineModel medicine) async {
    if (medicine.id == null) return;
    for (int i = 0; i < medicine.reminderTimes.length; i++) {
      await _notifications.cancel(id: _medicineId(medicine.id!, i));
    }
  }

  // ── APPOINTMENT REMINDERS — 4 notifications per appointment ──
  // Fires: 1 day | 6 hours | 1 hour | 30 minutes before

  Future<void> scheduleAppointmentReminder(DoctorModel doctor) async {
    if (doctor.id == null || doctor.id!.isEmpty) return;

    final ap = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canExact = await ap?.canScheduleExactNotifications();
    final mode = canExact == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final apptTZ = tz.TZDateTime.from(doctor.appointmentDate, tz.local);
    final timeStr = _formatTime(doctor.appointmentDate);

    final configs = [
      (
        offset: const Duration(days: 1),
        title: '🗓️ Appointment Tomorrow',
        body:
            'Dr. ${doctor.doctorName} (${doctor.speciality}) at $timeStr — ${doctor.clinicName}',
        slot: 0,
      ),
      (
        offset: const Duration(hours: 6),
        title: '🏥 Appointment in 6 Hours',
        body: 'Dr. ${doctor.doctorName} at $timeStr — ${doctor.clinicName}',
        slot: 1,
      ),
      (
        offset: const Duration(hours: 1),
        title: '⏰ Appointment in 1 Hour',
        body: 'Get ready! Dr. ${doctor.doctorName} at $timeStr',
        slot: 2,
      ),
      (
        offset: const Duration(minutes: 30),
        title: '🚨 Appointment in 30 Minutes',
        body: 'Leaving soon? Dr. ${doctor.doctorName} at $timeStr',
        slot: 3,
      ),
    ];

    final now = tz.TZDateTime.now(tz.local);
    int count = 0;

    for (final c in configs) {
      final fireAt = apptTZ.subtract(c.offset);
      if (fireAt.isBefore(now)) continue;

      final id = _doctorId(doctor.id!, c.slot);
      try {
        await _notifications.cancel(id: id);
        await _notifications.zonedSchedule(
          id: id,
          title: c.title,
          body: c.body,
          scheduledDate: fireAt,
          notificationDetails: _appointmentDetails,
          androidScheduleMode: mode,
          payload: 'appointment:${doctor.id}',
        );
        count++;
        debugPrint('Appt reminder [slot ${c.slot}] → $fireAt');
      } catch (e) {
        debugPrint('Appt reminder [slot ${c.slot}] failed: $e');
      }
    }

    debugPrint('Dr. ${doctor.doctorName}: $count/4 reminders set');
  }

  Future<void> cancelAppointmentReminder(DoctorModel doctor) async {
    if (doctor.id == null) return;
    for (int i = 0; i < 4; i++) {
      await _notifications.cancel(id: _doctorId(doctor.id!, i));
    }
  }

  // ── UTILITIES ──

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // ── CUSTOM ONE-SHOT REMINDER (for appointments) ──
  // User picks exact date + time — fires once at that moment.

  Future<void> scheduleCustomReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    if (scheduledDateTime.isBefore(DateTime.now())) {
      debugPrint('Custom reminder in past — skipping');
      return;
    }

    final ap = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canExact = await ap?.canScheduleExactNotifications();
    final mode = canExact == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final scheduledTZ = tz.TZDateTime.from(scheduledDateTime, tz.local);

    try {
      await _notifications.cancel(id: id);
      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTZ,
        notificationDetails: _appointmentDetails,
        androidScheduleMode: mode,
        payload: 'custom_reminder',
        // NO matchDateTimeComponents → fires ONCE, not repeating
      );
      debugPrint('Custom reminder set → $scheduledTZ (ID: $id)');
    } catch (e) {
      debugPrint('Custom reminder failed: $e');
    }
  }

  Future<void> cancelNotification(int id) async =>
      await _notifications.cancel(id: id);

  Future<void> cancelAllNotifications() async =>
      await _notifications.cancelAll();

  Future<void> logPendingNotifications() async {
    final p = await _notifications.pendingNotificationRequests();
    debugPrint('=== Pending: ${p.length} ===');
    for (final n in p) debugPrint('  ${n.id}: ${n.title}');
  }

  // ── ID GENERATORS ──
  // Medicine: 0–499999999 range
  int _medicineId(String id, int idx) =>
      ((id.hashCode.abs() * 10) + idx) % 499999999;

  // Doctor: 500000000–999999999 range, 4 slots per doctor
  int _doctorId(String id, int slot) =>
      (id.hashCode.abs() % 124999999) * 4 + 500000000 + slot;

  // ── TIME FORMATTER ──
  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final disp = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$disp:$m $suffix';
  }

  // ── TIME PARSER ──
  tz.TZDateTime? _parseTime(String time) {
    try {
      final t = time.trim();
      int h = 0, m = 0;
      final u = t.toUpperCase();
      if (u.contains('AM') || u.contains('PM')) {
        final isPM = u.contains('PM');
        final clean = u.replaceAll('AM', '').replaceAll('PM', '').trim();
        final p = clean.split(':');
        h = int.parse(p[0].trim());
        m = int.parse(p[1].trim());
        if (isPM && h != 12) h += 12;
        if (!isPM && h == 12) h = 0;
      } else if (t.contains(':')) {
        final p = t.split(':');
        h = int.parse(p[0].trim());
        m = int.parse(p[1].trim());
      } else {
        return null;
      }
      final now = tz.TZDateTime.now(tz.local);
      var s = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
      if (s.isBefore(now)) s = s.add(const Duration(days: 1));
      return s;
    } catch (e) {
      return null;
    }
  }
}
