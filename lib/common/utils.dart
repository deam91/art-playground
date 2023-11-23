// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:xml/xml.dart';

launch(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    debugPrint('Could not launch $url');
  }
}

class SvgPath {
  final String path;
  final double rotation;
  final Color fillColor;
  final double fillOpacity;
  final String transform;

  SvgPath({
    required this.path,
    required this.rotation,
    required this.fillColor,
    required this.fillOpacity,
    required this.transform,
  });
}

Future<List<SvgPath>> loadSvgImage({required String svgImage}) async {
  List<SvgPath> maps = [];
  String generalString = await rootBundle.loadString(svgImage);

  XmlDocument document = XmlDocument.parse(generalString);

  final paths = document.findAllElements('path');

  for (var element in paths) {
    String partPath = element.getAttribute('d').toString();
    String colorString =
        (element.getAttribute('fill')?.toString() ?? 'D7D3D2').toUpperCase();
    String valueString = colorString.replaceAll('#', ''); // kind of hacky..
    int value = int.parse(valueString, radix: 16);
    Color color = Color(value);

    double opacity =
        double.parse(element.getAttribute('fill-opacity')?.toString() ?? '1');

    maps.add(SvgPath(
      path: partPath,
      fillColor: color,
      fillOpacity: opacity,
      rotation: .0,
      transform: '',
    ));
  }

  return maps;
}

Future<Size> getSvgSize({required String svgImage}) async {
  String generalString = await rootBundle.loadString(svgImage);
  XmlDocument document = XmlDocument.parse(generalString);

  final svg = document.findAllElements('svg');
  String width =
      svg.first.getAttribute('width').toString().replaceAll('px', '');
  String height =
      svg.first.getAttribute('height').toString().replaceAll('px', '');
  return Size(double.parse(width), double.parse(height));
}

Future<List<Vector2>> loadSvgJson({required String svg}) async {
  List<Vector2> maps = [];
  String generalString = await rootBundle.loadString(svg);
  final data = json.decode(generalString) as List<dynamic>;
  for (var i = 0; i < data.length - 1; i += 2) {
    double x = .0;
    if (data[i] is int) {
      x = data[i].toDouble();
    } else if (data[i] is double) {
      x = data[i];
    } else if (data[i] is String) {
      x = double.parse(data[i] as String);
    }

    double y = .0;
    if (data[i + 1] is int) {
      y = data[i + 1].toDouble();
    } else if (data[i + 1] is double) {
      y = data[i + 1];
    } else if (data[i] is String) {
      y = double.parse(data[i + 1] as String);
    }
    maps.add(Vector2(x, y));
  }
  return maps;
}
