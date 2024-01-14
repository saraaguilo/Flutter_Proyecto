import 'package:applogin/controller/navBarController.dart';
import 'package:applogin/routes.dart';
import 'package:applogin/screens/chat_home.dart';
import 'package:applogin/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:applogin/screens/buscadoreventos.dart';
import 'package:applogin/screens/buscarunevento.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/screens/signup_screen.dart';
import 'package:applogin/screens/profile.dart';
import 'package:applogin/models/user.dart';
import 'package:applogin/screens/mapa.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    //required this.navigationShell,
    super.key,
  });
  //final StatefulNavigationShell navigationShell;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //int _selectedIndex = 0;

  final List<Widget> _pages = [
    BuscadorUnEventoScreen(),
    BuscadorScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      //_selectedIndex = index;
    });
    Get.toNamed(RoutesClass.getRouteForIndex(
        index)); // Navega a la ruta correspondiente
  }

  /* void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  } */

  final controller = Get.put(NavBarController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavBarController>(builder: (context) {
      return Scaffold(
        body: IndexedStack(
          index: controller.tabIndex,
          children: const [
            BuscadorUnEventoScreen(),
            BuscadorScreen(),
            ProfileScreen()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          onTap: controller.changeTabIndex,
          iconSize: 30,
          selectedItemColor: Colors.black,
          currentIndex: controller.tabIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
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
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPrincipalScreen()),
                      );*/
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
           /* Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            ); */
          },
          tooltip: 'Show Map',
          child: Icon(Icons.map),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }


}
