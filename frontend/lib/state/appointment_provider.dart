import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/appointment.dart';

/// Stores the patient's appointments. Persisted locally as JSON.
class AppointmentProvider extends ChangeNotifier {
  static const _kAppointments = 'appointments';

  final List<Appointment> _appointments = [];
  SharedPreferences? _prefs;

  List<Appointment> get all {
    final list = [..._appointments];
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<Appointment> byStatus(AppointmentStatus status) =>
      all.where((a) => a.status == status).toList();

  List<Appointment> get upcoming => byStatus(AppointmentStatus.upcoming)
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  List<Appointment> get completed => byStatus(AppointmentStatus.completed);
  List<Appointment> get cancelled => byStatus(AppointmentStatus.cancelled);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_kAppointments);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _appointments
        ..clear()
        ..addAll(
          list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)),
        );
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final encoded =
        jsonEncode(_appointments.map((a) => a.toJson()).toList());
    await _prefs?.setString(_kAppointments, encoded);
  }

  bool isSlotBooked(String doctorId, DateTime date, String slotLabel) {
    return _appointments.any((a) =>
        a.doctorId == doctorId &&
        a.status == AppointmentStatus.upcoming &&
        a.dateTime.year == date.year &&
        a.dateTime.month == date.month &&
        a.dateTime.day == date.day &&
        a.slotLabel == slotLabel);
  }

  Future<void> book(Appointment appointment) async {
    _appointments.add(appointment);
    await _persist();
    notifyListeners();
  }

  Future<void> cancel(String id) async {
    final a = _appointments.firstWhere((e) => e.id == id);
    a.status = AppointmentStatus.cancelled;
    await _persist();
    notifyListeners();
  }

  Future<void> markCompleted(String id) async {
    final a = _appointments.firstWhere((e) => e.id == id);
    a.status = AppointmentStatus.completed;
    await _persist();
    notifyListeners();
  }

  Future<void> markReviewed(String id) async {
    final a = _appointments.firstWhere((e) => e.id == id);
    a.reviewed = true;
    await _persist();
    notifyListeners();
  }

  int get count => _appointments.length;
}
