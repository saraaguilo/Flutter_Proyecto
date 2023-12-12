import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiYm9yamEyMDIzIiwiYSI6ImNscHd5Mmh0aDBoOXoya28yODB3dXNkNXUifQ.TLNdg-RLv0nuy5N9ihcoeg';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? myPosition;

  Future<void> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    final Position position = await Geolocator.getCurrentPosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Widget mapLayer({
    required Widget Function(BuildContext, MapState) builder,
  }) {
    return MapLayer(
      options: MapLayerOptions(
        stateBuilder: (context, mapState) => builder(context, mapState),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mapa'),
        backgroundColor: Colors.blueAccent,
      ),
      body: myPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                center: myPosition!,
                minZoom: 5,
                maxZoom: 25,
                zoom: 18,
              ),
              children: [
                mapLayer(
                  builder: (_, __) => TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=$MAPBOX_ACCESS_TOKEN',
                    additionalOptions: {'id': 'mapbox/streets-v12'},
                  ),
                ),
                // Add more widgets here if needed
              ],
            ),
    );
  }
}

class MapLayer extends StatelessWidget {
  final MapLayerOptions options;

  const MapLayer({Key? key, required this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return options.stateBuilder!(context, MapState());
  }
}

class MapLayerOptions {
  final Widget Function(BuildContext, MapState)? stateBuilder;

  const MapLayerOptions({this.stateBuilder});
}

class MapState {}
