import 'package:applogin/models/event.dart';
import 'package:applogin/screens/buscadoreventos.dart';
import 'package:applogin/screens/buscarunevento.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/profile.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/screens/signup_screen.dart';
import 'package:get/get.dart';

class RoutesClass {
  static getnavbar() => [navbar];
  static getEventsList() => events;
  static getSearch() => search;
  static getProfile() => profile;
  static getSignin() => signin;
  static getSignup() => signup;

  static String navbar = '/';
  static String search = '/search';
  static String events = '/events';
  static String profile = '/profile';
  static String signin = '/signin';
  static String signup = '/signup';

  static Event eventArguments = Event(
      id: '',
      coordinates: [],
      date: DateTime.now(),
      eventName: '',
      description: '');

  static final List<GetPage> routes = [
    GetPage(
      name: '/',
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/signin',
      page: () => SignInScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/signup',
      page: () => SignUpScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/profile',
      page: () => ProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/events',
      page: () => BuscadorScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/search',
      page: () => BuscadorUnEventoScreen(),
      transition: Transition.fadeIn,
    ),
  ];
/*
  static final unknownRoute = GetPage(
    name: '/unknown',
    page: () => UnknownRoutePage(),
    transition: Transition.fadeIn,
  );
  */

  static final List<GetPage> eventsPages = [
    GetPage(
      name: '/events/:eventId',
      page: () => EventoDetailScreen(eventId: eventArguments.id),
      transition: Transition.fadeIn,
    ),
  ];

  static String getRouteForIndex(int index) {
    switch (index) {
      case 0:
        return '/search';
      case 1:
        return '/events'; // Puedes ajustar esto según tus necesidades
      case 2:
        return '/profile';
      default:
        return '/unknown'; // En caso de un índice desconocido
    }
  }

  static void settingEvent(Event event) {
    eventArguments = event;
  }
}
