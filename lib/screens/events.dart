import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:flutter/material.dart';


class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key});

  @override
  State<EventsScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<EventsScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("FFB74D"), // Naranja claro
              hexStringToColor("FF9800"), // Naranja medio
              hexStringToColor("E65100"), // Naranja oscuro
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              logoWidget("images/music.jpg"),
              SizedBox(height: 50),
              reusableTextField("SEARCH FOR EVENTS", Icons.person_outline, false, usernameController),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(179, 254, 254, 254), // Cambia el color a gris
                ),
                child: Text("Logout"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}