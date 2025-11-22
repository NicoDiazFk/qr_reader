import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:qr_reader/providers/db_provider.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final Completer<GoogleMapController> _controller = Completer();
  MapType mapType = MapType.normal;

  // Toca cambiar esta por la propia API Key de Google Maps para configurarla
  static const String _googleApiKey = 'AIzaSyD1pPA7tmp6QP8KwN9uf5Oa2U3ig5GqgrE';

  late final PolylinePoints _polylinePoints;
  Set<Polyline> _polylines = {};
  bool _routeRequested = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos PolylinePoints con la API Key
    _polylinePoints = PolylinePoints(apiKey: _googleApiKey);
  }

  // 🔷 Método para dibujar la ruta entre dos puntos
  Future<void> _drawRoute(LatLng origin, LatLng destination) async {
    setState(() => _polylines.clear());

    try {
      // Aqui se deberia Usar la API de Rutas
      final RoutesApiRequest request = RoutesApiRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
        routingPreference: RoutingPreference.trafficAware,
      );

      final RoutesApiResponse response =
          await _polylinePoints.getRouteBetweenCoordinatesV2(request: request);

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;
        final points = route.polylinePoints ?? [];

        if (points.isNotEmpty) {
          final coords = points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(growable: false);

          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.blue,
                width: 5,
                points: coords,
              ),
            );
          });

          debugPrint(
              'Ruta cargada: ${route.distanceKm} km (${route.durationMinutes} min)');
        }
      } else {
        debugPrint('No se encontró ninguna ruta disponible');
      }
    } catch (e) {
      debugPrint('Error al obtener la ruta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final scan = args['scan'] as ScanModel;
    final userLocation = args['userLocation'] as LatLng?;

    final CameraPosition puntoInicial = CameraPosition(
      target: scan.getLatLng(),
      zoom: 14.5,
      tilt: 45,
    );

    // Marcadores en el mapa
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('destino'),
        position: scan.getLatLng(),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    if (userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('origen'),
          position: userLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // Dibujar la ruta una vez
      if (!_routeRequested) {
        _routeRequested = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _drawRoute(userLocation, scan.getLatLng());
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              final controller = await _controller.future;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: scan.getLatLng(),
                    zoom: 15,
                    tilt: 45,
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
        onMapCreated: (controller) => _controller.complete(controller),
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
