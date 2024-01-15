import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:logger/logger.dart';
import 'crearevento.dart';
import 'package:applogin/models/event.dart';
import 'buscadoreventos.dart';
import 'package:provider/provider.dart';
import 'package:applogin/reusable_/event_provider.dart';
import 'dart:async';

// ignore: constant_identifier_names
const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiYm9yamEyMDIzIiwiYSI6ImNscHd5Mmh0aDBoOXoya28yODB3dXNkNXUifQ.TLNdg-RLv0nuy5N9ihcoeg';

void main() {
  //List<Event>? events;
  //navigateToCreateListEvents(events);
  runApp(const MapScreen());
}

class MapScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const MapScreen({Key? key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreen createState() => _MapScreen();
}

class _MapScreen extends State<MapScreen> {
  late LatLng clickedLatlng;
  late List<_PopupMarker> _markers = [];
  late TapPosition pointed;
  //late Event event;
  List<Event>? events;
  final BuscadorScreen buscadorScreen = BuscadorScreen();
  final PopupController _popupController = PopupController();
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    clickedLatlng = const LatLng(51.509364, -0.128928);
    print('Me inicializo correctamente');
    //initMarkers();
    // _markers = [];
    events = [];
    //buscadorScreen.createState().initState();
  }

  @override
  void didChangeDependencies() {
    print('He entrado en didChangesDependencies');
    super.didChangeDependencies();
    events = Provider.of<EventProvider>(context).events;

    if (events != null && events!.isNotEmpty) {
      initMarkers();
    }
  }

  Future<void> initMarkers() async {
    print('Entro en initMarkers');

    // Filtra eventos con coordenadas válidas
    final eventsWithCoordinates = events
        ?.where((event) =>
            event.coordinates.length >= 2 &&
            event.coordinates[0] != null &&
            event.coordinates[1] != null)
        .toList();

    if (eventsWithCoordinates != null && eventsWithCoordinates.isNotEmpty) {
      // Solo si hay eventos con coordenadas válidas
      print(
          'Coordenadas del primer evento: ${eventsWithCoordinates.first.coordinates[0]}, ${eventsWithCoordinates.first.coordinates[1]}');

      // Inicializa _markers solo una vez
      if (_markers.isEmpty) {
        _markers = _generateMarkers(eventsWithCoordinates);
      }
    } else {
      print(
          // ignore: unnecessary_brace_in_string_interps
          'Advertencia: No hay eventos con coordenadas válidas.${eventsWithCoordinates}');
    }

    print('Número de eventos antes de navegar: ${events?.length}');
    print('initMarkers is called');
  }

  Future<void> handleMapTap(TapPosition position, LatLng selectedLatLng) async {
    try {
      print('HandleMapTap, allá voy');

      // Pasa las coordenadas seleccionadas de regreso a la pantalla de creación de eventos
      Navigator.pop(context, selectedLatLng);

      // Obtiene eventos utilizando el EventProvider
      await Provider.of<EventProvider>(context, listen: false).getEvents();
    } catch (error) {
      print('Error en handleMapTap: $error');
      // Manejar el error según tus necesidades
    }
  }

  List<_PopupMarker> _generateMarkers(List<Event>? events) {
    print(
        'Estoy en generate markers no os preocupeis si no salen los marker algo falla dentro');
    print('Número de eventos: ${events?.length}');
    if (events != null) {
      return events.map((event) {
        LatLng eventLatLng;

        if (event.coordinates.length >= 2) {
          eventLatLng = LatLng(
            event
                .coordinates[0], // Suponiendo que el primer valor es la latitud
            event.coordinates[
                1], // Suponiendo que el segundo valor es la longitud
          );
        } else {
          // Manejar el caso donde event.coordinates no es válido
          // Puedes asignar un valor predeterminado o lanzar una excepción, según tus necesidades.
          // Ejemplo:
          eventLatLng = LatLng(0.0, 0.0); // Latitud y longitud por defecto
          print('Advertencia: event.coordinates no es válido.');
        }

        return _PopupMarker(
          eventLatLng,
          marker: Marker(
            width: 40.0,
            height: 40.0,
            point: eventLatLng,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
            ),
          ),
          popupBuilder: (BuildContext context, Marker marker) {
            return ExamplePopup(marker, eventLatLng);
            // Puedes personalizar el contenido del popup
          },
        );
      }).toList();
    } else {
      // Devolver una lista vacía si events es nulo
      return [];
    }
  }

  @override
  void dispose() {
    _popupController.dispose(); // Liberar recursos al cerrar la app
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<EventProvider>(context).initialized,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          events = Provider.of<EventProvider>(context).events;
          if (_markers.isEmpty && events != null && events!.isNotEmpty) {
            initMarkers();
          }

          final List<Marker> mapMarkers =
              _markers.map((_PopupMarker pm) => pm.marker).toList();

          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Social Groove'),
              ),
              body: Consumer<EventProvider>(
                builder: (context, eventProvider, _) {
                  events = eventProvider.events;
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: const LatLng(41.2741, 1.9922),
                        initialZoom: 9.2,
                        onTap: handleMapTap,
                      ),
                      children: [
                        MapLayer(
                          options: MapLayerOptions(
                            stateBuilder: (_, __) => TileLayer(
                              urlTemplate:
                                  'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=$MAPBOX_ACCESS_TOKEN',
                              additionalOptions: const {
                                'id': 'mapbox/streets-v12'
                              },
                            ),
                          ),
                        ),
                        MarkerLayer(
                          markers: mapMarkers,
                        ),
                        PopupMarkerLayer(
                          options: PopupMarkerLayerOptions(
                            markers: _markers
                                .map((_PopupMarker pm) => pm.marker)
                                .toList(),
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
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context, clickedLatlng);
                },
                child: const Icon(Icons.check),
              ),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
  /* Widget build(BuildContext context) {
    events = Provider.of<EventProvider>(context).events;
    _markers = _generateMarkers(events);
    final List<Marker> mapMarkers =
        _markers.map((_PopupMarker pm) => pm.marker).toList();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Social Groove'),
        ),
        body: Consumer<EventProvider>(
          builder: (context, eventProvider, _) {
            events = eventProvider.events;
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(41.2741, 1.9922),
                  initialZoom: 9.2,
                  onTap: handleMapTap,
                ),
                children: [
                  MapLayer(
                    options: MapLayerOptions(
                      stateBuilder: (_, __) => TileLayer(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=$MAPBOX_ACCESS_TOKEN',
                        additionalOptions: const {'id': 'mapbox/streets-v12'},
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
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, clickedLatlng);
          },
          child: const Icon(Icons.check),
        ),
      ),
    );
  } */
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

  const ExamplePopup(this.marker, this.clickedLatlng, {super.key});

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
