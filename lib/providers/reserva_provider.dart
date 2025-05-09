import 'package:flutter/material.dart';
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
    if (_reservaActual != null) {
      _reservaActual!.confirmada = true;
      notifyListeners();

      // Aquí puedes enviar la reserva al backend vía HTTP POST
      // Una vez confirmada, limpiar la reserva actual:
      _reservaActual = null;
      notifyListeners();
    }
  }

  void cancelarReserva() {
    _reservaActual = null;
    notifyListeners();
  }
}
