// lib/models/horario.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Horario {
  final TimeOfDay hora;
  final bool disponible;

  Horario({
    required this.hora,
    this.disponible = true,
  });

  // Modificado para producir el mismo formato que el backend: "8:00 AM"
  String get horaFormateada {
    final int hour12 = (hora.hourOfPeriod == 0 ? 12 : hora.hourOfPeriod);
    final String minuteStr = hora.minute.toString().padLeft(2, '0');
    final String period = hora.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:$minuteStr $period';
  }

  static Future<void> marcarHorarioOcupado({
    required DateTime fecha,
    required int canchaId,
    required String sede,
    required String horaFormateada,
  }) async {
    final url = Uri.parse('http://localhost:5000/marcar_horario_ocupado');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fecha': fecha.toIso8601String().split('T')[0],
        'cancha_id': canchaId,
        'sede': sede,
        'hora': horaFormateada,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al marcar horario como ocupado: ${response.body}');
    }
  }

  static Future<List<Horario>> generarHorarios({
    required DateTime fecha,
    required int canchaId,
    required String sede,
  }) async {
    final List<Horario> horarios = [];
    const List<int> horasDisponibles = [
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24
    ];

    // Constrúyase la URL para conocer los horarios ocupados.
    final url = Uri.parse(
        'http://localhost:5000/horarios_ocupados?fecha=${fecha.toIso8601String().split('T')[0]}&cancha=$canchaId&sede=$sede');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener horarios ocupados: ${response.body}');
    }

    final data = jsonDecode(response.body);
    // Se espera que el backend retorne algo como:
    // { "horarios_ocupados": ["08:00 am", "10:00 am"] }
    final List<String> horariosOcupados =
        List<String>.from(data['horarios_ocupados']);

    final now = DateTime.now();
    bool esHoy = fecha.year == now.year &&
        fecha.month == now.month &&
        fecha.day == now.day;

    for (var hora in horasDisponibles) {
      final timeOfDay = TimeOfDay(hour: hora, minute: 0);
      // Usamos temporalmente el getter actualizado para obtener el formato
      final horarioTemp = Horario(hora: timeOfDay);
      final String horaStr = horarioTemp.horaFormateada;

      // Verifica si el horario está ocupado según el backend.
      bool ocupado = horariosOcupados.contains(horaStr);

      // Si la fecha es hoy, marcar como ocupado los horarios que ya han pasado.
      if (esHoy && hora <= now.hour) {
        ocupado = true;
      }

      horarios.add(Horario(
        hora: timeOfDay,
        disponible: !ocupado,
      ));
    }

    return horarios;
  }
}
