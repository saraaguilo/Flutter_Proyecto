import 'dart:convert';
import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/events.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/screens/signup_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:applogin/config.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late final User userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "LOG IN",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: gradientBackground(),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 30),
                  logoWidget("images/logoOrange.png"),
                  SizedBox(height: 20, width: double.infinity),
                  //EMAIL TEXT FIELD
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    onSaved: (value) {
                      setState(() {
                        // Guarda el valor en una variable cuando el formulario se guarda
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  //PASSWORD TEXT FIELD
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    onSaved: (value) {
                      setState(() {
                        // Guarda el valor en una variable cuando el formulario se guarda
                      });
                    },
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  signInButton(),
                  SizedBox(height: 20),
                  signUpOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton signInButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          final Map<String, String> userData = {
            'email': emailController.text,
            'password': passwordController.text,
          };

          //PETICIÓN HTTP
          final response = await http.post(
            Uri.parse('$uri/auth/signin'),
            body: userData,
          );

          if (response.statusCode == 200) {
            final Map<dynamic, dynamic> jsonResponse =
                json.decode(response.body);
            final bool auth = jsonResponse['auth'];
            final String token = jsonResponse['token'];
            // Ahora puedes extraer el usuario del cuerpo de la respuesta
            final Map<String, dynamic> userJson = jsonResponse['user'];
            final User user = User.fromJson(userJson);

            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setString('userName', user.userName);
            await prefs.setString('email', user.email);
            await prefs.setString('idUser', user.idUser ?? '');
            await prefs.setString(
                'birthDate', user.birthDate?.toString() ?? '');
            await prefs.setString('password', user.password);
            await prefs.setString('avatar', jsonEncode(user.avatar));
            await prefs.setString(
                'createdEventsId', jsonEncode(user.createdEventsId));
            await prefs.setString(
                'joinedEventsId', jsonEncode(user.joinedEventsId));
            await prefs.setString(
                'idCategories', jsonEncode(user.idCategories));
            await prefs.setString('role', jsonEncode(user.role));
            await prefs.setString('description', jsonEncode(user.description));

            print('Usuario loggeado con éxito.');

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            print(
                'Error al loggear el usuario. Código de estado: ${response.statusCode}');
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert(context, 'Error',
                    'Incorrect email or password, please try again', null);
              },
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 255, 255, 255),
      ),
      child: Text(
        'LOG IN',
        style: TextStyle(color: Color.fromARGB(255, 255, 102, 0)),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
