import '../api/api_client.dart';
import '../api/appointment_api.dart';
import '../api/auth_api.dart';
import '../api/doctor_api.dart';
import '../api/health_api.dart';
import '../api/hospital_api.dart';
import '../api/review_api.dart';
import 'settings_store.dart';

/// Composition root: builds the [ApiClient] from persisted settings and wires up
/// every resource API. Providers receive this object and call the APIs through
/// it. The single shared [api] carries the bearer token for all requests.
class Services {
  final SettingsStore settings;
  final ApiClient api;

  final AuthApi auth;
  final DoctorApi doctors;
  final HospitalApi hospitals;
  final AppointmentApi appointments;
  final ReviewApi reviews;
  final HealthApi health;

  Services._({
    required this.settings,
    required this.api,
    required this.auth,
    required this.doctors,
    required this.hospitals,
    required this.appointments,
    required this.reviews,
    required this.health,
  });

  factory Services.wire({required SettingsStore settings}) {
    final api = ApiClient(baseUrl: settings.baseUrl)..token = settings.token;
    return Services._(
      settings: settings,
      api: api,
      auth: AuthApi(api),
      doctors: DoctorApi(api),
      hospitals: HospitalApi(api),
      appointments: AppointmentApi(api),
      reviews: ReviewApi(api),
      health: HealthApi(api),
    );
  }
}
