import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sede_provider.dart';
import 'canchas_screen.dart';

class SedeScreen extends StatelessWidget {
  const SedeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Sede'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selecciona una sede para continuar:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Provider.of<SedeProvider>(context, listen: false)
                    .setSede('Sede 1');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CanchasScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Sede 1',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Provider.of<SedeProvider>(context, listen: false)
                    .setSede('Sede 2');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CanchasScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Sede 2',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
