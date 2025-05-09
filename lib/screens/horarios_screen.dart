// lib/screens/horarios_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/cancha.dart';
import '../models/horario.dart';
import '../providers/sede_provider.dart';
import 'detalles_screen.dart';
import '../main.dart'; // para usar el routeObserver

class HorariosScreen extends StatefulWidget {
  final Cancha cancha;

  const HorariosScreen({Key? key, required this.cancha}) : super(key: key);

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> with RouteAware {
  DateTime _selectedDate = DateTime.now();
  List<Horario> horarios = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHorarios();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadHorarios();
  }

  Future<void> _loadHorarios() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final sedeProvider = Provider.of<SedeProvider>(context, listen: false);
      final nuevosHorarios = await Horario.generarHorarios(
        fecha: _selectedDate,
        canchaId: widget.cancha.id,
        sede: sedeProvider.sede,
      );

      if (!mounted) return;

      setState(() {
        horarios = nuevosHorarios;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar horarios: $e')),
      );
    }

    // Se elimina el `return` dentro de `finally`
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogTheme(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });

      // Se usa `Future.delayed(Duration.zero, _loadHorarios)` para garantizar que se actualice correctamente
      Future.delayed(Duration.zero, _loadHorarios);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sedeProvider = Provider.of<SedeProvider>(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (mounted) Navigator.pop(context);
            },
          ),
          title: Text(widget.cancha.nombre),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Cambiar Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Horarios Disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2,
                        ),
                        itemCount: horarios.length,
                        itemBuilder: (context, index) {
                          final horario = horarios[index];
                          return ElevatedButton(
                            onPressed: horario.disponible
                                ? () {
                                    if (mounted) {
                                      Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetallesScreen(
                                            cancha: widget.cancha,
                                            fecha: _selectedDate,
                                            horario: horario,
                                            sede: sedeProvider.sede,
                                          ),
                                        ),
                                      ).then((reservaRealizada) {
                                        if (reservaRealizada == true) {
                                          _loadHorarios();
                                        }
                                      });
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: horario.disponible
                                  ? Colors.green
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(horario.horaFormateada),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
