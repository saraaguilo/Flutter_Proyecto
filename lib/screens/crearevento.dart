2import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/signin_screen.dart'; // acceso a currentUserEmail
import 'package:applogin/config.dart';
import 'package:applogin/models/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'mapa.dart';
import 'package:latlong2/latlong.dart';
import 'package:applogin/models/event.dart';

class CrearEventoScreen extends StatefulWidget {
  late MapScreen _mapScreen;
  late Event event;

  @override
  _CrearEventoScreenState createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  LatLng? selectedLocation;
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _eventLocationController =
      TextEditingController();
  String _selectedCategory = 'Pop';
  DateTime _selectedDate = DateTime.now();
  String token = '';
  String passedIdUser = '';
  late List<Event> events = [];

  // categorías musicales
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
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = prefs.getString('token') ?? '';
      passedIdUser = prefs.getString('idUser') ?? '';
    });
  }

  Future<void> saveEvent() async {
    var idUser = await passedIdUser;
    if (idUser == null) {
      print('No se pudo obtener el ID del usuario');
      return;
    }
    List<double> coordinatesArray = [
      selectedLocation?.latitude ?? 0.0,
      selectedLocation?.longitude ?? 0.0,
    ];

    /*List<String> coordinatesArray = _eventLocationController.text
        .split(
            '${selectedLocation?.latitude.toString()},${selectedLocation?.longitude.toString()}')
        .map((s) => s.trim())
        .toList();*/

    var response = await http.post(
      Uri.parse('$uri/events'),
      headers: {'Content-Type': 'application/json', 'x-access-token': token},
      body: json.encode({
        'eventName': _eventNameController.text,
        'description': _eventDescriptionController.text,
        'coordinates': coordinatesArray,
        'date': _selectedDate.toIso8601String(),
        'idUser': idUser,
      }),
    );

    if (response.statusCode == 201) {
      print('Evento guardado correctamente: $coordinatesArray');
      Navigator.pop(context,
          true); // return a pantalla anterior e indica que se ha creado evento para refresh)
    } else {
      print(
          'Error al guardar el evento. Código de estado: ${response.statusCode}');
    }
  }

  Future<LatLng?> goToMapScreen() async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
    print('$selectedLocation');
    return selectedLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createEventHint),
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
                  labelText: AppLocalizations.of(context)!.musicalCategory),
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
              child: Row(
                children: <Widget>[
                  Icon(Icons.map),
                  SizedBox(width: 10),
                  Text('Select Location on Map'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                child: Text(AppLocalizations.of(context)!.saveEvent),
                onPressed: saveEvent,
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20.0), // Ajusta el radio según sea necesario
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
