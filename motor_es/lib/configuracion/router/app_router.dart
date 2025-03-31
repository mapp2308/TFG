import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/screens/acceso/login.dart';
import 'package:motor_es/screens/admin/prueba.dart';
import 'package:motor_es/screens/user/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/admin/home',
        builder: (context, state) => const HomePageAdmin(),
      ),
    ],
  );
}

