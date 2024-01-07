import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  String? _usernameController;
  TextEditingController emailController = TextEditingController();
  String? _emailController;
  TextEditingController passwordController = TextEditingController();
  String? _passwordController;
  TextEditingController passwordController2 = TextEditingController();
  String? _passwordController2;

  int? _passwordStrength;

  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
        title:  Text(
          AppLocalizations.of(context)!.signUpTitle,
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.username,
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
                        _usernameController = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
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
                        _emailController = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
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
                        _passwordController = value;
                      });
                    },
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: passwordController2,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.passwordAgain,
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
                        _passwordController2 = value;
                      });
                    },
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(1930),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.birthdateHint,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(width: 15),
                        Icon(Icons.calendar_today,
                            color: Colors.white), // Set icon color to white
                        SizedBox(width: 10),
                        Text(
                          '${_selectedDate.toLocal()}'.split(' ')[0],
                          style: TextStyle(
                              color: Colors.white), // Set text color to white
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (passwordController.text
                                    .compareTo(passwordController2.text) ==
                                0) {
                              print('Contraseñas coinciden');
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                // Validar la fortaleza de la contraseña
                                _passwordStrength = validatePasswordStrength(
                                    passwordController.toString());

                                if (_passwordStrength == null) {
                                  // Contraseña fuerte, proceder con el registro
                                  await signUpUser();
                                } else {
                                  // Contraseña no cumple con los requisitos
                                  showErrorDialog(
                                      context, AppLocalizations.of(context)!.error, _passwordStrength.toString());
                                }
                              }
                            } else {
                              showErrorDialog(
                                  context, AppLocalizations.of(context)!.error, AppLocalizations.of(context)!.errorPass);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 255, 255, 255),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.signUp,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 102, 0),
                            ),
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

  int? validatePasswordStrength(String password) {
  if (password.length < 8) {
    showErrorToast(AppLocalizations.of(context)!.passError8char);
    return 400;
  }

  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    showErrorToast(AppLocalizations.of(context)!.passErrorCapital);
    return 400;
  }

  if (!RegExp(r'[a-z]').hasMatch(password)) {
    showErrorToast(AppLocalizations.of(context)!.passErrorLowercase);
    return 400;
  }

  if (!RegExp(r'[0-9]').hasMatch(password)) {
    showErrorToast(AppLocalizations.of(context)!.passErrorNumber);
    return 400;
  }

  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
    showErrorToast(AppLocalizations.of(context)!.passErrorSpecialChar);
    return 400;
  }

  return null;
}

  Future<void> signUpUser() async {
    final Map<String, String> userData = {
      'userName': _usernameController ?? "",
      'email': _emailController ?? "",
      'password': _passwordController ?? "",
      'birthDate': _selectedDate != null ? _selectedDate.toString() : "",
    };

    final response = await http.post(
      Uri.parse('$uri/auth/signup'),
      body: userData,
    );

    if (response.statusCode == 200) {
      print('Usuario creado con éxito.');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert(
              context,AppLocalizations.of(context)!.success, AppLocalizations.of(context)!.successRegister, SignInScreen());
        },
      );
    } else {
      print(
          'Error al crear el usuario. Código de estado: ${response.statusCode}');

      if (response.statusCode == 404) {
        showErrorDialog(context, AppLocalizations.of(context)!.error, AppLocalizations.of(context)!.emailUsed);
      } else if (response.statusCode == 405) {
        showErrorDialog(context, AppLocalizations.of(context)!.error, AppLocalizations.of(context)!.usernameUsed);
      }else if (response.statusCode == 400) {
      
      showErrorDialog(context, AppLocalizations.of(context)!.error, response.body);
      } else {
        showErrorDialog(context, AppLocalizations.of(context)!.error,
           AppLocalizations.of(context)!.unexpectedError);
      }
    }
  }
}

Future<void> showErrorDialog(
    BuildContext context, String title, String message) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.okUp),
          ),
        ],
      );
    },
  );
}
void showErrorToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
  );
}