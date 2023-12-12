import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/profile.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ProfileEditScreen> {
  String passedUsername = '';
  String passedEmail = '';
  String passedPassword = '';
  String passedIdUser = '';
  DateTime passedBirthdate = DateTime(2023, 11, 22);
  String passedDescription = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      passedUsername = prefs.getString('userName') ?? '';
      passedEmail = prefs.getString('email') ?? '';
      passedIdUser = prefs.getString('idUser') ?? '';
      String? date = prefs.getString('birthDate');
      passedBirthdate = DateTime.parse(date ?? '2023-12-08T12:34:56');
      passedPassword = prefs.getString('password') ?? '';
      passedDescription = prefs.getString('description') ?? '';

      usernameController.text = passedUsername;
      emailController.text = passedEmail;
      passwordController.text = passedPassword;
      passwordController2.text = passedPassword;
      _selectedDate = passedBirthdate;
      descriptionController.text = passedDescription;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  String? _usernameController;
  TextEditingController emailController = TextEditingController();
  String? _emailController;
  TextEditingController passwordController = TextEditingController();
  String? _passwordController;
  TextEditingController passwordController2 = TextEditingController();
  String? _passwordController2;
  DateTime _selectedDate = DateTime.now();
  TextEditingController descriptionController = TextEditingController();
  String? _descriptionController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
                      color: Colors.grey,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  onSaved: (value) {
                    setState(() {
                      _usernameController = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  onSaved: (value) {
                    setState(() {
                      _emailController = value;
                    });
                  },
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  onSaved: (value) {
                    setState(() {
                      _descriptionController = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Introduce a new password',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  onSaved: (value) {
                    setState(() {
                      _passwordController = value;
                    });
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: passwordController2,
                  decoration: InputDecoration(
                    labelText: 'Introduce your new password again',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  onSaved: (value) {
                    setState(() {
                      _passwordController2 = value;
                    });
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 30),
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
                      Text('Select your birthdate: ',
                          style: TextStyle(color: Colors.black, fontSize: 16)),
                      SizedBox(width: 15),
                      Icon(Icons.calendar_today,
                          color: Colors.black), // Set icon color to white
                      SizedBox(width: 10),
                      Text(
                        '${_selectedDate.toLocal()}'.split(' ')[0],
                        style: TextStyle(
                            color: Colors.black), // Set text color to white
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (passwordController.text
                                      .compareTo(passwordController2.text) ==
                                  0) {
                                print('Contraseñas coinciden');
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  final Map<String, String> userData = {
                                    'userName': _usernameController ?? "",
                                    'email': _emailController ?? "",
                                    'description': _descriptionController ?? "",
                                    'password': _passwordController ?? "",
                                    'birthDate': _selectedDate != null
                                        ? _selectedDate.toString()
                                        : "",
                                  };
                                  print(userData);
                                  final response = await http.put(
                                    Uri.parse('$uri/users/$passedIdUser'),
                                    body: userData,
                                  );

                                  if (response.statusCode == 201) {
                                    print('Perfil modificado con éxito.');

                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                        'userName', _usernameController ?? '');
                                    await prefs.setString(
                                        'email', _emailController ?? "");
                                    await prefs.setString(
                                        'birthDate',
                                        _selectedDate != null
                                            ? _selectedDate.toString()
                                            : "");
                                    await prefs.setString(
                                        'password', _passwordController ?? "");
                                    await prefs.setString('description',
                                        _descriptionController ?? "");

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()),
                                    );
                                  } else {
                                    print(
                                        'Error al modificar el usuario. Código de estado: ${response.statusCode}');
                                  }
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert(
                                        context,
                                        'Error',
                                        'Try introducing your password again',
                                        null);
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange,
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.orange),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
