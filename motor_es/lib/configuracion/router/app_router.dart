import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/screens/screens.dart';


Future<GoRouter> createAppRouter() async {
  final user = FirebaseAuth.instance.currentUser;

  String initialPath = '/login';

  if (user != null) {
    final userDoc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
    final isAdmin = userDoc.data()?['isAdmin'] == true;

    initialPath = isAdmin ? '/admin/home' : '/user/home';
  }

  return GoRouter(
    initialLocation: initialPath,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/user/home',
        builder: (context, state) => const PantallaPrincipal(),
      ),
      GoRoute(
        path: '/user/events',
        builder: (context, state) => const EventosScreen(),
      ),
      GoRoute(
        path: '/user/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/user/search',
        builder: (context, state) => const EventFilterScreen(),
      ),
      GoRoute(
        path: '/user/events',
        name: EventosScreen.name,
        builder: (context, state) => const EventosScreen(),
      ),
      GoRoute(
        path: '/user/maps',
        builder: (context, state) => const EventMapScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const SettingsScreenAdmin(),
      ),
      GoRoute(
        path: '/admin/home',
        builder: (context, state) => const PantallaPrincipalAdmin(),
      ),
      GoRoute(
        path: '/admin/event',
        builder: (context, state) {
          final evento = state.extra as DocumentSnapshot;
          return DetalleEventoAdminScreen(evento: evento);
        },
      ),
      GoRoute(
        path: '/admin/edit',
        builder: (context, state) {
          final evento = state.extra as DocumentSnapshot;
          return EditarEventoScreen(evento: evento);
        },
      ),
      GoRoute(
        path: '/admin/events',
        builder: (context, state) => const MisEventosCreadosScreen(),
      ),
      GoRoute(
        path: '/admin/form',
        builder: (context, state) => const AddEventScreen(),
      ),
    ],
  );
}

