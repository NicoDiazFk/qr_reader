import 'package:flutter/material.dart';
import 'package:qr_reader/widgets/scan_tiles.dart';

class UbicacionesPage extends StatelessWidget {
  const UbicacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScanTiles(tipo: 'geo');
  }
}
