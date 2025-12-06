// lib/icons.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  // SVG Icons
  static const String bottle = 'assets/icons/feeding-bottle.svg';

  // Material Icons used in HomeScreen
  static const IconData feedingBottle = Icons.local_drink;
  static const IconData sleep = Icons.nightlight_round;
  static const IconData diaper = Icons.opacity;
  static const IconData temperature = Icons.thermostat;
  static const IconData time = Icons.access_time;
  static const IconData feeding = Icons.local_drink;
  static const IconData sleepNight = Icons.nights_stay;
  static const IconData medication = Icons.medication;
  static const IconData hospital = Icons.local_hospital;

  static Widget svg(String path, {double size = 32, Color? color}) =>
      SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );
}
