import '../models/doctor.dart';
import '../models/hospital.dart';
import 'api_client.dart';

/// Hospital directory endpoints (read-only for the patient app).
class HospitalApi {
  final ApiClient _client;
  HospitalApi(this._client);

  /// GET /hospitals -> `{ data: [...] }`.
  Future<List<Hospital>> list() =>
      _client.getList<Hospital>('/hospitals', Hospital.fromJson);

  /// GET /hospitals/:id -> single hospital.
  Future<Hospital> getById(String id) async => Hospital.fromJson(
      await _client.get('/hospitals/$id') as Map<String, dynamic>);

  /// GET /hospitals/:id/doctors -> `{ data: [...] }` (doctors at this hospital).
  Future<List<Doctor>> doctors(String id) =>
      _client.getList<Doctor>('/hospitals/$id/doctors', Doctor.fromJson);
}
