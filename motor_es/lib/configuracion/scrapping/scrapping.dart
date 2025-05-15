import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class ScraperEventos {
  static const String creadorID = 'pWqRiEXspfQLQX1v03zcg1lEzX42';
  static const String urlEventos = 'https://www.coches.net/noticias/calendario-de-eventos-motor-2025';
  static const String apiKey = 'AIzaSyD08IKjkvYqAgjTcT_u6HBqrzRVjEn18eY'; // Sustituye

  Future<void> ejecutarScraping() async {
    try {
      final response = await http.get(Uri.parse(urlEventos));
      if (response.statusCode != 200) {
        return;
      }

      final document = parser.parse(response.body);

      final contenedores = document.querySelectorAll('.mt-NewsDetail-articleBodyHeading');

      final meses2025 = RegExp(
        r'^(enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre)\s+2025$',
        caseSensitive: false,
      );

      for (final contenedor in contenedores) {
        final h2 = contenedor.querySelector('h2');
        if (h2 == null) continue;

        final nombre = h2.text.trim();
        if (meses2025.hasMatch(nombre.toLowerCase())) continue;

        // Buscar el siguiente <ul> que contiene los datos del evento
        Element? ul = contenedor.nextElementSibling;
        while (ul != null &&
            (ul.localName != 'ul' || !ul.classes.contains('mt-NewsDetail-articleBodyUnorderedList'))) {
          ul = ul.nextElementSibling;
        }

        if (ul == null) {
          continue;
        }

        final parrafos = ul.querySelectorAll('li > p.mt-NewsDetail-articleBodyParagraph');
        if (parrafos.length < 3) {
          continue;
        }

        final fechaTexto = _extraerValor(parrafos[0].text, 'Fecha');
        final ciudad = _extraerValor(parrafos[1].text, 'Lugar');
        final descripcion = _extraerValor(parrafos[2].text, 'Descripción');

        final fecha = _parseFecha(fechaTexto);
        final geo = await _obtenerCoordenadasCiudad(ciudad);

        final existe = await FirebaseFirestore.instance
            .collection('eventos')
            .where('nombre', isEqualTo: nombre)
            .get();

        if (existe.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('eventos').add({
            'creadoPor': creadorID,
            'nombre': nombre,
            'descripcion': descripcion,
            'fecha': Timestamp.fromDate(fecha),
            'tipo': 'mixto',
            'vehiculo': 'coche',
            'ciudad': ciudad,
            'ubicacion': geo,
          });

        } else {
        }
      }
    } catch (e) {
      return;
    }
  }

  String _extraerValor(String texto, String campo) {
    final partes = texto.split(':');
    return partes.length > 1 ? partes[1].trim() : texto.trim();
  }

  DateTime _parseFecha(String texto) {
    final meses = {
      'enero': 1, 'febrero': 2, 'marzo': 3, 'abril': 4, 'mayo': 5,
      'junio': 6, 'julio': 7, 'agosto': 8, 'septiembre': 9,
      'octubre': 10, 'noviembre': 11, 'diciembre': 12,
    };

    final textoLimpio = texto.toLowerCase();

    final rango = RegExp(r'(\d{1,2})\s*(?:al|-)\s*(\d{1,2})\s+de\s+(\w+)\s+de\s+(\d{4})');
    final simple = RegExp(r'(\d{1,2})\s+de\s+(\w+)\s+de\s+(\d{4})');

    final matchRango = rango.firstMatch(textoLimpio);
    if (matchRango != null) {
      final dia = int.parse(matchRango.group(1)!);
      final mes = meses[matchRango.group(3)!]!;
      final anio = int.parse(matchRango.group(4)!);
      return DateTime(anio, mes, dia);
    }

    final matchSimple = simple.firstMatch(textoLimpio);
    if (matchSimple != null) {
      final dia = int.parse(matchSimple.group(1)!);
      final mes = meses[matchSimple.group(2)!]!;
      final anio = int.parse(matchSimple.group(3)!);
      return DateTime(anio, mes, dia);
    }

    return DateTime.now(); // fallback
  }

  Future<GeoPoint> _obtenerCoordenadasCiudad(String ciudad) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(ciudad)}&key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final location = json['results'][0]['geometry']['location'];
        return GeoPoint(location['lat'], location['lng']);
      }
    } catch (e) {
    }

    return const GeoPoint(0.0, 0.0); // fallback
  }
}
