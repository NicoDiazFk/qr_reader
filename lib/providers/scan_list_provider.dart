import 'package:flutter/material.dart';
import 'package:qr_reader/providers/db_provider1.dart';
import 'package:qr_reader/utils/location_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ScanListProvider extends ChangeNotifier {
  List<ScanModel> scans = [];
  String tipoSeleccionado = '';

  Future<ScanModel> nuevoScan(String valor) async {
    // Determinar tipo
    String tipo;
    if (valor.contains('http')) {
      tipo = 'http';
    } else if (valor.contains('geo')) {
      tipo = 'geo';
    } else {
      tipo = 'otro';
    }


    // Si es "otro", capturamos ubicación actual
    if (tipo == 'otro') {
      final pos = await LocationHelper.getCurrentPosition();
      if (pos != null) {
        // Guardamos como "loc:lat,lng; value:texto"
        valor = 'loc:${pos.latitude},${pos.longitude}; value:$valor';
      }
    }
     // Si es "geo", también obtenemos la ubicación actual
    LatLng? currentLocation;
    if (tipo == 'geo') {
      final pos = await LocationHelper.getCurrentPosition();
      if (pos != null) {
      currentLocation = LatLng(pos.latitude, pos.longitude);
      }
    }

    // Crear modelo
    final nuevoScan = ScanModel(tipo: tipo, valor: valor);

    // Guardar en BD
    final id = await DBProvider1.db.nuevoScan(nuevoScan);
    nuevoScan.id = id;

    if (tipoSeleccionado == tipo) {
      scans.add(nuevoScan);
      notifyListeners();
    }


    return nuevoScan;
  }

  Future<void> cargarScanPorTipo(String tipo) async {
    final scans = await DBProvider1.db.getScansPorTipo(tipo);
    this.scans = [...scans];
    tipoSeleccionado = tipo;
    notifyListeners();
  }
Future<void> borrarTodos() async {
  await DBProvider1.db.deleteScansByType(tipoSeleccionado);
  scans = [];
  notifyListeners();
}
  Future<void> borrarScanPorId(int id) async {
    await DBProvider1.db.deleteScan(id);
  }
}

  