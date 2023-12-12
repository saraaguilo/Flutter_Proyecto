import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/buscadoreventos.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:applogin/config.dart';
import 'package:applogin/models/event.dart';

class EventoEditScreen extends StatefulWidget {
  final Event event;

  EventoEditScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EventoEditScreenState createState() => _EventoEditScreenState();
}

class _EventoEditScreenState extends State<EventoEditScreen> {
  late TextEditingController _eventNameController;
  late TextEditingController _eventDescriptionController;
  late TextEditingController _eventLocationController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  final List<String> _categories = ['Pop', 'Rock', 'Rap', 'Trap', 'Jazz', 'Metal'];

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(text: widget.event.eventName);
    _eventDescriptionController = TextEditingController(text: widget.event.description);
    _eventLocationController = TextEditingController(text: widget.event.coordinates.join(', '));
    _selectedCategory = 'Pop'; // Asumir categoría por defecto o añadir lógica para obtenerla
    _selectedDate = widget.event.date;
  }

  Future<void> updateEvent() async {
    List<String> coordinatesArray = _eventLocationController.text.split(',').map((s) => s.trim()).toList();

    var response = await http.put(
      Uri.parse('$uri/events/${widget.event.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'eventName': _eventNameController.text,
        'description': _eventDescriptionController.text,
        'coordinates': coordinatesArray,
        'date': _selectedDate.toIso8601String(),
        // Aquí puedes añadir otros campos que quieras actualizar
      }),
    );

    if (response.statusCode == 200) {
      print('Evento actualizado correctamente');
      Navigator.pop(context, true); // Retorno a la pantalla anterior con indicador de actualización
    } else {
      print('Error al actualizar el evento. Código de estado: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Evento'),
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
              child: Text('Guardar Cambios'),
              onPressed: updateEvent,
              style: ElevatedButton.styleFrom(primary: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
