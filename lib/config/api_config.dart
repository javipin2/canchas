import 'package:flutter/foundation.dart';

class ApiConfig {
  // URL de producción: reemplaza con la URL que te asignó Railway.
  static const String productionUrl = "https://tu-aplicacion.up.railway.app";

  // URL para desarrollo: para emulador Android se utiliza 10.0.2.2
  static const String developmentUrl = "http://10.0.2.2:5000";

  // Devuelve la URL base según el entorno (release vs. debug)
  static String get baseUrl => kReleaseMode ? productionUrl : developmentUrl;

  // Construye la URL completa para un endpoint específico.
  static String getApiUrl(String endpoint) {
    return "$baseUrl/$endpoint";
  }
}
