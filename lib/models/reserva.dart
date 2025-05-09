// lib/models/reserva.dart
import 'package:intl/intl.dart';
import 'cancha.dart';
import 'horario.dart';

enum TipoAbono { parcial, completo }

class Reserva {
  Cancha cancha;
  DateTime fecha;
  Horario horario;
  String sede;
  TipoAbono tipoAbono;
  double montoTotal;
  double montoPagado;
  // Datos del cliente:
  String? nombre;
  String? telefono;
  String? email;
  bool confirmada; // nueva propiedad

  Reserva({
    required this.cancha,
    required this.fecha,
    required this.horario,
    required this.sede,
    required this.tipoAbono,
    required this.montoTotal,
    required this.montoPagado,
    this.nombre,
    this.telefono,
    this.email,
    this.confirmada = false, // por defecto en false
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'correo': email,
      'fecha': DateFormat('yyyy-MM-dd').format(fecha),
      'cancha': cancha.id,
      'horario': horario.horaFormateada,
      // Si es pago completo, setear "completo"; caso contrario, "Pendiente"
      'estado': tipoAbono == TipoAbono.completo ? 'completo' : 'Pendiente',
      'valor': montoTotal,
      'tipo_evento': 'Fútbol', // o ajustar según convenga
      'sede': sede,
    };
  }
}
