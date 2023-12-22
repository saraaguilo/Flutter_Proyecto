import 'dart:convert';
import 'package:applogin/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/crearevento.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:applogin/screens/eventoeditar.dart';
import 'package:applogin/config.dart';
import 'package:applogin/models/event.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class BuscadorScreen extends StatefulWidget {
  const BuscadorScreen({Key? key}) : super(key: key);

  @override
  State<BuscadorScreen> createState() => _BuscadorScreenState();
}

class _BuscadorScreenState extends State<BuscadorScreen> {
  List<Event> events = [];
  String? url;

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

//cambiar al routing
  void navigateToCreateEventScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearEventoScreen()),
    );

    if (result == true) {
      getEvents();
    }
  }

//SE USAN?
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
                  AppNavigation.eventArguments = events[index];
                  GoRouter.of(context).go('/events/${events[index].id}');
                },
                child: Row(
                  children: [
                    // Contenido de la Card
                    Expanded(
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
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.share_outlined),
                      onPressed: () {
                        url =
                            'http://147.83.7.158:8080/#/events/${events[index].id}';

                        Share.share(
                            'Take a look at this event in SocialGroove App! ${events[index].eventName} will take place the ${events[index].date.toLocal()} at location ${events[index].coordinates}. \n Click here for more information! $url');
                      },
                    ),
                  ],
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
