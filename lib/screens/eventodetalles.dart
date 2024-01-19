import 'dart:convert';
import 'package:applogin/screens/chat_screen.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  List<String> eventNames = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
    loadData();
    fetchEventNames();
  }

  Future<void> fetchEventNames() async {
    final response = await http.get(Uri.parse('$uri/events'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        eventNames =
            data.map((event) => event['eventName'].toString()).toList();
      });
    } else {
      print('Error al cargar los eventos: ${response.statusCode}');
    }
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = prefs.getString('token') ?? '';
      passedIdUser = prefs.getString('idUser') ?? '';

      // Añadir logs para depuración
      if (token.isEmpty) {
        print('Token not found');
      } else {
        print('Token found: $token');
        // Aquí podrías añadir lógica adicional para verificar la caducidad del token
        // si tu token incluye una marca de tiempo de expiración.
      }
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
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(AppLocalizations.of(context)!.errorComment),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.close),
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
        headers: {'Content-Type': 'application/json', 'x-access-token': token},
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

  bool isCommentByCurrentUser(String commentUserId) {
    return commentUserId == passedIdUser;
  }

  Future<void> deleteComment(String commentId) async {
    var url = Uri.parse('$uri/comments/$commentId');
    var response = await http.delete(url, headers: {'x-access-token': token});

    if (response.statusCode == 200) {
      print('Comentario eliminado con éxito');
      _loadComments();
    } else {
      print('Error al eliminar comentario: ${response.statusCode}');
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
                      '${AppLocalizations.of(context)!.description}: ${widget.event.description}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${AppLocalizations.of(context)!.date}: ${DateFormat('yyyy-MM-dd').format(widget.event.date)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${AppLocalizations.of(context)!.location}: ${widget.event.coordinates}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(width: 200),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(16.0),
                    padding: EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: widget.event.photo != null
                          ? Image.network(
                              widget.event.photo!,
                              width: 300,
                              height: 200,
                              fit: BoxFit.cover
                            )
                          : Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.black,
                            ),
                    ),
                  ),
                ),
             
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  navigateToChatScreen(context, widget.event.eventName);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.joinEvent,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.commentHint,
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
                child: Text(AppLocalizations.of(context)!.leaveComment),
              ),
            ),
            if (isLoading) Center(child: CircularProgressIndicator()),
            if (!isLoading && comments.isEmpty)
              Text(AppLocalizations.of(context)!.noComments),
            ...comments
                .map((comment) => Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 196, 107),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Align(
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
                          if (isCommentByCurrentUser(comment.userId))
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: ElevatedButton(
                                onPressed: () => deleteComment(comment.id),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Delete Comment',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ))
                .toList(),
            SizedBox(height: 60),
            if (passedIdUser == widget.event.idUser)
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
                    child: Text(AppLocalizations.of(context)!.editEvent),
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
                    child: Text(AppLocalizations.of(context)!.deleteEvent),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void navigateToChatScreen(BuildContext context, String eventName) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(chatName: eventName),
    ),
  );
}

//moure a una classe
class Comment {
  final String id; // Agregar esta línea
  final String userId;
  final String userName;
  final String text;
  final DateTime date;
  final double punctuation;

  Comment({
    required this.id, // Agregar esta línea
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
      id: json['_id'], // Agregar esta línea para obtener el ID del JSON
      userId: userId,
      userName: userName,
      text: json['text'],
      date: DateTime.parse(json['date']),
      punctuation:
          json['punctuation'] != null ? json['punctuation'].toDouble() : 0.0,
    );
  }
}
