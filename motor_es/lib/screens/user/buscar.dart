import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:motor_es/widgets/custom_buttom_navigation.dart';
import 'package:motor_es/widgets/widget_evento.dart';

const Color rojo = Color(0xFFE53935);

class EventFilterScreen extends StatefulWidget {
  const EventFilterScreen({super.key});

  @override
  State<EventFilterScreen> createState() => _EventFilterScreenState();
}

class _EventFilterScreenState extends State<EventFilterScreen> {
  List<Map<String, String>> adminUsers = [];
  String? selectedAdminUid;
  String? selectedVehicleType;
  String? selectedEventType;
  DateTime? startDate;
  DateTime? endDate;

  List<DocumentSnapshot> filteredEvents = [];

  final vehicleTypes = [
    {'label': 'Coche', 'value': 'coche'},
    {'label': 'Moto', 'value': 'moto'},
  ];

  final eventTypes = [
    {'label': 'Exposición', 'value': 'exposicion'},
    {'label': 'Curso', 'value': 'curso'},
    {'label': 'Carrera', 'value': 'carrera'},
    {'label': 'Rally', 'value': 'rally'},
    {'label': 'Exhibición', 'value': 'exhibicion'},
    {'label': 'Juntada', 'value': 'juntada'},
    {'label': 'Ruta', 'value': 'ruta'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAdmins();
    _filterEvents();
  }

  Future<void> _loadAdmins() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('isAdmin', isEqualTo: true)
        .get();

    setState(() {
      adminUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'nombre': (data['nombreUsuario'] ?? data['nombre'] ?? data['email'] ?? 'Admin sin nombre').toString(),
        };
      }).toList();
    });
  }

  Future<void> _filterEvents() async {
    CollectionReference eventosRef = FirebaseFirestore.instance.collection('eventos');
    Query<Map<String, dynamic>> query = eventosRef as Query<Map<String, dynamic>>;

    if (selectedAdminUid != null && selectedAdminUid!.isNotEmpty) {
      query = query.where('creadoPor', isEqualTo: selectedAdminUid);
    }

    if (selectedVehicleType != null && selectedVehicleType!.isNotEmpty) {
      query = query.where('vehiculo', isEqualTo: selectedVehicleType);
    }

    if (selectedEventType != null && selectedEventType!.isNotEmpty) {
      query = query.where('tipo', isEqualTo: selectedEventType);
    }

    bool aplicarRangoFecha = startDate != null && endDate != null;

    if (aplicarRangoFecha) {
      query = query
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate!))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate!))
          .orderBy('fecha');
    }

    try {
      final snapshot = await query.get();
      setState(() {
        filteredEvents = snapshot.docs;
      });
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Falta un índice para esta combinación de filtros. Revísalo en Firebase."),
            backgroundColor: rojo,
          ),
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void _openFilterModal() {
    final dateRangeText = (startDate != null && endDate != null)
        ? '${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}'
        : 'Selecciona un rango de fechas';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDropdown(
                  label: 'Creado por (admin)',
                  value: selectedAdminUid,
                  options: adminUsers.map((admin) {
                    return {
                      'label': admin['nombre'] ?? 'Admin sin nombre',
                      'value': admin['uid']!,
                    };
                  }).toList(),
                  onChanged: (value) => setState(() => selectedAdminUid = value),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: 'Tipo de vehículo',
                  value: selectedVehicleType,
                  options: vehicleTypes,
                  onChanged: (value) => setState(() => selectedVehicleType = value),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: 'Tipo de evento',
                  value: selectedEventType,
                  options: eventTypes,
                  onChanged: (value) => setState(() => selectedEventType = value),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range, color: rojo),
                  label: Text(dateRangeText, style: const TextStyle(color: rojo)),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    _filterEvents();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Aplicar filtros"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedAdminUid = null;
                      selectedVehicleType = null;
                      selectedEventType = null;
                      startDate = null;
                      endDate = null;
                    });
                    _filterEvents();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text("Limpiar filtros"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rojo,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<Map<String, String>> options,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      value: value,
      items: options.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(item['label']!),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Buscar Eventos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            TextButton.icon(
              onPressed: _openFilterModal,
              icon: const Icon(Icons.filter_alt, color: Colors.white),
              label: const Text("Filtrar", style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: rojo,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
                    child: Text(
                      'No hay eventos que coincidan con los filtros.',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      return EventoCard(evento: filteredEvents[index]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
