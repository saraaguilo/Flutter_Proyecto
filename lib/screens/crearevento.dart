import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CrearEventoScreen extends StatefulWidget {
  @override
  _CrearEventoScreenState createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _eventLocationController =
      TextEditingController();
  String _selectedCategory = 'Pop';
  DateTime _selectedDate = DateTime.now();

  // categorías musicales
  final List<String> _categories = [
    'Pop',
    'Rock',
    'Rap',
    'Trap',
    'Jazz',
    'Metal'
  ];

  Future<void> saveEvent() async {
    var url = Uri.parse('http://147.83.7.158:9090/events');
    try {
      List<String> coordinatesArray = _eventLocationController.text
          .split(',')
          .map((s) => s.trim())
          .toList();

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'eventName': _eventNameController.text,
          'description': _eventDescriptionController.text,
          //'category': _selectedCategory,
          'coordinates': coordinatesArray,
          'date': _selectedDate.toIso8601String(),
        }),
      );
      if (response.statusCode == 201) {
        print('Evento guardado correctamente');
      } else {
        print(
            'Error al guardar el evento. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      print('Error al guardar el evento: $error');
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
              decoration: InputDecoration(
                labelText: 'Nombre del Evento',
              ),
            ),
            TextField(
              controller: _eventDescriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción del Evento',
              ),
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
              decoration: InputDecoration(
                labelText: 'Categoría Musical',
              ),
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
              decoration: InputDecoration(
                labelText: 'Ubicación',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Guardar Evento'),
              onPressed: saveEvent,
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
