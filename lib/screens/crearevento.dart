import 'dart:convert';
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
import 'package:applogin/services/user_services.dart';
import 'package:applogin/services/cloudinary_services.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/services.dart';

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
  XFile? _eventImage;
  Uint8List? _imageBytes;
  Cloudinary? cloudinary;

  final List<String> _categories = [
    'Pop',
    'Rock',
    'Rap',
    'Trap',
    'Jazz',
    'Metal',
    'Flamenco'
  ];

  void initState() {
    super.initState();
    loadData();
    setState(() {});
    cloudinary = Cloudinary.signedConfig(
        apiKey: '663893452531627',
        apiSecret: '0_DJghpiMZUtH4t9AX5O-967op8',
        cloudName: 'dsivbpzlp');
  }

  void selectImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      var bytes = await img.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _eventImage = img;
      });
    }
  }

  Widget eventImageWidget() => Stack(
        children: [
          _imageBytes != null
              ? CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: MemoryImage(_imageBytes!),
                )
              : const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('images/default.png'),
                ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: selectImage,
              child: ClipOval(
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.orange,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          )
        ],
      );

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? '';
      passedIdUser = prefs.getString('idUser') ?? '';
    });
  }

  Future<void> saveEvent() async {
    var idUser = passedIdUser;
    if (idUser == null || cloudinary == null) {
      print('Datos faltantes');
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
    try {
      String? imageUrl;

      if (_imageBytes != null) {
        imageUrl = await uploadImageEvents(cloudinary!, _imageBytes!, token);
      } else {
        ByteData data = await rootBundle.load('images/default.png');
        List<int> defaultImageBytes = data.buffer.asUint8List();
        imageUrl = await uploadImageEvents(
            cloudinary!, Uint8List.fromList(defaultImageBytes), token);
      }

      List<String> coordinatesArray = _eventLocationController.text
          .split(',')
          .map((s) => s.trim())
          .toList();

      if (imageUrl != null) {
        var eventResponse = await http.post(
          Uri.parse('$uri/events'),
          headers: {
            'Content-Type': 'application/json',
            'x-access-token': token
          },
          body: json.encode({
            'eventName': _eventNameController.text,
            'description': _eventDescriptionController.text,
            'coordinates': coordinatesArray,
            'date': _selectedDate.toIso8601String(),
            'idUser': idUser,
            'photo': imageUrl, // Agrega la URL de la imagen aquí
          }),
        );

        if (eventResponse.statusCode == 201) {
          print('Evento guardado correctamente');
          Navigator.pop(context, true);
        } else {
          print('Error al guardar evento: ${eventResponse.statusCode}');
        }
      } else {
        print('Error al obtener la URL de la imagen');
      }
    } catch (e) {
      print('Error al subir imagen o guardar evento: $e');
    }
  }

  Future<LatLng?> goToMapScreen() async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen(creatingEvent: true)),
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
            SizedBox(height: 10),
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
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 10),
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
            eventImageWidget(),
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                child: Text(AppLocalizations.of(context)!.saveEvent),
                onPressed: saveEvent,
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
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
