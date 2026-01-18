import 'package:flutter/material.dart';

class MonitoringItem {
  final String title;
  String value;
  final String unit;
  final Color color;
  final IconData iconData;
  final String iconLetter;
  final List<double> dataPoints;

  MonitoringItem({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.iconData,
    required this.iconLetter,
    required this.dataPoints,
  });
}
