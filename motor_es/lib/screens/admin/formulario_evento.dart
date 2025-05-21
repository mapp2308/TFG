import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/widgets/widgets.dart';


class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  GeoPoint? _geoPoint;

  String? _selectedType;
  String? _selectedVehicle;

  final List<String> _eventTypes = ['Rally', 'Exposición', 'Drift', 'Circuito', 'Clásicos', 'Mixto'];
  final List<String> _vehicleTypes = ['coche', 'moto'];

  bool _validating = false;

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  Future<bool> _getGeoPointFromAddress(String location, String city) async {
    final query = '$location, $city';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=AIzaSyD08IKjkvYqAgjTcT_u6HBqrzRVjEn18eY';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final latLng = data['results'][0]['geometry']['location'];
      _geoPoint = GeoPoint(latLng['lat'], latLng['lng']);
      return true;
    }

    _geoPoint = null;
    return false;
  }

  Future<void> _submit() async {
    setState(() => _validating = true);

    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedType == null ||
        _selectedVehicle == null) {
      _showErrorDialog('Completa todos los campos, incluyendo tipo y vehículo.');
      setState(() => _validating = false);
      return;
    }

    final validLocation = await _getGeoPointFromAddress(
      _locationController.text.trim(),
      _cityController.text.trim(),
    );

    if (!validLocation || _geoPoint == null) {
      _showErrorDialog('Dirección inválida. Asegúrate de escribir una ubicación real.');
      setState(() => _validating = false);
      return;
    }

    final fecha = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showErrorDialog('Usuario no autenticado.');
      setState(() => _validating = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('eventos').add({
        'creadoPor': user.uid,
        'nombre': _nameController.text.trim(),
        'descripcion': _descController.text.trim(),
        'fecha': Timestamp.fromDate(fecha),
        'tipo': _selectedType,
        'vehiculo': _selectedVehicle,
        'ciudad': _cityController.text.trim(),
        'ubicacion': _geoPoint!,
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Error al guardar el evento: $e');
    } finally {
      setState(() => _validating = false);
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Evento guardado!'),
        content: const Text('Se ha creado correctamente el evento.'),
        actions: [
          TextButton(
            onPressed: () => context.go('/admin/home'),
            child: const Text('Ir al inicio'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _formKey.currentState?.reset();
              _nameController.clear();
              _descController.clear();
              _locationController.clear();
              _cityController.clear();
              setState(() {
                _selectedDate = null;
                _selectedTime = null;
                _geoPoint = null;
                _selectedType = null;
                _selectedVehicle = null;
              });
            },
            child: const Text('Crear otro'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            
            children: [
              const SizedBox(height: 50),
              const Text(
                "Crear Eventos",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),

              _buildTextField(_nameController, 'Nombre del evento', true),
              _buildTextField(_descController, 'Descripción', false, maxLines: 3),
              _buildTextField(_locationController, 'Lugar (para geolocalizar)', true),
              _buildTextField(_cityController, 'Ciudad', true),
              _buildDropdown(
                value: _selectedType,
                label: 'Tipo de evento',
                items: _eventTypes.map((e) => e.toLowerCase()).toList(),
                onChanged: (val) => setState(() => _selectedType = val),
              ),
              _buildDropdown(
                value: _selectedVehicle,
                label: 'Vehículo',
                items: _vehicleTypes,
                onChanged: (val) => setState(() => _selectedVehicle = val),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Seleccionar fecha y hora'
                      : DateFormat('dd/MM/yyyy HH:mm').format(
                          DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _selectedTime?.hour ?? 0,
                            _selectedTime?.minute ?? 0,
                          ),
                        ),
                  style: TextStyle(color: Colors.white)
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDateTime,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _validating ? null : _submit,
                label: _validating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar evento'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationAdmin(),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isRequired, {
    int maxLines = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Campo requerido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(color: colorScheme.onSurface)),
                ))
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
        validator: (val) => val == null ? 'Campo requerido' : null,
      ),
    );
  }
}
