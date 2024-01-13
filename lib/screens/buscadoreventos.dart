import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/crearevento.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:applogin/screens/eventoeditar.dart';
import 'package:applogin/config.dart';
import 'package:applogin/models/event.dart';
import 'package:intl/intl.dart';
import 'package:applogin/screens/chat_home.dart';
import 'mapa.dart';

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
          print('Número de eventos antes de navegar: ${events.length}');
        });
      } else {
        print(
            'Error al cargar eventos. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      print('Error de red al cargar eventos: $error');
    }
  }

  void navigateToCreateListEvents(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen(events: events)),
    );

    if (result == true) {
      getEvents();
      print('Número de eventos antes de navegar: ${events.length}');
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

  void navigateToChatPrincipalScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPrincipalScreen()),
    );
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
      body: Stack(
        children: [
          Container(
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
                            builder: (context) =>
                                EventoDetailScreen(event: events[index])),
                      );
                    },
                    child: ListTile(
                      title: Text('Event Name: ${events[index].eventName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Coordinates: ${events[index].coordinates}'),
                          Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(events[index].date)}'),
                          Text('Description: ${events[index].description}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 75.0,
            right: 20.0,
            child: FloatingActionButton.extended(
              onPressed: navigateToCreateEventScreen,
              label: Text('Create Event'),
              icon: Icon(Icons.add),
              backgroundColor: Colors.orange,
            ),
          ),
          Positioned(
            bottom: 140.0,
            right: 20.0,
            child: FloatingActionButton.extended(
              onPressed: navigateToChatPrincipalScreen,
              label: Text('Join Chat Room'),
              icon: Icon(Icons.add),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
