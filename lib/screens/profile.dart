import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key});

  @override
  State<ProfileScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ProfileScreen> {
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
            "Username del usuario",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            "email del usuario",
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
            "User's biography",
            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey),
          ),
        ],
      ));
}
