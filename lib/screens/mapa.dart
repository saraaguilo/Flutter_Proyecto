import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:logger/logger.dart';
import 'crearevento.dart';
import 'package:applogin/models/event.dart';
import 'buscadoreventos.dart';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiYm9yamEyMDIzIiwiYSI6ImNscHd5Mmh0aDBoOXoya28yODB3dXNkNXUifQ.TLNdg-RLv0nuy5N9ihcoeg';

void main() {
  final List<Event> events = [];
  //navigateToCreateListEvents(events);
  runApp(MapScreen(events: events));
}

class MapScreen extends StatefulWidget {
  final List<Event> events;
  const MapScreen({Key? key, required this.events}) : super(key: key);

  @override
  _MapScreen createState() => _MapScreen();
}

class _MapScreen extends State<MapScreen> {
  late LatLng clickedLatlng;
  late List<_PopupMarker> _markers;
  late TapPosition pointed;
  late Event event;

  final PopupController _popupController = PopupController();
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    clickedLatlng = LatLng(51.509364, -0.128928);
    _markers = [];
    print('initState is called');
    print('Número de eventos antes de navegar: ${widget.events.length}');
    initMarkers(widget.events);
  }

  Future<void> initMarkers(List<Event> events) async {
    print('Número de eventos antes de navegar: ${events.length}');
    print('initMarkers is called');
    setState(() {
      _markers = _generateMarkers(events);
      print('Número de eventos: ${events.length}');
    });
  }

  Future<void> handleMapTap(TapPosition position, LatLng selectedLatLng) async {
    // Pasa las coordenadas seleccionadas de regreso a la pantalla de creación de eventos
    Navigator.pop(context, selectedLatLng);
  }

  List<_PopupMarker> _generateMarkers(List<Event> events) {
    print('Número de eventos: ${events.length}');
    return events.map((event) {
      LatLng eventLatLng = LatLng(
        event.coordinates[0], // Suponiendo que el primer valor es la latitud
        event.coordinates[1], // Suponiendo que el segundo valor es la longitud
      );
      return _PopupMarker(
        eventLatLng,
        marker: Marker(
          width: 40.0,
          height: 40.0,
          point: eventLatLng,
          child: Container(
            child: Icon(
              Icons.location_on,
              color: Colors.red,
            ),
          ),
        ),
        popupBuilder: (BuildContext context, Marker marker) {
          return ExamplePopup(marker,
              eventLatLng); // Puedes personalizar el contenido del popup
        },
      );
    }).toList();
  }

  /* void handleTap(TapPosition position, LatLng latLng) {
    setState(() {
      pointed = position;
      clickedLatlng = latLng;
      _markers.add(
        _PopupMarker(
          latLng,
          marker: Marker(
            width: 40.0,
            height: 40.0,
            alignment: Alignment.center,
            point: latLng,
            child: Container(
              child: Icon(
                Icons.location_on,
                color: Colors.red,
              ),
            ),
          ),
          popupBuilder: (BuildContext context, Marker marker) =>
              ExamplePopup(marker, clickedLatlng),
        ),
      );
      print('Coordenadas clickeadas: ${latLng.latitude}, ${latLng.longitude}');
    });
  }*/

  @override
  void dispose() {
    _popupController.dispose(); // Liberar recursos al cerrar la app
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Marker> mapMarkers =
        _markers.map((_PopupMarker pm) => pm.marker).toList();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Social Groove'),
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(41.2741, 1.9922),
              initialZoom: 9.2,
              onTap: handleMapTap,
            ),
            children: [
              MapLayer(
                options: MapLayerOptions(
                  stateBuilder: (_, __) => TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=$MAPBOX_ACCESS_TOKEN',
                    additionalOptions: {'id': 'mapbox/streets-v12'},
                  ),
                ),
              ),
              MarkerLayer(
                markers: mapMarkers,
              ),
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                    markers:
                        _markers.map((_PopupMarker pm) => pm.marker).toList(),
                    popupController: _popupController,
                    popupDisplayOptions: PopupDisplayOptions(
                        builder: (BuildContext context, Marker marker) {
                          final pm = _markers.firstWhere(
                            (_PopupMarker pm) => pm.marker == marker,
                          );
                          return pm.popupBuilder(context, marker);
                        },
                        snap: PopupSnap.markerCenter,
                        animation: const PopupAnimation.fade(
                            duration: Duration(milliseconds: 300))),
                    selectedMarkerBuilder:
                        (BuildContext context, Marker marker) {
                      return MouseRegion(
                        onEnter: (event) {
                          _popupController.togglePopup(marker);
                        },
                        child: GestureDetector(
                          onTap: () {
                            _popupController.togglePopup(marker);
                          },
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, clickedLatlng);
          },
          child: Icon(Icons.check),
        ),
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

class _PopupMarker {
  final Marker marker;
  final Widget Function(BuildContext, Marker) popupBuilder;
  final LatLng clickedLatlng;

  _PopupMarker(this.clickedLatlng,
      {required this.marker, required this.popupBuilder});
}

class ExamplePopup extends StatelessWidget {
  final Marker marker;
  final LatLng clickedLatlng;

  const ExamplePopup(this.marker, this.clickedLatlng);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Popup content for marker at ${marker.point}'),
      ),
    );
  }
}
