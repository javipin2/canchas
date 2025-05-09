// providers/sede_provider.dart
import 'package:flutter/material.dart';

class SedeProvider with ChangeNotifier {
  String _sede = 'Sede 1'; // Valor por defecto

  String get sede => _sede;

  void setSede(String nuevaSede) {
    _sede = nuevaSede;
    notifyListeners();
  }
}
