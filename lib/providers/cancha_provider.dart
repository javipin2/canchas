// providers/cancha_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cancha.dart';

class CanchaProvider with ChangeNotifier {
  List<Cancha> _canchas = [];
  bool _isLoading = false;

  List<Cancha> get canchas => _canchas;
  bool get isLoading => _isLoading;

  // Ahora fetchCanchas recibe la sede y la incluye en la petición a la API.
  Future<void> fetchCanchas(String sede) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse("http://localhost:5000/canchas?sede=$sede");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> canchasData = data['canchas'];
        _canchas = canchasData.map((json) => Cancha.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar canchas');
      }
    } catch (error) {
      throw Exception(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
