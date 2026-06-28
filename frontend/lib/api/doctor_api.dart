import '../models/doctor.dart';
import 'api_client.dart';

/// Doctor discovery endpoints (read-only for the patient app).
class DoctorApi {
  final ApiClient _client;
  DoctorApi(this._client);

  /// GET /doctors -> paginated `{ data, page, limit, total }`.
  Future<Paged<Doctor>> list({
    String? q,
    String? specialtyId,
    bool? availableToday,
    double? minRating,
    String? sort,
    int page = 1,
    int limit = 100,
  }) {
    return _client.getPaged<Doctor>('/doctors', Doctor.fromJson, query: {
      'q': q,
      'specialtyId': specialtyId,
      'availableToday': availableToday,
      'minRating': minRating,
      'sort': sort,
      'page': page,
      'limit': limit,
    });
  }

  /// GET /doctors/top?limit= -> `{ data: [...] }` (home "Top doctors" rail).
  Future<List<Doctor>> top({int limit = 6}) =>
      _client.getList<Doctor>('/doctors/top', Doctor.fromJson,
          query: {'limit': limit});

  /// GET /doctors/:id -> single doctor.
  Future<Doctor> getById(String id) async =>
      Doctor.fromJson(await _client.get('/doctors/$id') as Map<String, dynamic>);
}
