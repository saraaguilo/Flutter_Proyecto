import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BuscadorUnEventoScreen extends StatefulWidget {
  const BuscadorUnEventoScreen({Key? key});

  @override
  State<BuscadorUnEventoScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<BuscadorUnEventoScreen> {
  TextEditingController searchController = TextEditingController();
  Event? foundEvent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event details'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de búsqueda y botón
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter the event name',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    searchEvent();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange, // Establece el color naranja
                  ),
                  child: Text('Search'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Mostrar el evento encontrado
            if (foundEvent != null)
              Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                color: Colors.grey[200],
                child: ListTile(
                  title: Text('Event Name: ${foundEvent!.eventName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coordinates: ${foundEvent!.coordinates}'),
                      Text('Date: ${foundEvent!.date}'),
                      Text('Description: ${foundEvent!.description}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> searchEvent() async {
    try {
      final response =
          await http.get(Uri.parse('http://147.83.7.158:9090/events'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Buscar el evento por eventName
        final List<Event> matchingEvents = data
            .map((item) => Event.fromJson(item))
            .where((event) => event.eventName == searchController.text)
            .toList();

        if (matchingEvents.isNotEmpty) {
          setState(() {
            foundEvent = matchingEvents.first;
          });
        } else {
          setState(() {
            foundEvent = null;
          });
          print('No se encontraron eventos con el eventName especificado.');
        }
      } else {
        print(
            'Error al cargar eventos. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      print('Error de red al cargar eventos: $error');
    }
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
      coordinates: (json['coordinates'] as List<dynamic>).join(', '),
      date: DateTime.parse(json['date'] ?? ''),
      eventName: json['eventName'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
