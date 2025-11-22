import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

ScanModel scanModelFromJson(String str) => ScanModel.fromJson(json.decode(str));
String scanModelToJson(ScanModel data) => json.encode(data.toJson());

class ScanModel {
  int? id;
  String tipo;
  String valor;

  // Constructor base
  ScanModel({this.id, required this.tipo, required this.valor});

  LatLng getLatLng() {
    // Limpia el prefijo "geo:" o "loc:" y posibles textos adicionales.
    String coords = valor;

    // Quitar el prefijo "geo:" o "loc:" si existe
    coords = coords.replaceAll('geo:', '').replaceAll('loc:', '');

    // Si hay "; value:", dividir y quedarnos con la parte antes del punto y coma
    if (coords.contains(';')) {
      coords = coords.split(';').first;
    }

    // Separar latitud y longitud
    final latLng = coords.split(',');
    final lat = double.parse(latLng[0]);
    final lng = double.parse(latLng[1]);

    return LatLng(lat, lng);
  }

  /// Crea un objeto desde JSON
  factory ScanModel.fromJson(Map<String, dynamic> json) =>
      ScanModel(id: json["id"], tipo: json["tipo"], valor: json["valor"]);

  /// Convierte el objeto a JSON
  Map<String, dynamic> toJson() => {"id": id, "tipo": tipo, "valor": valor};
}
