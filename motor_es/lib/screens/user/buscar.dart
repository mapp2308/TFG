import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:motor_es/widgets/user/custom_buttom_navigation.dart';
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
  DateTime? startDate;
  DateTime? endDate;

  List<String> selectedEventTypes = [];
  List<String> selectedCities = [];
  List<String> availableCities = [];

  List<DocumentSnapshot> filteredEvents = [];

  final vehicleTypes = [
    {'label': 'Coche', 'value': 'coche'},
    {'label': 'Moto', 'value': 'moto'},
  ];

  final eventTypes = [
    {'label': 'Exposición', 'value': 'Exposición'},
    {'label': 'Curso', 'value': 'Curso'},
    {'label': 'Carrera', 'value': 'Carrera'},
    {'label': 'Rally', 'value': 'Rally'},
    {'label': 'Exhibición', 'value': 'Exhibición'},
    {'label': 'Juntada', 'value': 'Juntada'},
    {'label': 'Ruta', 'value': 'Ruta'},
    {'label': 'Mixto', 'value': 'mixto'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAdmins();
    _loadCities();
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

  Future<void> _loadCities() async {
    final snapshot = await FirebaseFirestore.instance.collection('eventos').get();

    final cities = snapshot.docs
        .map((doc) => doc['ciudad']?.toString())
        .where((city) => city != null && city.isNotEmpty)
        .toSet()
        .toList();

    setState(() {
      availableCities = cities.cast<String>();
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

    if (selectedEventTypes.isNotEmpty) {
      query = query.where('tipo', whereIn: selectedEventTypes);
    }

    if (selectedCities.isNotEmpty) {
      query = query.where('ciudad', whereIn: selectedCities);
    }

    final Timestamp now = Timestamp.now();

    if (startDate != null && endDate != null) {
      query = query
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate!.isBefore(DateTime.now()) ? DateTime.now() : startDate!))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate!));
    } else {
      query = query.where('fecha', isGreaterThanOrEqualTo: now);
    }

    query = query.orderBy('fecha', descending: false);

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: isDarkMode
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    surface: Colors.grey,
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
          child: child!,
        );
      },
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filtrar',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, _) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    elevation: 10,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              onChanged: (value) {
                                setState(() => selectedAdminUid = value);
                                setModalState(() {});
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildDropdown(
                              label: 'Tipo de vehículo',
                              value: selectedVehicleType,
                              options: vehicleTypes,
                              onChanged: (value) {
                                setState(() => selectedVehicleType = value);
                                setModalState(() {});
                              },
                            ),
                            const SizedBox(height: 12),

                            // Tipo de evento
                            _buildMultiSelectTile(
                              title: 'Tipo de evento',
                              options: eventTypes.map((e) => e['value']!).toList(),
                              labels: eventTypes.map((e) => e['label']!).toList(),
                              selectedValues: selectedEventTypes,
                              onChanged: (value) {
                                setState(() {
                                  if (selectedEventTypes.contains(value)) {
                                    selectedEventTypes.remove(value);
                                  } else {
                                    selectedEventTypes.add(value);
                                  }
                                });
                                setModalState(() {});
                              },
                            ),
                            const SizedBox(height: 12),

                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                                  childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  title: const Text('Ciudad'),
                                  trailing: const Icon(Icons.arrow_drop_down),
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: availableCities.map((city) {
                                        final isSelected = selectedCities.contains(city);
                                        return FilterChip(
                                          label: Text(city),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            setState(() {
                                              if (selected) {
                                                selectedCities.add(city);
                                              } else {
                                                selectedCities.remove(city);
                                              }
                                            });
                                            // Forzar reconstrucción del modal para que se vea reflejado de inmediato
                                            (context as Element).markNeedsBuild();
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            TextButton.icon(
                              onPressed: _pickDateRange,
                              icon: const Icon(Icons.date_range, color: rojo),
                              label: Text(dateRangeText, style: const TextStyle(color: rojo)),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _filterEvents();
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.search, color: Colors.white),
                                  label: const Text("Aplicar filtros", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      selectedAdminUid = null;
                                      selectedVehicleType = null;
                                      selectedEventTypes.clear();
                                      selectedCities.clear();
                                      startDate = null;
                                      endDate = null;
                                    });
                                    _filterEvents();
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.clear, color: Colors.white),
                                  label: const Text("Limpiar filtros", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: rojo,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
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

  Widget _buildMultiSelectTile({
    required String title,
    required List<String> options,
    required List<String> labels,
    required List<String> selectedValues,
    required void Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          title: Text(title),
          trailing: const Icon(Icons.arrow_drop_down),
          children: List.generate(options.length, (index) {
            final value = options[index];
            final label = labels[index];
            final isSelected = selectedValues.contains(value);
            return CheckboxListTile(
              title: Text(label),
              value: isSelected,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (_) => onChanged(value),
            );
          }),
        ),
      ),
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
                backgroundColor: rojo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
