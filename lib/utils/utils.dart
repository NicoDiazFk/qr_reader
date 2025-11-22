import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_reader/providers/db_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_reader/utils/location_helper.dart';

Future<void> launchURL(BuildContext context, ScanModel scan) async {

  if (scan.tipo == 'otro') return;
  
  if (scan.tipo == 'http') {
    final url = scan.valor;

    final Uri uriUrl = Uri.parse(url);
    // Abrir el sitio web
    if (!await launchUrl(uriUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uriUrl');
    }
  } else {
    //Crear Ruta
    final pos = await LocationHelper.getCurrentPosition();
    if (pos != null) {
      final lat = pos.latitude;
      final lng = pos.longitude;
      final devicePos = LatLng(lat, lng);
    }
    
    if (!context.mounted) return;
    //Abrir mapa
    Navigator.pushNamed(context, 'mapa', arguments: scan);
  }
}

