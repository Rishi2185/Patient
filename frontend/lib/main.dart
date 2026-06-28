import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'state/appointment_provider.dart';
import 'state/auth_provider.dart';
import 'state/doctor_provider.dart';
import 'state/hospital_provider.dart';
import 'state/review_provider.dart';
import 'state/services.dart';
import 'state/settings_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Load persisted settings, wire the API client + services, then restore any
  // saved session before the first frame.
  final settings = await SettingsStore.load();
  final services = Services.wire(settings: settings);

  final auth = AuthProvider(services);
  await auth.init();

  runApp(AarvyApp(services: services, auth: auth));
}

class AarvyApp extends StatelessWidget {
  final Services services;
  final AuthProvider auth;

  const AarvyApp({
    super.key,
    required this.services,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Services>.value(value: services),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider(create: (_) => AppointmentProvider(services)),
        ChangeNotifierProvider(create: (_) => DoctorProvider(services)),
        ChangeNotifierProvider(create: (_) => HospitalProvider(services)),
        ChangeNotifierProvider(create: (_) => ReviewProvider(services)),
      ],
      child: MaterialApp(
        title: 'Aarvy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
