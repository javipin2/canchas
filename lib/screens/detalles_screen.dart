import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cancha.dart';
import '../models/horario.dart';
import '../models/reserva.dart';
import 'reserva_screen.dart';

class DetallesScreen extends StatefulWidget {
  // Cambiado a StatefulWidget
  final Cancha cancha;
  final DateTime fecha;
  final Horario horario;
  final String sede;

  const DetallesScreen({
    Key? key,
    required this.cancha,
    required this.fecha,
    required this.horario,
    required this.sede,
  }) : super(key: key);

  @override
  State<DetallesScreen> createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen> {
  @override
  Widget build(BuildContext context) {
    // Se asume que cancha.precio es el precio completo asignado por el admin
    final double precioCompleto = widget.cancha.precio;
    const double abono = 20000; // Valor fijo para abono

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Reserva'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.cancha.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(widget.fecha)}\nHora: ${widget.horario.horaFormateada}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Precio completo: \$${NumberFormat.currency(symbol: "\$", decimalDigits: 0).format(precioCompleto)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Abono: \$${NumberFormat.currency(symbol: "\$", decimalDigits: 0).format(abono)}',
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                _hacerReserva(TipoAbono.parcial, abono);
              },
              child: Text(
                'Abonar y Reservar - \$${NumberFormat.currency(symbol: "\$", decimalDigits: 0).format(abono)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                _hacerReserva(TipoAbono.completo, precioCompleto);
              },
              child: Text(
                'Pagar Completo - \$${NumberFormat.currency(symbol: "\$", decimalDigits: 0).format(precioCompleto)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nuevo método para manejar la creación de reservas
  Future<void> _hacerReserva(TipoAbono tipoAbono, double montoPagado) async {
    Reserva reserva = Reserva(
      cancha: widget.cancha,
      fecha: widget.fecha,
      horario: widget.horario,
      sede: widget.sede,
      tipoAbono: tipoAbono,
      montoTotal: widget.cancha.precio,
      montoPagado: montoPagado,
    );

    // Navegamos a la pantalla de reserva y esperamos el resultado
    final bool? reservaExitosa = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ReservaScreen(reserva: reserva),
      ),
    );

    // Si la reserva fue exitosa, retornamos a HorariosScreen con resultado positivo
    if (reservaExitosa == true) {
      Navigator.of(context)
          .pop(true); // Indicar a HorariosScreen que hubo una reserva
    }
  }
}
