import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/crearevento.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:applogin/screens/eventoeditar.dart';
import 'package:applogin/config.dart';
import 'package:applogin/models/event.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class BuscadorScreen extends StatefulWidget {
  const BuscadorScreen({Key? key}) : super(key: key);

  @override
  State<BuscadorScreen> createState() => _BuscadorScreenState();
}

class _BuscadorScreenState extends State<BuscadorScreen> {
  List<Event> events = [];
  List<Event> filteredEvents = [];
  double distanceFilter = 50000; //50 km por defecto
  Position? currentUserPosition;

  @override
  void initState() {
    super.initState();
    determinePosition();
    getEvents();
  }

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están desactivados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Los permisos de ubicación están permanentemente denegados, no podemos solicitar permisos.');
    } 

    currentUserPosition = await Geolocator.getCurrentPosition();
  }

  Future<void> getEvents() async {
    try {
      final response = await http.get(Uri.parse('$uri/events'));

      if (response.statusCode == 200) {
        print('Lista de eventos cargada correctamente');
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          events = data.map((item) => Event.fromJson(item)).toList();
          filteredEvents = events;
        });
      } else {
        print('Error al cargar eventos. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      print('Error de red al cargar eventos: $error');
    }
  }

void filterEvents(double distance) async {
  if (currentUserPosition == null) {
    currentUserPosition = await Geolocator.getCurrentPosition();
  }

  final queryParams = {
    'longitude': currentUserPosition!.longitude.toString(),
    'latitude': currentUserPosition!.latitude.toString(),
    'radius': distance.toString(), //distancia en metros
  };
  final queryString = Uri(queryParameters: queryParams).query;
  final uri = Uri.parse('http://localhost:9090/events/nearby?$queryString');
  //solicitud al backend
  final response = await http.get(uri, headers: {
    'Content-Type': 'application/json',
  });

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    setState(() {
      filteredEvents = data.map((item) => Event.fromJson(item)).toList();
    });
  } else {
    print('Error al filtrar eventos: ${response.statusCode}');
  }
}


  void navigateToCreateEventScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearEventoScreen()),
    );

    if (result == true) {
      getEvents();
    }
  }

  void navigateToDetailEventScreen(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventoDetailScreen(event: event)),
    );

    if (result == true) {
      getEvents();
    }
  }

  void navigateToEditEventScreen(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventoEditScreen(event: event)),
    );

    if (result == true) {
      getEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events list'),
        backgroundColor: Colors.orange,
        actions: <Widget>[
          PopupMenuButton<double>(
            onSelected: filterEvents,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
              const PopupMenuItem<double>(
                value: 10000,
                child: Text('A menos de 10km'),
              ),
              const PopupMenuItem<double>(
                value: 20000,
                child: Text('A menos de 20km'),
              ),
              const PopupMenuItem<double>(
                value: 50000,
                child: Text('A menos de 50km'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.grey[200],
              child: InkWell(
                onTap: () => navigateToDetailEventScreen(filteredEvents[index]),
                child: ListTile(
                  title: Text('Event Name: ${filteredEvents[index].eventName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coordinates: ${filteredEvents[index].coordinates}'),
                      Text('Date: ${DateFormat('yyyy-MM-dd').format(filteredEvents[index].date)}'),
                      Text('Description: ${filteredEvents[index].description}'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0, right: 10.0),
        child: FloatingActionButton.extended(
          heroTag: "TagCrearEvento",
          onPressed: navigateToCreateEventScreen,
          label: Text('Crear Evento'),
          icon: Icon(Icons.add),
          backgroundColor: Colors.orange,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}