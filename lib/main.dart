import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/places_provider.dart';
import 'screens/places_list_screen.dart';
import 'widgets/min_size_box.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PlacesProvider()..loadPlaces(),
      child: const PlacesApp(),
    ),
  );
}

class PlacesApp extends StatelessWidget {
  const PlacesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moje miesta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      locale: const Locale('sk'),
      supportedLocales: const [Locale('sk')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MinSizeBox(child: child!),
      home: const PlacesListScreen(),
    );
  }
}
