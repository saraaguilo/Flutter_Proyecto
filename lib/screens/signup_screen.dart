import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key});
  
  @override
  State<SignUpScreen> createState() => _MyWidgetState();
}
final List<Widget> _pages = [
    SignInScreen(),
    
  ];

class _MyWidgetState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  String? _usernameController;
  TextEditingController emailController = TextEditingController();
  String? _emailController;
  TextEditingController passwordController = TextEditingController();
  String? _passwordController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "SIGN UP",
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
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 30),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),

                      ),
                    ),
                    onSaved: (value) {
                      setState(() {
                        _usernameController = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),

                      ),
                    ),
                    onSaved: (value) {
                      setState(() {
                        _emailController = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),

                      ),
                    ),
                    onSaved: (value) {
                      setState(() {
                        _passwordController = value;
                      });
                    },
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              final Map<String, String> userData = {
                                'userName': _usernameController ?? "",
                                'email': _emailController ?? "",
                                'password': _passwordController ?? "",
                              };

                              final response = await http.post(
                                Uri.parse('http://localhost:9090/auth/signup'),
                                body: userData,
                              );

                              if (response.statusCode == 200) {
                                print('Usuario creado con éxito.');

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Éxito'),
                                      content: Text('Usuario creado con éxito'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Aceptar'),
                                          onPressed: () {
                                            // Cierra el diálogo
                                            Navigator.of(context).pop();
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                print('Error al crear el usuario. Código de estado: ${response.statusCode}');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 255, 255, 255),
                          ),
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
