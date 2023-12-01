import 'package:flutter/material.dart';
import 'package:applogin/screens/buscadoreventos.dart'; 

class EventoDetailScreen extends StatelessWidget {
  final Event event;

  EventoDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.eventName),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nombre del Evento: ${event.eventName}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Descripción: ${event.description}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            //Text(
            //  'Categoría Musical: ${event.category}', // Asegúrate de que Event tiene un campo 'category'
           //   style: TextStyle(fontSize: 16),
           // ),
            SizedBox(height: 10),
            Text(
              'Fecha: ${event.date}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Ubicación: ${event.coordinates}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}