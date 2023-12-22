import 'package:applogin/models/event.dart';
import 'package:applogin/screens/buscadoreventos.dart';
import 'package:applogin/screens/buscarunevento.dart';
import 'package:applogin/screens/crearevento.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/profile.dart';
import 'package:applogin/screens/profile_edit.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/screens/signup_screen.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigation {
  AppNavigation._();

  static String initial = "/signin";

  // Private navigators
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorSearch =
      GlobalKey<NavigatorState>(debugLabel: 'shellSearch');
  static final _shellNavigatorEvents =
      GlobalKey<NavigatorState>(debugLabel: 'shellEvents');
  static final _shellNavigatorProfile =
      GlobalKey<NavigatorState>(debugLabel: 'shellProfile');
  static final _shellNavigatorSignIn =
      GlobalKey<NavigatorState>(debugLabel: 'shellSignIn');
  static final _shellNavigatorSignUp =
      GlobalKey<NavigatorState>(debugLabel: 'shellSignUp');

  static Event eventArguments = Event(
      id: '',
      coordinates: [],
      date: DateTime.now(),
      eventName: '',
      description: '');

  AppNavigation({Event? initialEvent}) {
    Event eventArguments = initialEvent ??
        Event(
            id: '',
            coordinates: [],
            date: DateTime.now(),
            eventName: '',
            description: '');
  }
  static bool result = true; //lista modificada

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: initial,
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    routes: [
      /// MainWrapper
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeScreen(
            navigationShell: navigationShell,
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearch,
            routes: <RouteBase>[
              GoRoute(
                path: "/search",
                name: "Search",
                builder: (BuildContext context, GoRouterState state) =>
                    const BuscadorUnEventoScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorEvents,
            routes: <RouteBase>[
              GoRoute(
                path: "/events",
                name: "Events",
                builder: (BuildContext context, GoRouterState state) =>
                    const BuscadorScreen(),
                routes: [
                  //rutes dins del mapa o de la llista d'events
                  GoRoute(
                    path: 'create',
                    name: 'Create',
                    builder: (context, state) {
                      return CrearEventoScreen();
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'Details',
                    builder: (context, state) {
                      return EventoDetailScreen(event: eventArguments);
                    },
                  ), 
                  
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: <RouteBase>[
              GoRoute(
                path: "/profile",
                name: "Profile",
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: "edit",
                    name: "Edit",
                    pageBuilder: (context, state) {
                      return CustomTransitionPage<void>(
                        key: state.pageKey,
                        child: const ProfileEditScreen(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) =>
                            FadeTransition(opacity: animation, child: child),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/signin',
        name: "SignIn",
        builder: (context, state) => SignInScreen(
          key: state.pageKey,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/signup',
        name: "SignUp",
        builder: (context, state) => SignUpScreen(
          key: state.pageKey,
        ),
      )
    ],
  );
}
