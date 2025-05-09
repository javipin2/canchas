// screens/reserva_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/reserva.dart';
import '../config/api_config.dart'; // Importamos el archivo de configuración de la API

class ReservaScreen extends StatefulWidget {
  final Reserva reserva;

  const ReservaScreen({Key? key, required this.reserva}) : super(key: key);

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  bool _procesando = false;

  Future<void> _confirmarReserva() async {
    if (!mounted) return; // Evita llamar setState en un widget desmontado

    if (_formKey.currentState!.validate()) {
      setState(() {
        _procesando = true;
      });

      // Actualizar datos de la reserva con lo ingresado en los campos
      widget.reserva.nombre = _nombreController.text;
      widget.reserva.telefono = _telefonoController.text;
      widget.reserva.email = _emailController.text;

      // Usamos ApiConfig para construir la URL correcta según el entorno
      final url = Uri.parse(ApiConfig.getApiUrl("crear_reserva"));

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(widget.reserva.toJson()),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.statusCode == 200
                ? "¡Reserva confirmada con éxito!"
                : "Error: ${response.body}"),
          ),
        );

        if (response.statusCode == 200) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error inesperado: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _procesando = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Reserva'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Resumen de la reserva
            Text(
              'Reserva para ${widget.reserva.cancha.nombre}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('dd/MM/yyyy').format(widget.reserva.fecha)} - ${widget.reserva.horario.horaFormateada}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre Completo',
                    keyboardType: TextInputType.text,
                    validatorMsg: 'Por favor ingresa tu nombre',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _telefonoController,
                    label: 'Teléfono',
                    keyboardType: TextInputType.phone,
                    validatorMsg: 'Por favor ingresa tu teléfono',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Correo Electrónico',
                    keyboardType: TextInputType.emailAddress,
                    validatorMsg: 'Por favor ingresa tu correo',
                    extraValidation: (value) {
                      if (value != null &&
                          (value.isEmpty ||
                              !value.contains('@') ||
                              !value.contains('.'))) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _procesando
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _confirmarReserva,
                          child: const Text('Confirmar Reserva'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required String validatorMsg,
    String? Function(String?)? extraValidation,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        if (extraValidation != null) {
          return extraValidation(value);
        }
        return null;
      },
    );
  }
}
