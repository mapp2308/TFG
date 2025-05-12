import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationAdmin extends StatefulWidget {
  const CustomBottomNavigationAdmin({super.key});

  @override
  State<CustomBottomNavigationAdmin> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigationAdmin> {
  final List<String> _routes = [
    '/admin/home',
    '/admin/events',
    '/admin/form',
    '/admin/settings',
  ];

  final List<IconData> _selectedIcons = [
    Icons.home,
    Icons.event,
    Icons.add,         
    Icons.settings,
  ];

  final List<IconData> _unselectedIcons = [
    Icons.home_outlined,
    Icons.event_outlined,
    Icons.add_outlined,
    Icons.settings_outlined,
  ];

  final List<String> _labels = [
    'Inicio',
    'Mis Eventos',
    'Añadir',          
    'Ajustes',
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
          label: _labels[index],
        );
      }),
    );
  }
}
