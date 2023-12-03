import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/buscadoreventos.dart';
import 'package:applogin/screens/signin_screen.dart'; // importa para acceder a currentUserEmail

class EventoDetailScreen extends StatelessWidget {
  final Event event;
  final TextEditingController commentController = TextEditingController();

  EventoDetailScreen({Key? key, required this.event}) : super(key: key);

  Future<String?> getCurrentUserId() async {
    var url = Uri.parse('http://localhost:9090/users');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      var currentUser = users.firstWhere(
        (user) => user['email'] == currentUserEmail, // currentUserEmail aquí
        orElse: () => null,
      );
      return currentUser?['_id'];
    } else {
      print('Error al obtener usuarios: ${response.statusCode}');
      return null;
    }
  }

  Future<void> postComment(String userId) async {
    var commentUrl = Uri.parse('http://localhost:9090/comments');
    var commentResponse = await http.post(
      commentUrl,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'text': commentController.text,
        'date': DateTime.now().toIso8601String(),
      }),
    );

    if (commentResponse.statusCode == 201) {
      print('Comentario enviado con éxito');
      var commentData = json.decode(commentResponse.body);
      var commentId = commentData['_id']; 
      await addCommentToEvent(commentId);
    } else {
      print('Error al enviar comentario: ${commentResponse.statusCode}');
    }
  }

  Future<void> addCommentToEvent(String commentId) async {
  var getEventUrl = Uri.parse('http://localhost:9090/events/${event.id}');
  var getEventResponse = await http.get(getEventUrl);

  if (getEventResponse.statusCode == 200) {
    var eventData = json.decode(getEventResponse.body);
    
    List<dynamic> idComments = List<dynamic>.from(eventData['idComments'] ?? []);
    idComments.add(commentId);

    var updateEventUrl = Uri.parse('http://localhost:9090/events/${event.id}');
    var updateEventResponse = await http.put(
      updateEventUrl,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'idComments': idComments,
      }),
    );

    if (updateEventResponse.statusCode == 200) {
      print('Evento actualizado con éxito');
    } else {
      print('Error al actualizar evento: ${updateEventResponse.statusCode}');
    }
  } else {
    print('Error al obtener detalles del evento: ${getEventResponse.statusCode}');
  }
}

void handlePostComment() async {
  String? userId = await getCurrentUserId();
  if (userId != null) {
    await postComment(userId);
  } else {
    print('Error: No se pudo obtener el ID del usuario');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.eventName),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
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
            Text(
              'Fecha: ${event.date}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Ubicación: ${event.coordinates}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Join Event',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Deja tu comentario aquí',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: handlePostComment,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Dejar Comentario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Comment {
  final String userId;
  final String text;
  final DateTime date;

  Comment({
    required this.userId,
    required this.text,
    required this.date,
  });
}
