import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:qr_reader/providers/db_provider.dart';

class MapaPage extends StatefulWidget {
  final LatLng? destinationPoint; // opcional: segundo punto para ruta

  const MapaPage({super.key, this.destinationPoint});

  @override
  // ignore: library_private_types_in_public_api
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final Completer<GoogleMapController> _controller = Completer();
  MapType mapType = MapType.normal;

  // Polyline / API
  static const String _googleApiKey = 'AIzaSyDQZ6vfLniJwM7ZoYOB5mHwldcCTvFrtEM'; // reemplaza
  late final PolylinePoints _polylinePoints;
  Set<Polyline> _polylines = {};
  bool _routeRequested = false; // para evitar llamadas repetidas

  @override
  void initState() {
    super.initState();
    // Usar la fábrica "enhanced" con la apiKey (Routes API)
    _polylinePoints = PolylinePoints.enhanced(_googleApiKey);
  }

  Future<void> _drawPolyline(LatLng origin, LatLng destination) async {
    // limpia polylines previas
    setState(() {
      _polylines.clear();
    });

    try {
      final response = await _polylinePoints.getRouteBetweenCoordinatesV2(
        request: RequestConverter.createEnhancedRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          travelMode: TravelMode.driving,
        ),
      );

      if (response.routes.isNotEmpty) {
        // Convertir a formato legacy para obtener lista de PointLatLng
        final legacy = _polylinePoints.convertToLegacyResult(response);
        final points = legacy.points;
        if (points.isNotEmpty) {
          final coords = points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(growable: false);

          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.blue,
                points: coords,
                width: 4,
              ),
            );
          });
        }
      } else {
        // No route found -> no hace nada o podrías mostrar un error
      }
    } catch (e) {
      // Manejo simple de errores (puedes mejorar logging/ UI)
      debugPrint('Error al obtener ruta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scan = ModalRoute.of(context)!.settings.arguments as ScanModel;

    final CameraPosition puntoInicial = CameraPosition(
      target: scan.getLatLng(),
      zoom: 17.5,
      tilt: 50,
    );

    // Marcadores
    Set<Marker> markers = <Marker>{};

    markers.add(
      Marker(
        markerId: const MarkerId('geo-location'),
        position: scan.getLatLng(),
      ),
    );

    if (widget.destinationPoint != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destinationPoint!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // Pedir ruta una sola vez después del primer build cuando haya destination
      if (!_routeRequested) {
        _routeRequested = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _drawPolyline(scan.getLatLng(), widget.destinationPoint!);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_disabled),
            onPressed: () async {
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: scan.getLatLng(),
                    zoom: 17.5,
                    tilt: 50,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        mapType: mapType,
        markers: markers,
        polylines: _polylines,
        initialCameraPosition: puntoInicial,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.layers),
        onPressed: () {
          setState(() {
            mapType =
                mapType == MapType.normal ? MapType.satellite : MapType.normal;
          });
        },
      ),
    );
  }
}
