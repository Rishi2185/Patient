import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../models/appointment.dart';
import 'services.dart';

/// The signed-in patient's appointments, backed by the cloud API
/// (`/appointments`). Booking, cancelling and completing all round-trip to the
/// server; the local list mirrors the latest known state.
class AppointmentProvider extends ChangeNotifier {
  final Services _services;
  AppointmentProvider(this._services);

  final List<Appointment> _appointments = [];
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

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

  int get count => _appointments.length;

  /// Load the patient's appointments. Safe to call when signed out (the request
  /// would 401) — callers should only invoke it once authenticated.
  Future<void> load({bool force = false}) async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _services.appointments.list(limit: 100);
      _appointments
        ..clear()
        ..addAll(page.data);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Drop everything on sign-out.
  void clear() {
    _appointments.clear();
    _error = null;
    notifyListeners();
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

  /// Book an appointment. Returns the created record (server-authoritative).
  /// Throws [ApiException] on failure (e.g. 409 if the slot was just taken).
  Future<Appointment> book({
    required String doctorId,
    required DateTime dateTime,
    required String slotLabel,
    required int fee,
    required PaymentMethod paymentMethod,
    String? patientName,
    int? patientAge,
    String? patientBloodGroup,
    String? patientType,
    String? paymentStatus,
  }) async {
    final created = await _services.appointments.create(
      doctorId: doctorId,
      dateTime: dateTime,
      slotLabel: slotLabel,
      fee: fee,
      paymentMethod: paymentMethod.index,
      patientName: patientName,
      patientAge: patientAge,
      patientBloodGroup: patientBloodGroup,
      patientType: patientType,
      paymentStatus: paymentStatus,
    );
    _appointments.add(created);
    notifyListeners();
    return created;
  }

  Future<void> cancel(String id) =>
      _patch(id, {'status': AppointmentStatus.cancelled.index});

  Future<void> markCompleted(String id) =>
      _patch(id, {'status': AppointmentStatus.completed.index});

  /// Mark an appointment as reviewed. The review POST already flags it
  /// server-side (via `appointmentId`), so this updates the local copy only.
  Future<void> markReviewed(String id) async {
    final i = _appointments.indexWhere((a) => a.id == id);
    if (i >= 0) {
      _appointments[i].reviewed = true;
      notifyListeners();
    }
  }

  Future<void> _patch(String id, Map<String, dynamic> changes) async {
    final updated = await _services.appointments.patch(id, changes);
    final i = _appointments.indexWhere((a) => a.id == id);
    if (i >= 0) {
      _appointments[i] = updated;
    } else {
      _appointments.add(updated);
    }
    notifyListeners();
  }
}
