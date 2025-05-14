import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color rojo = Color(0xFFE53935);

class EditarEventoScreen extends StatefulWidget {
  final DocumentSnapshot evento;

  const EditarEventoScreen({super.key, required this.evento});

  @override
  State<EditarEventoScreen> createState() => _EditarEventoScreenState();
}

class _EditarEventoScreenState extends State<EditarEventoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _ciudadController;

  String? _vehiculo;
  String? _tipo;
  DateTime? _fecha;

  final List<Map<String, String>> tipos = [
    {"label": "Exposición", "value": "exposicion"},
    {"label": "Curso", "value": "curso"},
    {"label": "Carrera", "value": "carrera"},
    {"label": "Rally", "value": "rally"},
    {"label": "Exhibición", "value": "exhibicion"},
    {"label": "Juntada", "value": "juntada"},
    {"label": "Ruta", "value": "ruta"},
    {"label": "Mixto", "value": "mixto"},
  ];

  final List<Map<String, String>> vehiculos = [
    {"label": "Coche", "value": "coche"},
    {"label": "Moto", "value": "moto"},
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.evento.data() as Map<String, dynamic>;
    _nombreController = TextEditingController(text: data['nombre']);
    _descripcionController = TextEditingController(text: data['descripcion']);
    _ciudadController = TextEditingController(text: data['ciudad']);
    _tipo = data['tipo'];
    _vehiculo = data['vehiculo'];
    _fecha = (data['fecha'] as Timestamp).toDate();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate() || _fecha == null || _tipo == null || _vehiculo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    final data = {
      'nombre': _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'tipo': _tipo,
      'vehiculo': _vehiculo,
      'ciudad': _ciudadController.text.trim(),
      'fecha': Timestamp.fromDate(_fecha!),
    };

    await FirebaseFirestore.instance
        .collection('eventos')
        .doc(widget.evento.id)
        .update(data);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento actualizado correctamente')),
      );
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (seleccionada == null) return;

    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fecha ?? DateTime.now()),
    );

    if (hora == null) return;

    final nuevaFecha = DateTime(
      seleccionada.year,
      seleccionada.month,
      seleccionada.day,
      hora.hour,
      hora.minute,
    );

    setState(() {
      _fecha = nuevaFecha;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            "Editar Evento",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: rojo,
            ),
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Información del evento",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rojo,
                  )),
              const SizedBox(height: 8),
              _buildTextField(_nombreController, 'Nombre del evento'),
              _buildTextField(_descripcionController, 'Descripción', maxLines: 8),

              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: InputDecoration(
                  labelText: "Tipo de evento",
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: tipos
                    .map((tipo) => DropdownMenuItem(
                          value: tipo['value'],
                          child: Text(tipo['label']!),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _tipo = value),
                validator: (value) => value == null ? 'Selecciona un tipo' : null,
              ),

              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _vehiculo,
                decoration: InputDecoration(
                  labelText: "Vehículo",
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: vehiculos
                    .map((v) => DropdownMenuItem(
                          value: v['value'],
                          child: Text(v['label']!),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _vehiculo = value),
                validator: (value) => value == null ? 'Selecciona un vehículo' : null,
              ),

              const SizedBox(height: 12),
              _buildTextField(_ciudadController, 'Ciudad'),

              const SizedBox(height: 16),
              Text("Fecha del evento",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rojo,
                  )),
              const SizedBox(height: 8),
              ListTile(
                tileColor: isDark ? Colors.grey[800] : Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _fecha != null
                      ? DateFormat('dd MMM yyyy – HH:mm', 'es_ES').format(_fecha!)
                      : 'Seleccionar fecha',
                  style: textTheme.bodyLarge,
                ),
                onTap: _seleccionarFecha,
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardarCambios,
                icon: const Icon(Icons.save),
                label: const Text("Guardar cambios"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: rojo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
          labelStyle: theme.textTheme.labelMedium,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: rojo, width: 1.5),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }
}
