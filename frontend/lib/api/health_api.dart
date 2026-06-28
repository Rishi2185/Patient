import 'api_client.dart';

/// Liveness check against the backend (`GET /health`). Never throws — a network
/// error simply means "offline". Handy for a connectivity banner or debugging.
class HealthApi {
  final ApiClient _client;
  HealthApi(this._client);

  Future<bool> ping() async {
    try {
      final data = await _client.get('/health');
      if (data is Map) {
        final status = data['status'];
        return status == 'ok' || status == true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
