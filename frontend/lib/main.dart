import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'state/appointment_provider.dart';
import 'state/auth_provider.dart';
import 'state/doctor_provider.dart';
import 'state/review_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final auth = AuthProvider();
  final appointments = AppointmentProvider();
  await Future.wait([auth.init(), appointments.init()]);

  runApp(AarvyApp(auth: auth, appointments: appointments));
}

class AarvyApp extends StatelessWidget {
  final AuthProvider auth;
  final AppointmentProvider appointments;

  const AarvyApp({
    super.key,
    required this.auth,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: appointments),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
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
