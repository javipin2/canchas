// providers/reserva_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/reserva.dart';

class ReservaProvider with ChangeNotifier {
  Reserva? _reservaActual;

  Reserva? get reservaActual => _reservaActual;

  void iniciarReserva(Reserva reserva) {
    _reservaActual = reserva;
    notifyListeners();
  }

  void actualizarDatosCliente({
    required String nombre,
    required String telefono,
    required String email,
  }) {
    if (_reservaActual != null) {
      _reservaActual!.nombre = nombre;
      _reservaActual!.telefono = telefono;
      _reservaActual!.email = email;
      notifyListeners();
    }
  }

  void registrarPago(double monto) {
    if (_reservaActual != null) {
      _reservaActual!.montoPagado = monto;
      _reservaActual!.confirmada = true;
      notifyListeners();
    }
  }

  Future<void> confirmarReserva() async {
    if (_reservaActual == null) return;

    try {
      // Usamos el endpoint configurado para crear reservas
      final url = Uri.parse(ApiConfig.getApiUrl("crear_reserva"));

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_reservaActual!.toJson()),
      );

      if (response.statusCode == 200) {
        // Reserva enviada correctamente.
        print("Reserva enviada: ${response.body}");
        _reservaActual = null; // Limpiamos la reserva actual
        notifyListeners();
      } else {
        throw Exception('Error al enviar la reserva: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception("Error al enviar la reserva: $error");
    }
  }

  void cancelarReserva() {
    _reservaActual = null;
    notifyListeners();
  }
}
