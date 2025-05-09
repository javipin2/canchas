// models/cancha.dart
class Cancha {
  final int id;
  final String nombre;
  final String descripcion;
  final String imagen;
  final bool techada;
  final String ubicacion;
  final double precio;
  final List<String> servicios;

  Cancha({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.techada,
    required this.ubicacion,
    required this.precio,
    required this.servicios,
  });

  // Método factory que crea una instancia de Cancha a partir de un JSON
  factory Cancha.fromJson(Map<String, dynamic> json) {
    List<String> serviciosFromJson = [];
    if (json['servicios'] != null) {
      serviciosFromJson =
          json['servicios'].toString().split(',').map((s) => s.trim()).toList();
    }
    return Cancha(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      imagen: json['imagen'] ?? '',
      techada: json['techada'] == 1 || json['techada'] == true,
      ubicacion: json['ubicacion'] ?? '',
      precio: double.tryParse(json['precio'].toString()) ?? 0,
      servicios: serviciosFromJson,
    );
  }
}
