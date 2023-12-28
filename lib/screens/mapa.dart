import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiYm9yamEyMDIzIiwiYSI6ImNscHd5Mmh0aDBoOXoya28yODB3dXNkNXUifQ.TLNdg-RLv0nuy5N9ihcoeg';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<_PopupMarker> _markers = [
    _PopupMarker(
      marker: Marker(
        width: 40.0,
        height: 40.0,
        alignment: Alignment.center,
        point: LatLng(41.2741, 1.9922),
        child: Container(
          child: Icon(
            Icons.location_on,
            color: Colors.red,
          ),
        ),
      ),
      popupBuilder: (BuildContext context, Marker marker) =>
          ExamplePopup(marker),
    ),
    _PopupMarker(
      marker: Marker(
        width: 40.0,
        height: 40.0,
        alignment: Alignment.center,
        point: LatLng(41.3851, 2.1734),
        child: Container(
          child: Icon(
            Icons.location_on,
            color: Colors.blue,
          ),
        ),
      ),
      popupBuilder: (BuildContext context, Marker marker) =>
          ExamplePopup(marker),
    ),
    _PopupMarker(
      marker: Marker(
        width: 40.0,
        height: 40.0,
        alignment: Alignment.center,
        point: LatLng(39.9496, 4.0979),
        child: Container(
          child: Icon(
            Icons.location_on,
            color: Colors.red,
          ),
        ),
      ),
      popupBuilder: (BuildContext context, Marker marker) =>
          ExamplePopup(marker),
    ),
    // Agrega más _PopupMarker aquí si es necesario
  ];
  final PopupController _popupController = PopupController();

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
          title: const Text('Groove'),
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: FlutterMap(
            options: const MapOptions(
              center: LatLng(41.2741, 1.9922),
              zoom: 9.2,
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

                      /*Stack(
                      children: [
                        MouseRegion(
                          onEnter: (_) {
                            _popupController.togglePopup(marker);
                          },
                          onExit: (_) {
                            _popupController.hideAllPopups();
                          },
                           child: GestureDetector(
          onTap: () {
            if (_popupController.togglePopup(marker,disableAnimation: true)) {
              _popupController.hideAllPopups();
            } else {
              _popupController.togglePopup(marker);
            }
          },
          //child: YourMarkerWidget(), // Reemplaza YourMarkerWidget con tu widget de marcador
        ),
                        ),
                      ],
                    );*/
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//class CustomMarkerWidget {}

//YourMarkerWidget() {}

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

  _PopupMarker({required this.marker, required this.popupBuilder});
}

class ExamplePopup extends StatelessWidget {
  final Marker marker;

  const ExamplePopup(this.marker);

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
