import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/profile_edit.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:applogin/utils/utilsPictures.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:applogin/models/user.dart';
import 'package:applogin/models/event.dart';
import 'package:applogin/services/user_services.dart';
import 'package:applogin/services/cloudinary_services.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:applogin/config.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key});

  @override
  State<ProfileScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ProfileScreen> {
  String token = '';
  String userName = '';
  String email = '';
  String idUser = '';
  DateTime? birthDate;
  String password = '';
  String avatar =
      'https://res.cloudinary.com/dsivbpzlp/image/upload/v1703593654/profilePics/ykj88nlthv29rkdg69dk.webp';
  List<String> createdEventsId = [];
  List<String> joinedEventsId = [];
  List<String> idCategories = [];

  List<String> selectedCategories = [];
  final List<String> _categories = [
    'Pop',
    'Rock',
    'Rap',
    'Trap',
    'Jazz',
    'Metal'
  ];

  String role = '';
  String description = '';
  List<Event> events = [];
  bool _isExpanded = false; //desplegable

  XFile? _image;
  Uint8List? _imageBytes;
  String defaultPic = "";
  Cloudinary? cloudinary;
  final uploadUrl =
      Uri.parse('https://api.cloudinary.com/v1_1/dsivbpzlp/upload');

  void initState() {
    super.initState();
    loadData();
    setState(() {});
    cloudinary = Cloudinary.signedConfig(
        apiKey: '663893452531627',
        apiSecret: '0_DJghpiMZUtH4t9AX5O-967op8',
        cloudName: 'dsivbpzlp');
  }

  Future<void> getEventsByUser(idUser) async {
    try {
      final response = await http.get(Uri.parse('$uri/events/user/$idUser'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          events = data.map((item) => Event.fromJson(item)).toList();
        });
      } else {
        print(
            'Error al cargar eventos. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      print('Error de red al cargar eventos: $error');
    }
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = prefs.getString('token') ?? '';
      userName = prefs.getString('userName') ?? '';
      email = prefs.getString('email') ?? '';
      idUser = prefs.getString('idUser') ?? '';
      String? date = prefs.getString('birthDate');
      birthDate = DateTime.parse(date ?? '2023-12-08T12:34:56');
      password = prefs.getString('password') ?? '';
      avatar = (prefs.getString('avatar') ?? '').replaceAll('"', '');
      print(avatar);
      //String? createdEventsIdString = prefs.getString('createdEventsId');
      //print(createdEventsIdString);
      //createdEventsId = (prefs.getStringList('createdEventsId') ?? []);
      //joinedEventsId = (prefs.getStringList('joinedEventsId') ?? []);
      //idCategories = (prefs.getStringList('idCategories') ?? []);
      role = prefs.getString('role') ?? '';
      description = prefs.getString('description') ?? '';
      getEventsByUser(idUser);
    });
  }

  void selectImage() async {
    XFile? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      var bytes = await img.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _image = img;
      });
    }
    uploadImage(
        cloudinary, _imageBytes, userName, email, password, idUser, token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          backgroundColor: Colors.orange,
          actions: [
            Container(
              margin: EdgeInsets.only(right: 10.0),
              child: popUpMenuButton(),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profilePicture(),
                  const SizedBox(width: 10),
                  counters(),
                ],
              ),
              const SizedBox(height: 5),
              basicInfo(),
              Expanded(child: eventsList()),
            ],
          ),
        ));
  }

  Widget basicInfo() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  email,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style:
                      TextStyle(fontSize: 14, height: 1.4, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 60),
          Container(
            padding: EdgeInsets.all(16.0),
            width: 250.0, // Establece el ancho deseado del contenedor
            child: MultiSelectDialogField(
              items: _categories
                  .map(
                      (category) => MultiSelectItem<String>(category, category))
                  .toList(),
              title: Text("Select Categories"),
              selectedColor: Colors.grey,
              selectedItemsTextStyle: const TextStyle(color: Colors.black),
              decoration: BoxDecoration(
                color: Colors.orange[200],
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                border: Border.all(
                  color: Colors.orange,
                  width: 2,
                ),
              ),
              buttonIcon: Icon(
                Icons.music_note_outlined,
                color: Colors.orange,
              ),
              buttonText: Text(
                "Select categories",
                style: TextStyle(
                  color: Colors.orange[800],
                  fontSize: 16,
                ),
              ),
              onConfirm: (results) {
                setState(() {
                  selectedCategories = results;
                });
              },
            ),
          ),
        ],
      );

  Widget eventsList() => Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color:
                    Colors.orange[200], // Utiliza un tono más claro de naranja
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(
                      20.0), // Bordes redondos en la parte superior
                ),
              ),
              width: double.infinity,
              padding: EdgeInsets.all(10.0),
              child: Text(
                "My events",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventoDetailScreen(event: events[index]),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      events[index].eventName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      events[index].description,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Coordinates: ${events[index].coordinates}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      'Date: ${events[index].date}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                              //const SizedBox(width: 10),
                              //Image.network( ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );

  Widget popUpMenuButton() => PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'logOut') {
            deletePrefs();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignInScreen()));
          } else if (value == 'deleteUser') {
            deleteUser(idUser, token);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignInScreen()));
          } else if (value == 'editProfile') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()));
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'logOut',
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log out'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'deleteUser',
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete account'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'editProfile',
            child: ListTile(
              leading: Icon(Icons.edit_attributes),
              title: Text('Edit profile'),
            ),
          ),
        ],
      );

  Widget counters() => Card(
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Container(
          height: 100,
          width: 200, // Ajusta el ancho según tus necesidades
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Events",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        events.length.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1, // Ancho del separador vertical
                  height: 70, // Altura del separador vertical
                  color: Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selectedCategories.length.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget profilePicture() => Stack(
        children: [
          _imageBytes != null
              ? CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: MemoryImage(_imageBytes!),
                )
              : CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(avatar),
                ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: () {
                print('Tocaste el ícono de edición');
                selectImage();
              },
              child: ClipOval(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(
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

  Future<void> deletePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
