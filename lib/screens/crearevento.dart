import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/signin_screen.dart'; // acceso a currentUserEmail

class CrearEventoScreen extends StatefulWidget {
  @override
  _CrearEventoScreenState createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  String _selectedCategory = 'Pop';
  DateTime _selectedDate = DateTime.now();

  // categorias musicales
  final List<String> _categories = ['Pop', 'Rock', 'Rap', 'Trap', 'Jazz', 'Metal'];

  Future<String?> getCurrentUserId() async {
    var url = Uri.parse('http://localhost:9090/users');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      var currentUser = users.firstWhere(
        (user) => user['email'] == currentUserEmail,
        orElse: () => null,
      );
      return currentUser?['_id'];
    } else {
      print('Error al obtener usuarios: ${response.statusCode}');
      return null;
    }
  }

  Future<void> saveEvent() async {
  var idUser = await getCurrentUserId();
  if (idUser == null) {
    print('No se pudo obtener el ID del usuario');
    return;
  }

  List<String> coordinatesArray = _eventLocationController.text.split(',').map((s) => s.trim()).toList();

  var response = await http.post(
    Uri.parse('http://localhost:9090/events'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'eventName': _eventNameController.text,
      'description': _eventDescriptionController.text,
      'coordinates': coordinatesArray,
      'date': _selectedDate.toIso8601String(),
      'idUser': idUser,
    }),
  );

  if (response.statusCode == 201) {
    print('Evento guardado correctamente');
    Navigator.pop(context, true); // return a pantalla anterior e indica que se ha creado evento para refresh)
  } else {
    print('Error al guardar el evento. Código de estado: ${response.statusCode}');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear un nuevo evento'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(labelText: 'Nombre del Evento'),
            ),
            TextField(
              controller: _eventDescriptionController,
              decoration: InputDecoration(labelText: 'Descripción del Evento'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Categoría Musical'),
            ),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2025),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.calendar_today),
                  SizedBox(width: 10),
                  Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                ],
              ),
            ),
            TextField(
              controller: _eventLocationController,
              decoration: InputDecoration(labelText: 'Ubicación'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Guardar Evento'),
              onPressed: saveEvent,
              style: ElevatedButton.styleFrom(primary: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
