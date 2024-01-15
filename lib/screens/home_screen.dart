import 'package:applogin/screens/chat_home.dart';
import 'package:applogin/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:applogin/screens/buscadoreventos.dart';
import 'package:applogin/screens/buscarunevento.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/screens/signup_screen.dart';
import 'package:applogin/models/event.dart';
import 'package:applogin/screens/profile.dart';
import 'package:applogin/models/user.dart';
import 'package:provider/provider.dart';
import 'package:applogin/reusable_/event_provider.dart';

import 'mapa.dart';

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
  late List<Event> events;
  late List<Widget> _pages;

  /* final List<Widget> _pages = [
      BuscadorUnEventoScreen(),
      BuscadorScreen(),
      ProfileScreen(),
      MapScreen(events: events),
    ];  */

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    events = Provider.of<EventProvider>(context).events;
    // Provider.of<EventProvider>(context, listen: false).getEvents();
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
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Map',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(top: 20.0),
          child: FloatingActionButton(
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 3;
    _pages = [
      BuscadorUnEventoScreen(),
      BuscadorScreen(),
      ProfileScreen(),
      MapScreen(), // Aquí es donde se inicializa con events
    ];

    checkAndLoadEvents(context);
  }

  void checkAndLoadEvents(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    eventProvider.initialized.then((bool isInitialized) {
      if (!isInitialized) {
        eventProvider.getEvents();
      } else {}
    });
  }
}
