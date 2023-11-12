import 'package:applogin/reusable_widgets/reusable_widget.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key});

  @override
  State<SignUpScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SignUpScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 30),
                reusableTextField("Enter your username", Icons.person_outline, false, usernameController),
                SizedBox(height: 30),
                reusableTextField("Enter your email", Icons.email_outlined, false, emailController),
                SizedBox(height: 30),
                reusableTextField("Enter your password", Icons.lock_outline, true, passwordController),
                SizedBox(height: 30),
                signInSignUpButton(context, false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
