import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/crearevento.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:applogin/screens/eventoeditar.dart';
import 'package:applogin/config.dart';
import 'package:applogin/models/event.dart';
import 'package:intl/intl.dart';
import 'package:applogin/screens/chat_home.dart';
//import 'mapa.dart';
import 'package:provider/provider.dart';
import 'package:applogin/reusable_/event_provider.dart';

class BuscadorScreen extends StatefulWidget {
  const BuscadorScreen({Key? key}) : super(key: key);

  @override
  State<BuscadorScreen> createState() => _BuscadorScreenState();
}

class _BuscadorScreenState extends State<BuscadorScreen> {
  late List<Event> events;
  late EventProvider _eventProvider;

  @override
  void initState() {
    super.initState();

    //getEvents();
    _eventProvider = Provider.of<EventProvider>(context, listen: false);
    _eventProvider.getEvents();
    events = _eventProvider.events;
  }

  void navigateToCreateEventScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearEventoScreen()),
    );

    if (result == true) {
      //getEvents();
      _eventProvider.getEvents();
    }
  }

  void navigateToChatPrincipalScreen() async {
    // ignore: unused_local_variable
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
      //getEvents();
      _eventProvider.getEvents();
    }
  }

  // navegar a la pantalla de editar evento
  void navigateToEditEventScreen(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventoEditScreen(event: event)),
    );

    if (result == true) {
      //getEvents();
      _eventProvider.getEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events list'),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
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
              label: const Text('Create Event'),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.orange,
            ),
          ),
          Positioned(
            bottom: 140.0,
            right: 20.0,
            child: FloatingActionButton.extended(
              onPressed: navigateToChatPrincipalScreen,
              label: const Text('Join Chat Room'),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
