import 'package:applogin/screens/chat_home.dart';
import 'package:applogin/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:applogin/screens/buscadoreventos.dart';
import 'package:applogin/screens/buscarunevento.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/screens/signup_screen.dart';
import 'package:applogin/screens/profile.dart';
import 'package:applogin/models/user.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  final List<Widget> _pages = [
    BuscadorUnEventoScreen(),
    BuscadorScreen(),
    ProfileScreen(),
    MapScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Color.fromARGB(255, 183, 181, 181),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        selectedItemColor: Color.fromARGB(255, 255, 123, 0),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              //label: 'Search one event',
              label: AppLocalizations.of(context)!.search),
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              //label: 'Events list',
              label: AppLocalizations.of(context)!.eventsList),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              //label: 'Profile',
              label: AppLocalizations.of(context)!.profile),
          BottomNavigationBarItem(
              icon: Icon(Icons.map),
              //label: 'Map',
              label: AppLocalizations.of(context)!.map),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 3;
  }
}
