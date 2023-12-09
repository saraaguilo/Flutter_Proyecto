import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/buscadoreventos.dart';
import 'package:applogin/screens/signin_screen.dart'; // acceso currentUserEmail
import 'package:applogin/screens/eventoeditar.dart';

class EventoDetailScreen extends StatefulWidget {
  final Event event;

  EventoDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EventoDetailScreenState createState() => _EventoDetailScreenState();
}

class _EventoDetailScreenState extends State<EventoDetailScreen> {
  final TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _getCurrentUserId();
  }

  Future<String?> _getCurrentUserId() async {
    var url = Uri.parse('http://localhost:9090/users');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      var currentUser = users.firstWhere(
        (user) => user['email'] == currentUserEmail,
        orElse: () => null,
      );
      setState(() {
        currentUserId = currentUser?['_id'];
      });
      return currentUser?['_id'];
    } else {
      print('Error al obtener usuarios: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _deleteEvent() async {
    var url = Uri.parse('http://localhost:9090/events/${widget.event.id}');
    var response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Evento eliminado con éxito');
      Navigator.pop(context, true); // true para refrescar la lista en la pantalla anterior
    } else {
      print('Error al eliminar evento: ${response.statusCode}');
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
    });

    var eventUrl = Uri.parse('http://localhost:9090/events/${widget.event.id}');
    var eventResponse = await http.get(eventUrl);
    List<Comment> loadedComments = [];
    if (eventResponse.statusCode == 200) {
      var eventData = json.decode(eventResponse.body);
      List<String> commentIds = List<String>.from(eventData['idComments'] ?? []);

      for (var commentId in commentIds) {
        var commentUrl = Uri.parse('http://localhost:9090/comments/$commentId');
        var commentResponse = await http.get(commentUrl);
        if (commentResponse.statusCode == 200) {
          var commentData = json.decode(commentResponse.body);
          loadedComments.add(Comment.fromJson(commentData));
        }
      }
    }

    setState(() {
      comments = loadedComments;
      isLoading = false;
    });
  }

  void handlePostComment() async {
    String? userId = await _getCurrentUserId();
    if (userId != null) {
      await postComment(userId);
    } else {
      print('Error: No se pudo obtener el ID del usuario');
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
    var getEventUrl = Uri.parse('http://localhost:9090/events/${widget.event.id}');
    var getEventResponse = await http.get(getEventUrl);

    if (getEventResponse.statusCode == 200) {
      var eventData = json.decode(getEventResponse.body);
      List<dynamic> idComments = List<dynamic>.from(eventData['idComments'] ?? []);
      idComments.add(commentId);

      var updateEventUrl = Uri.parse('http://localhost:9090/events/${widget.event.id}');
      var updateEventResponse = await http.put(
        updateEventUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idComments': idComments,
        }),
      );

      if (updateEventResponse.statusCode == 200) {
        print('Evento actualizado con éxito');
        _loadComments(); // refresh de comentarios después de agregar uno nuevo
      } else {
        print('Error al actualizar evento: ${updateEventResponse.statusCode}');
      }
    } else {
      print('Error al obtener detalles del evento: ${getEventResponse.statusCode}');
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.eventName),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nombre del Evento: ${widget.event.eventName}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Descripción: ${widget.event.description}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Fecha: ${widget.event.date}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Ubicación: ${widget.event.coordinates}',
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
            if (isLoading)
              Center(child: CircularProgressIndicator()),
            if (!isLoading && comments.isEmpty)
              Text('No hay comentarios'),
            ...comments.map((comment) => Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                comment.text,
                style: TextStyle(color: Colors.white),
              ),
            )).toList(),
            SizedBox(height: 60),
            if (currentUserId == widget.event.idUser) 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventoEditScreen(event: widget.event),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.orange,
                      side: BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Editar Evento'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteEvent,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Borrar Evento'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Declaración de la clase Comment fuera de la clase EventoDetailScreen
class Comment {
  final String userId;
  final String userName;
  final String text;
  final DateTime date;

  Comment({
    required this.userId,
    required this.userName,
    required this.text,
    required this.date,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    var user = json['userId'];
    var userId = '';
    var userName = '';

    if (user is Map) {
      userId = user['_id'];
      userName = user['userName'];
    } else {
      userId = user.toString();
    }

    return Comment(
      userId: userId,
      userName: userName,
      text: json['text'],
      date: DateTime.parse(json['date']),
    );
  }
}
