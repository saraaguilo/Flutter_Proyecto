import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:applogin/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ProfileScreen> {
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

  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.orange,
        //Eliminar message debug
        //Afegir els tres puntets amb: edit profile, log out, delete user (amb confirmació i en vermell)
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50),
          //Profile picture
          Icon(Icons.person, size: 72),
          const SizedBox(height: 10),
          //Username and email
          basicInfo(),
          const SizedBox(height: 20),
          //My details
          details(),
          const SizedBox(height: 10),
          //User's events list
        ],
      ),
    );
  }

  Widget basicInfo() => Column(
        children: [
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
          )
        ],
      );

  Widget details() => Container(
      padding: const EdgeInsets.only(left: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My details",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey),
          ),
        ],
      ));
}
