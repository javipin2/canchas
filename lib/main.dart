// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/sede_provider.dart';
import 'providers/reserva_provider.dart';
import 'providers/cancha_provider.dart';
import 'screens/sede_screen.dart';

// Declara un RouteObserver global
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReservaProvider()),
        ChangeNotifierProvider(create: (context) => SedeProvider()),
        ChangeNotifierProvider(create: (context) => CanchaProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva de Canchas',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData(primaryColor: Colors.green),
      home: const SedeScreen(),
    );
  }
}
