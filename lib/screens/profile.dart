import 'dart:convert';
import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/profile_edit.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:applogin/models/user.dart';
import 'package:applogin/models/event.dart';
import 'package:applogin/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:applogin/config.dart';
import 'package:http/http.dart' as http;

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

  void initState() {
    super.initState();
    loadData();
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
      avatar = prefs.getString('avatar') ?? '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.orange,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 25.0),
            child: popUpMenuButton(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                basicInfo(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 16),
              details(),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Expanded(child: eventsList()),
        ],
      ),
    );
  }

  Widget basicInfo() => Column(
        children: [
          const SizedBox(height: 10),
          ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: const Icon(Icons.person, size: 100)),
          Text(
            userName,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
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
                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
              );
            },
          ),
        ],
      );

  Widget details() => Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My details",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey),
          ),
        ],
      ));

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
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.grey[200],
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
                        child: ListTile(
                          title: Text(events[index].eventName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(events[index].description),
                              Text('Coordinates: ${events[index].coordinates}'),
                              Text('Date: ${events[index].date}'),
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
            deleteUser(idUser,token);
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
}
