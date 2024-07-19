import 'package:flutter/material.dart';

class EventCategory {
  final String name;
  final String? imagePath;
  final IconData? icon;
  bool isSelected;

  EventCategory({
    required this.name,
    this.imagePath,
    this.icon,
    this.isSelected = false,
  }) : assert(imagePath != null || icon != null,
            'Either imagePath or icon must be provided');
}
