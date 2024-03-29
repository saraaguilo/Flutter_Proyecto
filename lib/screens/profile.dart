import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:applogin/models/language.dart';
import 'package:applogin/models/language_constants.dart';
import 'package:applogin/main.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:applogin/screens/profile_edit.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/utils/utilsPictures.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:applogin/models/event.dart';
import 'package:applogin/services/user_services.dart';
import 'package:applogin/services/cloudinary_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:applogin/config.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  String avatar = '';
  List<String> createdEventsId = [];
  List<String> joinedEventsId = [];
  List<String> idCategories = [];
  String role = '';
  String description = '';
  List<Event> events = [];
  //image web
  XFile? _image;
  Uint8List? _imageBytes;
  //image android
  File? _imageAndroid;
  final ImagePicker picker = ImagePicker();

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

    //Cloudinary grupo
    //cloudinary = Cloudinary.signedConfig(
    //  apiKey: '851147581669956',
    //  apiSecret: '_9JS7cS5HQTMYbTiB0jTAvDIkBQ',
    //  cloudName: 'dkmpuejix');
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
      //String? createdEventsIdString = prefs.getString('createdEventsId');
      //print(createdEventsIdString);
      //createdEventsId = (prefs.getStringList('createdEventsId') ?? []);
      //joinedEventsId = (prefs.getStringList('joinedEventsId') ?? []);
      idCategories = (prefs.getStringList('idCategories') ?? []);
      role = prefs.getString('role') ?? '';
      description = prefs.getString('description') ?? '';
      getEventsByUser(idUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          backgroundColor: Colors.orange,
          actions: [
            DropdownButton<Language>(
              underline: const SizedBox(),
              icon: const Icon(
                Icons.language,
                color: Colors.black,
              ),
              onChanged: (Language? language) async {
                if (language != null) {
                  Locale _locale = await setLocale(language.languageCode);
                  MyApp.setLocale(context, _locale);
                }
              },
              items: Language.languageList()
                  .map<DropdownMenuItem<Language>>(
                    (e) => DropdownMenuItem<Language>(
                      value: e,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[Text(e.name)],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(
              width: 20,
            ),
            Container(
              margin: EdgeInsets.only(right: 5.0), // Reducir el margen aquí
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

  Widget basicInfo() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    userName,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    description,
                    style: const TextStyle(
                        fontSize: 14, height: 1.4, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 0),
          Container(
            width: 215.0, // Establece el ancho deseado del contenedor
            child: MultiSelectDialogField(
              items: _categories
                  .map(
                      (category) => MultiSelectItem<String>(category, category))
                  .toList(),
              title: Text(AppLocalizations.of(context)!.selectCategories),
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
                AppLocalizations.of(context)!.selectCategories,
                style: TextStyle(
                  color: Colors.orange[800],
                  fontSize: 14,
                ),
              ),
              initialValue: idCategories,
              onConfirm: (results) {
                // Asegúrate de que results sea una lista de String
                List<String> selectedCategories = results.cast<String>();

                setState(() {
                  idCategories = selectedCategories;
                  updateCategories();
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
                AppLocalizations.of(context)!.myEvents,
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
                                      '${AppLocalizations.of(context)!.coordinates}: ${events[index].coordinates}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      '${AppLocalizations.of(context)!.date}: ${events[index].date}',
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
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.deleteAccount,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.deleteAccountHint,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 10.0,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteUser(idUser, token);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.delete,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else if (value == 'editProfile') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()));
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'editProfile',
            child: ListTile(
              leading: Icon(Icons.edit_attributes),
              title: Text(AppLocalizations.of(context)!.editProfile),
            ),
          ),
          PopupMenuItem<String>(
            value: 'logOut',
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text(AppLocalizations.of(context)!.logOut),
            ),
          ),
          PopupMenuItem<String>(
            value: 'deleteUser',
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text(
                AppLocalizations.of(context)!.deleteAccount,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
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
                        AppLocalizations.of(context)!.events,
                        style: TextStyle(
                          fontSize: 14,
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
                        AppLocalizations.of(context)!.categories,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        idCategories.length.toString(),
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

  void selectImage() async {
    if (kIsWeb) {
      print('estas en web');
      XFile? img = await pickImage(ImageSource.gallery);

      if (img != null) {
        var bytes = await img.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _image = img;
        });
        uploadImage(cloudinary, _imageBytes, userName,
            email, password, idUser, token);
      }
    } else {
      print('NO estas en web');
      XFile? img = await picker.pickImage(source: ImageSource.gallery);
      if (img != null) {
        var pickedFile = File(img.path);
        setState(() {
          _imageAndroid = pickedFile;
        });
        //controlar si no ha triat foto
        uploadImageAndroid(cloudinary, _imageAndroid!.path, userName,
            email, password, idUser, token);
      }
    }
  }

  Widget profilePicture() => Stack(
        children: [
          _imageBytes == null && _imageAndroid == null
              ? CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(avatar),
                )
              : kIsWeb
                  ? CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: MemoryImage(_imageBytes!),
                    )
                  : CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: FileImage(_imageAndroid!),
                    ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: () {
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

  Future<void> updateCategories() async {
    String idCategoriesJson = jsonEncode(idCategories);

    final Map<String, dynamic> userData = {
      'userName': userName,
      'email': email,
      'password': password,
      'idCategories': idCategoriesJson
    };

    final response = await http.put(
      Uri.parse('$uri/users/$idUser'),
      headers: {'x-access-token': token},
      body: (userData),
    );

    if (response.statusCode == 201) {
      print('Perfil modificado con éxito.');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('idCategories', idCategories);
    } else {
      print(
          'Error al modificar el usuario. Código de estado: ${response.statusCode}');
    }
  }

  Future<void> deletePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}