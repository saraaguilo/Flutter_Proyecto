import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/screens/signin_screen.dart'; // acceso a currentUserEmail
import 'package:applogin/config.dart';
import 'package:applogin/models/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  String token = '';
  String passedIdUser = '';

  // categorías musicales
  final List<String> _categories = [
    'Pop',
    'Rock',
    'Rap',
    'Trap',
    'Jazz',
    'Metal'
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

    List<String> coordinatesArray =
        _eventLocationController.text.split(',').map((s) => s.trim()).toList();

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
      print('Evento guardado correctamente');
      Navigator.pop(context,
          true); // return a pantalla anterior e indica que se ha creado evento para refresh)
    } else {
      print(
          'Error al guardar el evento. Código de estado: ${response.statusCode}');
    }
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
            TextField(
              controller: _eventLocationController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.locationHint),
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
