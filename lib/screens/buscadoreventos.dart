import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BuscadorScreen extends StatefulWidget {
  const BuscadorScreen({Key? key});

  @override
  State<BuscadorScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<BuscadorScreen> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  Future<void> getEvents() async {
    try {
      final response =
          await http.get(Uri.parse('http://147.83.7.158:9090/events'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          events = data.map((item) => Event.fromJson(item)).toList();
        });
      } else {
        print(
            'Error al cargar eventos. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      print('Error de red al cargar eventos: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events list'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.grey[
                  200], // Puedes ajustar el color de fondo según tus preferencias
              child: ListTile(
                title: Text('Event Name: ${events[index].eventName}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coordinates: ${events[index].coordinates}'),
                    Text('Date: ${events[index].date}'),
                    Text('Description: ${events[index].description}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Event {
  final String coordinates;
  final DateTime date;
  final String eventName;
  final String description;

  Event({
    required this.coordinates,
    required this.date,
    required this.eventName,
    required this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      coordinates: (json['coordinates'] as List<dynamic>)
          .join(', '), // Convertir la lista de coordenadas a una cadena
      date: DateTime.parse(json['date'] ?? ''),
      eventName: json['eventName'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
