import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/buscadoreventos.dart';
import 'package:applogin/screens/buscarunevento.dart';
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
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                ),
                child: Text("Search one event"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BuscadorUnEventoScreen()));
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange, // Cambia el color a naranja
                ),
                child: Text("Show all events"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BuscadorScreen()));
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange, // Cambia el color a naranja
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