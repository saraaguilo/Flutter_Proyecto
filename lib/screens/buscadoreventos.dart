import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/crearevento.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:applogin/screens/eventoeditar.dart';
import 'package:applogin/config.dart';
import 'package:applogin/models/event.dart';
import 'package:intl/intl.dart';

class BuscadorScreen extends StatefulWidget {
  const BuscadorScreen({Key? key}) : super(key: key);

  @override
  State<BuscadorScreen> createState() => _BuscadorScreenState();
}

class _BuscadorScreenState extends State<BuscadorScreen> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  Future<void> getEvents() async {
    try {
      final response = await http.get(Uri.parse('$uri/events'));

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

  // navegar a la pantalla de editar evento
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
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey[200],
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventoDetailScreen(event: events[index]),
                  ),
                );
              },
              child: ListTile(
                title: Text('Event Name: ${events[index].eventName}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coordinates: ${events[index].coordinates}'),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(events[index].date)}',
                    ),
                    Text('Description: ${events[index].description}'),
                  ],
                ),
                // Show the image from the network
                trailing: events[index].photo != null
                    ? Image.network(
                        events[index].photo!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(),
              ),
            ),
          );
        },
      ),
    ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0, right: 10.0),
        child: FloatingActionButton.extended(
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
