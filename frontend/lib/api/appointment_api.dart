import '../models/appointment.dart';
import 'api_client.dart';

/// The patient's appointments (all endpoints require a bearer token).
class AppointmentApi {
  final ApiClient _client;
  AppointmentApi(this._client);

  /// GET /appointments?status= -> paginated list of the caller's appointments.
  Future<Paged<Appointment>> list({int? status, int page = 1, int limit = 100}) {
    return _client.getPaged<Appointment>(
      '/appointments',
      Appointment.fromJson,
      query: {'status': status, 'page': page, 'limit': limit},
    );
  }

  /// GET /appointments/:id -> single appointment owned by the caller.
  Future<Appointment> getById(String id) async => Appointment.fromJson(
      await _client.get('/appointments/$id') as Map<String, dynamic>);

  /// POST /appointments -> books a slot for the signed-in patient. The server
  /// derives doctor/patient details; a 409 means the slot was just taken.
  Future<Appointment> create({
    required String doctorId,
    required DateTime dateTime,
    required String slotLabel,
    required int fee,
    required int paymentMethod,
    String? patientName,
    int? patientAge,
    String? patientBloodGroup,
    String? patientType,
    String? paymentStatus,
  }) async {
    final data = await _client.post('/appointments', body: {
      'doctorId': doctorId,
      'dateTime': dateTime.toIso8601String(),
      'slotLabel': slotLabel,
      'fee': fee,
      'paymentMethod': paymentMethod,
      'patientName':? patientName,
      'patientAge':? patientAge,
      'patientBloodGroup':? patientBloodGroup,
      'patientType':? patientType,
      'paymentStatus':? paymentStatus,
    }) as Map<String, dynamic>;
    return Appointment.fromJson(data);
  }

  /// PATCH /appointments/:id -> update status (cancel/complete) and/or reviewed.
  Future<Appointment> patch(String id, Map<String, dynamic> changes) async =>
      Appointment.fromJson(
          await _client.patch('/appointments/$id', body: changes)
              as Map<String, dynamic>);
}
