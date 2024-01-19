import 'eventodetalles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart';
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
  late List<PopupMarker> _markers = [];
  late TapPosition pointed;
  //late Event event;
  List<Event>? events;
  final BuscadorScreen buscadorScreen = BuscadorScreen();
  final PopupController _popupController = PopupController();
  final Logger logger = Logger();
  late TextEditingController _searchController;
  //late FloatingSearchBarController _floatingSearchBarController;
  List<Event>? _searchResults;

  @override
  void initState() {
    super.initState();
    clickedLatlng = const LatLng(51.509364, -0.128928);
    print('Me inicializo correctamente');
    //initMarkers();
    // _markers = [];
    events = [];
    _searchController = TextEditingController();
    // _floatingSearchBarController = FloatingSearchBarController();
    _searchResults = [];
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
        _markers = await _generateMarkers(eventsWithCoordinates);
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

      // Verificar si se está creando un evento nuevo antes de cerrar el mapa
      if (Navigator.canPop(context)) {
        // Pasa las coordenadas seleccionadas de regreso a la pantalla de creación de eventos
        Navigator.pop(context, selectedLatLng);

        // Obtiene eventos utilizando el EventProvider
        await Provider.of<EventProvider>(context, listen: false).getEvents();
      } else {
        // No se está creando un evento nuevo, puedes hacer algo diferente o simplemente ignorarlo.
        print(
            'No se está creando un evento nuevo, no se realiza ninguna acción.');
      }
    } catch (error) {
      print('Error en handleMapTap: $error');
      // Manejar el error según tus necesidades
    }
  }

  List<PopupMarker> _generateMarkers(List<Event>? events) {
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

        return PopupMarker(
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
            return ExamplePopup(
              marker,
              eventLatLng,
              event: event,
            );
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
    _searchController.dispose();
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
              _markers.map((PopupMarker pm) => pm.marker).toList();

          return buildMap(mapMarkers);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget buildMap(List<Marker> mapMarkers) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        events = eventProvider.events;
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              FlutterMap(
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
                          _markers.map((PopupMarker pm) => pm.marker).toList(),
                      popupController: _popupController,
                      popupDisplayOptions: PopupDisplayOptions(
                        builder: (BuildContext context, Marker marker) {
                          final pm = _markers.firstWhere(
                            (PopupMarker pm) => pm.marker == marker,
                          );
                          return pm.popupBuilder(context, marker);
                        },
                        snap: PopupSnap.markerCenter,
                        animation: const PopupAnimation.fade(
                          duration: Duration(milliseconds: 200),
                        ),
                      ),
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
            ],
          ),
        );
      },
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

class PopupMarker {
  final Marker marker;
  final Widget Function(BuildContext, Marker) popupBuilder;
  final LatLng clickedLatlng;

  PopupMarker(this.clickedLatlng,
      {required this.marker, required this.popupBuilder});
}

class ExamplePopup extends StatelessWidget {
  final Marker marker;
  final LatLng clickedLatlng;
  final Event event;

  const ExamplePopup(this.marker, this.clickedLatlng,
      {required this.event, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Evento: ${event.eventName}'),
            Text('Fecha: ${event.date}'),
            Text('Descripción: ${event.description}'),
            const SizedBox(height: 8.0),
            InkWell(
              onTap: () {
                // Navegar a EventoDetailScreen() cuando se presiona el enlace
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventoDetailScreen(event: event),
                  ),
                );
              },
              child: Text(
                'Detalles del Evento',
                style: TextStyle(
                  color: Theme.of(context)
                      .primaryColor, // Usa el color primario del tema
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
