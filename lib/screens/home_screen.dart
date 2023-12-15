import 'package:applogin/router.dart';
import 'package:applogin/screens/chat_home.dart';
import 'package:applogin/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:applogin/screens/events.dart';
import 'package:applogin/screens/buscadoreventos.dart';
import 'package:applogin/screens/buscarunevento.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/screens/signup_screen.dart';

import 'package:applogin/screens/profile.dart';
import 'package:applogin/models/user.dart';

import 'package:applogin/screens/mapa.dart';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    BuscadorUnEventoScreen(),
    BuscadorScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Color.fromARGB(255, 183, 181, 181),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          selectedItemColor: Color.fromARGB(255, 255, 123, 0),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search one event',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Events list',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        persistentFooterButtons: [
          Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Do you want to join an event chat?',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPrincipalScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange, // Cambia a tu color deseado
                    ),
                    child: Text('Join Chat'),
                  ),
                ],
              ),
            ),
          ),
        ],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          },
          tooltip: 'Show Map',
          child: Icon(Icons.map),
          backgroundColor: Colors.orange,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 2;
  }
}
