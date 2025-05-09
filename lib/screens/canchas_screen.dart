// screens/canchas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sede_provider.dart';
import '../providers/cancha_provider.dart';
import '../widgets/cancha_card.dart';
import 'horarios_screen.dart';

class CanchasScreen extends StatefulWidget {
  const CanchasScreen({super.key});

  @override
  State<CanchasScreen> createState() => _CanchasScreenState();
}

class _CanchasScreenState extends State<CanchasScreen> {
  @override
  void initState() {
    super.initState();
    final sede = Provider.of<SedeProvider>(context, listen: false).sede;
    Provider.of<CanchaProvider>(context, listen: false).fetchCanchas(sede);
  }

  @override
  Widget build(BuildContext context) {
    final canchaProvider = Provider.of<CanchaProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(106, 85, 218, 96),
            Color.fromARGB(255, 255, 255, 255),
          ],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                'assets/img1.png',
                height: 60,
                width: 60,
              ),
              const SizedBox(width: 8),
              const Text(
                'La jugada',
                style: TextStyle(fontSize: 20, fontFamily: "Pacifico"),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: canchaProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : canchaProvider.canchas.isEmpty
                ? const Center(child: Text("No hay canchas disponibles"))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: canchaProvider.canchas.map((cancha) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: CanchaCard(
                            cancha: cancha,
                            onTap: () {
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HorariosScreen(cancha: cancha),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
      ),
    );
  }
}
