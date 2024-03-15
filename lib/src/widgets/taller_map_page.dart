import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TallerMapPage extends StatefulWidget {
  const TallerMapPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TallerMapPageState createState() => _TallerMapPageState();
}

class _TallerMapPageState extends State<TallerMapPage> {
  static const LatLng _center = LatLng(-0.345681000680282, -78.43577384959889); // Ejemplo de coordenadas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación del Taller Mecánico'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('tallerId'),
            position: _center,
            infoWindow: InfoWindow(
              title: 'Taller Mecánico del Instituto Rumiñahui',
              snippet: 'La mejor calidad y servicio.',
            ),
          ),
        },
      ),
    );
  }
}
