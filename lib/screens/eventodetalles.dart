import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/buscadoreventos.dart';
import 'package:applogin/screens/signin_screen.dart'; // acceso a currentUserEmail
import 'package:applogin/screens/eventoeditar.dart';
import 'package:applogin/models/event.dart';
import 'package:applogin/config.dart';
import 'package:intl/intl.dart';
import 'package:applogin/screens/chat_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  double currentRating = 0;
  String token = '';
  String passedIdUser = '';

  @override
  void initState() {
    super.initState();
    _loadComments();
    loadData();
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = prefs.getString('token') ?? '';
      passedIdUser = prefs.getString('idUser') ?? '';
    });
  }

  Future<void> _deleteEvent() async {
    var url = Uri.parse('$uri/events/${widget.event.id}');
    var response = await http.delete(url, headers: {'x-access-token': token});

    if (response.statusCode == 201) {
      print('Evento eliminado con éxito');
      Navigator.pop(context,
          true); // true para refresh de la lista en la pantalla anterior
    } else {
      print('Error al eliminar evento: ${response.statusCode}');
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
    });

    var eventUrl = Uri.parse('$uri/events/${widget.event.id}');
    var eventResponse = await http.get(eventUrl);
    List<Comment> loadedComments = [];
    if (eventResponse.statusCode == 200) {
      var eventData = json.decode(eventResponse.body);
      List<String> commentIds =
          List<String>.from(eventData['idComments'] ?? []);

      for (var commentId in commentIds) {
        var commentUrl = Uri.parse('$uri/comments/$commentId');
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
    if (currentRating == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(
                "Es necesario indicar una puntuación para dejar el comentario"),
            actions: <Widget>[
              TextButton(
                child: Text("Cerrar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    String? userId = await passedIdUser;
    if (userId != null) {
      await postComment(userId);
    } else {
      print('Error: No se pudo obtener el ID del usuario');
    }
  }

  Future<void> postComment(String userId) async {
    var commentUrl = Uri.parse('$uri/comments');
    var commentResponse = await http.post(
      commentUrl,
      headers: {'Content-Type': 'application/json', 'x-access-token': token},
      body: json.encode({
        'userId': userId,
        'text': commentController.text,
        'date': DateTime.now().toIso8601String(),
        'punctuation': currentRating,
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
    var getEventUrl = Uri.parse('$uri/events/${widget.event.id}');
    var getEventResponse = await http.get(getEventUrl);

    if (getEventResponse.statusCode == 200) {
      var eventData = json.decode(getEventResponse.body);
      List<dynamic> idComments =
          List<dynamic>.from(eventData['idComments'] ?? []);
      idComments.add(commentId);

      var updateEventUrl = Uri.parse('$uri/events/${widget.event.id}');
      var updateEventResponse = await http.put(
        updateEventUrl,
        headers: {'Content-Type': 'application/json','x-access-token': token},
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
      print(
          'Error al obtener detalles del evento: ${getEventResponse.statusCode}');
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
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.event.eventName}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Description: ${widget.event.description}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(widget.event.date)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Location: ${widget.event.coordinates}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(width: 200),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.all(16.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      Icons.image,
                      size: 100.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPrincipalScreen()),
                  );
                },
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
                labelText: 'Leave your comment here',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            Center(
              child: RatingBar.builder(
                initialRating: currentRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (punctuation) {
                  setState(() {
                    currentRating = punctuation;
                  });
                },
              ),
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
                child: Text('Leave Comment'),
              ),
            ),
            if (isLoading) Center(child: CircularProgressIndicator()),
            if (!isLoading && comments.isEmpty) Text('There are no comments'),
            ...comments
                .map((comment) => Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 196, 107),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.userName,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              comment.date.toLocal().toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              comment.text,
                              style: TextStyle(color: Colors.black),
                            ),
                            RatingBarIndicator(
                              rating: comment.punctuation,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
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
                          builder: (context) =>
                              EventoEditScreen(event: widget.event),
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
                    child: Text('Edit Event'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteEvent,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Delete Event'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
//moure a una classe
class Comment {
  final String userId;
  final String userName;
  final String text;
  final DateTime date;
  final double punctuation;

  Comment({
    required this.userId,
    required this.userName,
    required this.text,
    required this.date,
    required this.punctuation,
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
      punctuation:
          json['punctuation'] != null ? json['punctuation'].toDouble() : 0.0,
    );
  }
}
