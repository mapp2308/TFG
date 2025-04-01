import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatefulWidget {
  const CustomBottomNavigation({super.key});

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  final List<String> _routes = [
    '/user/home',
    '/user/settings',
  ];

  final List<IconData> _selectedIcons = [
    Icons.home,
    Icons.settings, // Cambié para que coincida mejor visualmente
  ];

  final List<IconData> _unselectedIcons = [
    Icons.home_outlined,
    Icons.settings_outlined,
  ];

  final List<String> _labels = [
    'Inicio',
    'Settings',
  ];

  int _currentIndex = 0;

  static const Color rojoEvento = Color(0xFFE53935);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final String currentLocation = GoRouter.of(context).location;
    final int index = _routes.indexOf(currentLocation);

    if (index >= 0 && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      context.go(_routes[index]);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: rojoEvento,
      unselectedItemColor: Colors.grey,
      items: List.generate(_routes.length, (index) {
        return BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == index
                ? _selectedIcons[index]
                : _unselectedIcons[index],
          ),
          label: _labels[index], // ✅ Aquí los labels personalizados
        );
      }),
    );
  }
}
