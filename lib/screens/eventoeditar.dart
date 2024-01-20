import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'buscadoreventos.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:applogin/config.dart';
import 'package:applogin/models/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'mapa.dart';
import 'package:latlong2/latlong.dart';

class EventoEditScreen extends StatefulWidget {
  final Event event;
  late MapScreen _mapScreen;

  EventoEditScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EventoEditScreenState createState() => _EventoEditScreenState();
}

class _EventoEditScreenState extends State<EventoEditScreen> {
  late List<Event> events = [];
  LatLng? selectedLocation;
  late TextEditingController _eventNameController;
  late TextEditingController _eventDescriptionController;
  late TextEditingController _eventLocationController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  String token = '';
  final List<String> _categories = [
    'Pop',
    'Rock',
    'Rap',
    'Trap',
    'Jazz',
    'Metal',
    'Flamenco'
  ];

  @override
  void initState() {
    super.initState();
    loadData();
    _eventNameController = TextEditingController(text: widget.event.eventName);
    _eventDescriptionController =
        TextEditingController(text: widget.event.description);
   _eventLocationController = TextEditingController(
      text: widget.event.coordinates.join(', ') ?? '',
    );
    _selectedCategory = 'Pop';
    _selectedDate = widget.event.date;
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = prefs.getString('token') ?? '';
    });
  }

  Future<void> updateEvent() async {
    List<String> coordinatesArray = _eventLocationController.text.split(',').map((s) => s.trim()).toList();

      var response = await http.put(
        Uri.parse('$uri/events/${widget.event.id}'),
        headers: {'Content-Type': 'application/json', 'x-access-token': token},
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
        Navigator.pop(context,
            true); // Retorno a la pantalla anterior con indicador de actualización
      } else {
        print(
            'Error al actualizar el evento. Código de estado: ${response.statusCode}');
      }

  }

  Future<LatLng?> goToMapScreen() async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen(creatingEvent: true)),
    );

    return selectedLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editEvent),
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
                  labelText: AppLocalizations.of(context)!.name),
            ),
            TextField(
              controller: _eventDescriptionController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.description),
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
                  labelText: AppLocalizations.of(context)!.category),
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
            GestureDetector(
              onTap: () async {
                var selectedLocation = await goToMapScreen();
                if (selectedLocation != null) {
                  setState(() {
                    _eventLocationController.text =
                        '${selectedLocation!.latitude}, ${selectedLocation!.longitude}';
                    selectedLocation = LatLng(selectedLocation!.latitude,
                        selectedLocation!.longitude);
                    this.selectedLocation =
                        selectedLocation; // Guarda las coordenadas seleccionadas
                  });
                }
              },
              child: const Row(
                children: <Widget>[
                  Icon(Icons.map),
                  SizedBox(width: 10),
                  Text('Select Location on Map'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.saveChanges),
              onPressed: updateEvent,
              style: ElevatedButton.styleFrom(primary: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
