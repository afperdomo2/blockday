import 'package:flutter/material.dart';

const List<Color> activityPalette = <Color>[
  Color(0xFF039BE5),
  Color(0xFF3F51B5),
  Color(0xFF7986CB),
  Color(0xFF8E24AA),
  Color(0xFFD50000),
  Color(0xFFE67C73),
  Color(0xFFF4511E),
  Color(0xFFF6BF26),
  Color(0xFF7CB342),
  Color(0xFF0B8043),
  Color(0xFF616161),
];

Color activityColor(int index) =>
    activityPalette[index % activityPalette.length];
