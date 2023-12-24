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
import 'package:flutter/material.dart';
import 'package:applogin/models/user.dart';
import 'package:applogin/models/event.dart';
import 'package:applogin/services/user_services.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:applogin/config.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
  List<String> createdEventsId = [];
  List<String> joinedEventsId = [];
  List<String> idCategories = [];
  String role = '';
  String description = '';
  List<Event> events = [];

  XFile? _image;
  Uint8List? _imageBytes;

  //late Cloudinary cloudinary;
  Cloudinary? cloudinary;
  final uploadUrl =
      Uri.parse('https://api.cloudinary.com/v1_1/dsivbpzlp/upload');
  final String apiKey = '663893452531627';
  final String apiSecret = '0_DJghpiMZUtH4t9AX5O-967op8';
  void initState() {
    super.initState();
    loadData();
    cloudinary = Cloudinary.signedConfig(
        apiKey: '663893452531627',
        apiSecret: '0_DJghpiMZUtH4t9AX5O-967op8',
        cloudName: 'dsivbpzlp');
    //cloudinary = CloudinaryObject.fromCloudName(cloudName: 'dsivbpzlp' );
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
      //avatar = prefs.getString('avatar') ?? '';
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
    //Uint8List img = await pickImage(ImageSource.gallery);
    XFile? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      var bytes = await img.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _image = img;
      });
    }
    _uploadImage();
  }

  /* Future<void> _uploadImage() async {
    try {
      var stream = http.ByteStream.fromBytes(_imageBytes!);
      var length = await _imageBytes!.length;

      var request = http.MultipartRequest(
          'POST', uploadUrl)
        ..fields['upload_preset'] = 'ml_default'
        ..headers['Authorization'] = 'Basic ' +
            base64Encode(utf8.encode('$apiKey:$apiSecret'))
        ..files.add(http.MultipartFile('file', stream, length,
            filename: 'uploaded_file.jpg'));

      var response = await request.send();
      if (response.statusCode == 200) {
        // Handle successful upload
        print('Image uploaded successfully!');
      } else {
        // Handle failed upload
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  } */

  Future<void> _uploadImage() async {
    try {
      CloudinaryResponse response;

      if (_image != null) {
        response = await cloudinary!.upload(
          fileBytes: _imageBytes,
          resourceType: CloudinaryResourceType.image,
          folder: 'profilePics',
        );
        if (response.isSuccessful) {
          print('Get your image from with ${response.secureUrl}');
        } else {
          print('No se ha subido bien');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 50),
              profilePicture(),
              SizedBox(width: 10),
              counters(),
            ],
          ),
          const SizedBox(height: 20),
          basicInfo(),
          const SizedBox(height: 10),
          //tabBar(),
          Expanded(child: eventsList()),
        ],
      ),
    );
  }

  Widget basicInfo() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0), // Margen a la izquierda
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
                  ],
                ),
              ),
              const SizedBox(width: 80),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Edit Profile',
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileEditScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20.0), // Margen a la izquierda
            child: Text(
              description,
              style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey),
            ),
          ),
        ],
      );

  Widget eventsList() => Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My events",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
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
                              const SizedBox(width: 10), // Espaciador
                              // Foto a la derecha
                              Image.network(
                                avatar,
                                width:
                                    100, // Ajusta el ancho según tus necesidades
                                height:
                                    100, // Ajusta la altura según tus necesidades
                                fit: BoxFit.cover,
                              ),
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignInScreen()));
          } else if (value == 'deleteUser') {
            deleteUser(idUser, token);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignInScreen()));
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
        ],
      );

  Widget counters() => Card(
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Container(
          width: 230, // Ajusta el ancho según tus necesidades
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
                        '3',
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
                        '4',
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
                  radius: 70,
                  backgroundColor: Colors.white,
                  backgroundImage: MemoryImage(_imageBytes!),
                )
              : CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(avatar),
                ),
          /*CldImageWidget(
                  cloudinary: cloudinary,
                  publicId: "cld-sample",
                  width: 150,
                  height: 150,
                ),*/
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

  Widget tabBar() => Column(
        children: [
          TabBar(tabs: [
            Tab(
              icon: Icon(Icons.event, color: Colors.orange),
            ),
            Tab(
              icon: Icon(Icons.list, color: Colors.orange),
            )
          ]),
          //TabBarView(children: [Expanded(child: eventsList()), categories()])
        ],
      );

  Widget categories() => Container();
}
